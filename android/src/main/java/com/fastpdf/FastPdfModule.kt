package com.fastpdf

import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.module.annotations.ReactModule
import java.io.File

@ReactModule(name = FastPdfModule.NAME)
class FastPdfModule(reactContext: ReactApplicationContext) :
  NativeFastPdfSpec(reactContext) {

  companion object {
    const val NAME = "FastPdf"
  }

  override fun getName(): String = NAME

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
