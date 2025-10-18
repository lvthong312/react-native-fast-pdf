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
                rejecter("Invalid URI: \(uri)")
            }
        }
    }

    // MARK: - Mở file local
    private func openLocalPdf(uri: String, resolver: @escaping (String) -> Void, rejecter: @escaping (String) -> Void) {
        let localURL = uri.starts(with: "file://")
            ? URL(fileURLWithPath: uri.replacingOccurrences(of: "file://", with: ""))
            : URL(fileURLWithPath: uri)

        guard FileManager.default.fileExists(atPath: localURL.path) else {
            rejecter("Local file not found: \(localURL.path)")
            return
        }

        presentPdf(url: localURL, resolver: resolver, rejecter: rejecter)
    }

    // MARK: - Mở online PDF bằng SafariViewController
    private func openOnlinePdf(uri: String, resolver: @escaping (String) -> Void, rejecter: @escaping (String) -> Void) {
        guard let url = URL(string: uri) else {
            rejecter("Invalid URL: \(uri)")
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

        rootVC.present(safariVC, animated: true) {
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

        rootVC.present(previewController, animated: true) {
            resolver("Opened local PDF: \(url.path)")
        }
    }

    // MARK: - QuickLook data source
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return pdfURL != nil ? 1 : 0
    }

    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return pdfURL! as QLPreviewItem
    }
}
