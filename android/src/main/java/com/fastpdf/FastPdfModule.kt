package com.fastpdf

import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.module.annotations.ReactModule
import java.io.File
import android.os.Environment // Import cần thiết cho DIRECTORY_DOWNLOADS
import android.widget.Toast // IMPORT MỚI: Thêm Toast
@ReactModule(name = FastPdfModule.NAME)
class FastPdfModule(reactContext: ReactApplicationContext) :
  NativeFastPdfSpec(reactContext) {

  companion object {
    const val NAME = "FastPdf"
  }

  override fun getName(): String = NAME
  /**
   * Tải file PDF từ URL về thư mục Downloads riêng tư của ứng dụng.
   * File sẽ được lưu trong thư mục: Android/data/{packageName}/files/Download/
   * * @param uri URL của file PDF
   * @param promise Promise để trả về đường dẫn tuyệt đối của file đã tải
   */
  @ReactMethod
  override fun downloadPdf(uri: String, promise: com.facebook.react.bridge.Promise) {
    try {
      val context = reactApplicationContext

      // 1. Kiểm tra URL
      if (!uri.startsWith("http://") && !uri.startsWith("https://")) {
        promise.reject("EINVAL", "Invalid URL: $uri")
        return
      }

      // 2. Lấy đường dẫn thư mục Tải xuống (Downloads) của ứng dụng
      // Dùng DIRECTORY_DOWNLOADS để lưu vào thư mục 'Download' riêng tư của app.
      val downloadsDir = context.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS)
      if (downloadsDir == null) {
        promise.reject("EDIR", "Cannot access Downloads directory")
        return
      }

      // 3. Tạo đường dẫn file
      val fileName = Uri.parse(uri).lastPathSegment ?: "downloaded.pdf"
      val destinationFile = File(downloadsDir, fileName)

      // Nếu file tồn tại, xóa trước khi tải lại
      if (destinationFile.exists()) {
        destinationFile.delete()
      }

      // 4. Bắt đầu tải xuống bằng Thread (non-blocking)
      Thread {
        try {
          val url = java.net.URL(uri)
          val connection = url.openConnection()
          connection.connect()

          val input = connection.getInputStream()
          val output = destinationFile.outputStream()

          input.use { inputStream ->
            output.use { outputStream ->
              inputStream.copyTo(outputStream)
            }
          }

          // Trả về đường dẫn tuyệt đối sau khi tải xong
          promise.resolve(destinationFile.absolutePath)
           // THÊM TOAST: Hiển thị thông báo thành công trên Main Thread
          context.currentActivity?.runOnUiThread {
            Toast.makeText(context, "Tải tệp \"$fileName\" thành công!", Toast.LENGTH_LONG).show()
          }
        } catch (e: Exception) {
           // THÊM TOAST: Hiển thị thông báo thất bại trên Main Thread
          // context.currentActivity?.runOnUiThread {
          //   Toast.makeText(context, "Tải tệp thất bại!", Toast.LENGTH_LONG).show()
          // }
          promise.reject("EDOWNLOAD", "Download failed: ${e.localizedMessage}", e)
        }
      }.start()

    } catch (e: Exception) {
      promise.reject("EUNEXPECTED", e.localizedMessage, e)
    }
  }

  // @ReactMethod
  // override fun downloadPdf(uri: String, promise: com.facebook.react.bridge.Promise) {
  //   try {
  //     val context = reactApplicationContext

  //     // Validate URL
  //     if (!uri.startsWith("http://") && !uri.startsWith("https://")) {
  //       promise.reject("EINVAL", "Invalid URL: $uri")
  //       return
  //     }

  //     // Get destination file path inside Documents
  //     val downloadsDir = context.getExternalFilesDir(android.os.Environment.DIRECTORY_DOCUMENTS)
  //     if (downloadsDir == null) {
  //       promise.reject("EDIR", "Cannot access Documents directory")
  //       return
  //     }

  //     val fileName = Uri.parse(uri).lastPathSegment ?: "downloaded.pdf"
  //     val destinationFile = File(downloadsDir, fileName)

  //     // If file exists, delete it before re-downloading
  //     if (destinationFile.exists()) {
  //       destinationFile.delete()
  //     }

  //     // Download using thread (non-blocking)
  //     Thread {
  //       try {
  //         val url = java.net.URL(uri)
  //         val connection = url.openConnection()
  //         connection.connect()

  //         val input = connection.getInputStream()
  //         val output = destinationFile.outputStream()

  //         input.use { inputStream ->
  //           output.use { outputStream ->
  //             inputStream.copyTo(outputStream)
  //           }
  //         }

  //         promise.resolve(destinationFile.absolutePath)
  //       } catch (e: Exception) {
  //         promise.reject("EDOWNLOAD", "Download failed: ${e.localizedMessage}", e)
  //       }
  //     }.start()

  //   } catch (e: Exception) {
  //     promise.reject("EUNEXPECTED", e.localizedMessage, e)
  //   }
  // }

  /**
   * Mở file PDF — có thể là local hoặc online
   * @param uri đường dẫn file PDF (vd: file:///data/user/0/... hoặc https://example.com/file.pdf)
   */
  @ReactMethod
  override fun openPdf(uri: String, promise: com.facebook.react.bridge.Promise) {
    try {
      val context = reactApplicationContext

      // ✅ Nếu là file local
      if (uri.startsWith("file://") || File(uri).exists()) {
        val file = if (uri.startsWith("file://")) {
          File(Uri.parse(uri).path!!)
        } else {
          File(uri)
        }

        if (!file.exists()) {
          promise.reject("ENOENT", "Local file not found: ${file.path}")
          return
        }

        // Dùng FileProvider để chia sẻ file với các app khác (PDF viewer)
        val pdfUri = FileProvider.getUriForFile(
          context,
          context.packageName + ".provider",
          file
        )

        val intent = Intent(Intent.ACTION_VIEW).apply {
          setDataAndType(pdfUri, "application/pdf")
          addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
          addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }

        context.startActivity(intent)
        promise.resolve("Opened local PDF: ${file.path}")
      }

      // ✅ Nếu là link online
      else if (uri.startsWith("http://") || uri.startsWith("https://")) {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(uri)).apply {
          addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
        promise.resolve("Opened online PDF: $uri")
      }

      // ❌ URI không hợp lệ
      else {
        promise.reject("EINVAL", "Invalid URI: $uri")
      }

    } catch (e: Exception) {
      promise.reject("EOPEN", e.localizedMessage, e)
    }
  }
}
