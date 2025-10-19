//
//  FastPdfImpl.swift
//  FastPdf
//
//  Created by Thong Luong on 18/10/25.
//
import Foundation
import UIKit
import QuickLook
import SafariServices

@objc public class FastPdfImpl: NSObject, QLPreviewControllerDataSource {
    private var pdfURL: URL?
    
    /**
     * Tải file PDF từ URL về thư mục Documents của ứng dụng.
     * File sẽ hiển thị trong Files app (On My iPhone/iPad > {AppName}/Documents).
     * @param uri URL của file PDF
     * @param resolver Callback trả về đường dẫn tuyệt đối của file đã tải
     * @param rejecter Callback trả về lỗi
     */
    @objc public func downloadPdf(
        uri: String,
        resolver: @escaping (String) -> Void,
        rejecter: @escaping (String) -> Void
    ) {
        guard let url = URL(string: uri) else {
            rejecter("EINVAL: Invalid URL: \(uri)")
            return
        }

        // 1. Lấy đường dẫn thư mục Documents (Nơi hiển thị được trong Files app)
        guard let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            rejecter("EDIR: Cannot access Documents directory")
            return
        }

        // 2. Tạo đường dẫn file đích
        // Đảm bảo tên file không rỗng, mặc định là downloaded.pdf
        let fileName = url.lastPathComponent.isEmpty || url.lastPathComponent.contains("/") ? "downloaded.pdf" : url.lastPathComponent
        let destinationURL = documentsDir.appendingPathComponent(fileName)

        // 3. Xóa file cũ nếu tồn tại
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            do {
                try FileManager.default.removeItem(at: destinationURL)
            } catch {
                rejecter("EWRITE: Failed to delete existing file: \(error.localizedDescription)")
                return
            }
        }

        // 4. Bắt đầu tải xuống (sử dụng URLSession)
        let task = URLSession.shared.downloadTask(with: url) { tempURL, response, error in
            if let error = error {
                rejecter("EDOWNLOAD: Download failed: \(error.localizedDescription)")
                return
            }

            guard let tempURL = tempURL else {
                rejecter("EDOWNLOAD: No data downloaded")
                return
            }

            // 5. Di chuyển file tạm đến vị trí đích
            do {
                try FileManager.default.moveItem(at: tempURL, to: destinationURL)
                
                // Trả về đường dẫn tuyệt đối sau khi tải xong
                resolver(destinationURL.path)
            } catch {
                rejecter("EWRITE: Failed to save file: \(error.localizedDescription)")
            }
        }

        task.resume()
    }
   
    @objc public func openPdf(
        uri: String,
        resolver: @escaping (String) -> Void,
        rejecter: @escaping (String) -> Void
    ) {
        DispatchQueue.main.async {
            if uri.starts(with: "file://") || FileManager.default.fileExists(atPath: uri) {
                self.openLocalPdf(uri: uri, resolver: resolver, rejecter: rejecter)
            } else if uri.starts(with: "http://") || uri.starts(with: "https://") {
                // ✅ Mở online PDF trực tiếp (không tải về)
                self.openOnlinePdf(uri: uri, resolver: resolver, rejecter: rejecter)
            } else {
                rejecter("EINVAL: Invalid URI: \(uri)")
            }
        }
    }

    // MARK: - Mở file local
    private func openLocalPdf(uri: String, resolver: @escaping (String) -> Void, rejecter: @escaping (String) -> Void) {
        let localURL = uri.starts(with: "file://")
            ? URL(fileURLWithPath: uri.replacingOccurrences(of: "file://", with: ""))
            : URL(fileURLWithPath: uri)

        guard FileManager.default.fileExists(atPath: localURL.path) else {
            rejecter("ENOENT: Local file not found: \(localURL.path)")
            return
        }

        presentPdf(url: localURL, resolver: resolver, rejecter: rejecter)
    }

    // MARK: - Mở online PDF bằng SafariViewController
    private func openOnlinePdf(uri: String, resolver: @escaping (String) -> Void, rejecter: @escaping (String) -> Void) {
        guard let url = URL(string: uri) else {
            rejecter("EINVAL: Invalid URL: \(uri)")
            return
        }

        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = .systemBlue

        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
            .first?.rootViewController else {
            rejecter("Cannot find rootViewController")
            return
        }

        // Tìm UIViewController đang hiển thị để present SFSafariViewController
        var topController = rootVC
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }

        topController.present(safariVC, animated: true) {
            resolver("Opened online PDF: \(uri)")
        }
    }

    // MARK: - Hiển thị local PDF bằng QuickLook
    private func presentPdf(url: URL, resolver: @escaping (String) -> Void, rejecter: @escaping (String) -> Void) {
        self.pdfURL = url

        let previewController = QLPreviewController()
        previewController.dataSource = self

        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
            .first?.rootViewController else {
            rejecter("Cannot find rootViewController")
            return
        }
        
        // Tìm UIViewController đang hiển thị để present QLPreviewController
        var topController = rootVC
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }

        topController.present(previewController, animated: true) {
            resolver("Opened local PDF with QuickLook: \(url.path)")
        }
    }

    // MARK: - Hiển thị Thông báo ngắn (Toast/HUD đơn giản)
    /**
     * Hiển thị một UIAlertController mô phỏng Toast và tự động đóng.
     */
    // private func showToast(message: String) {
    //     // 1. Tìm UIViewController đang hiển thị
    //     guard let rootVC = UIApplication.shared.connectedScenes
    //         .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
    //         .first?.rootViewController else {
    //         return
    //     }
        
    //     var topController = rootVC
    //     while let presentedViewController = topController.presentedViewController {
    //         topController = presentedViewController
    //     }

    //     // 2. Tạo UIAlertController (Toast)
    //     let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
    //     // 3. Hiển thị Alert
    //     topController.present(alert, animated: true)
        
    //     // 4. Tự động dismiss sau 1.5 giây
    //     DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
    //         // Kiểm tra xem alert có còn đang hiển thị không trước khi đóng
    //         if alert.presentingViewController != nil {
    //             alert.dismiss(animated: true, completion: nil)
    //         }
    //     }
    // }


    // MARK: - QuickLook data source
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return pdfURL != nil ? 1 : 0
    }

    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return pdfURL! as QLPreviewItem
    }
}
