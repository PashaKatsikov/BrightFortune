package com.brightfortune.brightfortunegame

import android.app.Activity
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// ============================================================
// MainActivity — WebView file-upload bridge
// ============================================================
// Dependency-free WebView file upload: the site's <input type="file">
// triggers the WebView's file selector, which hops here over a
// MethodChannel and returns the picked content:// URIs. Deliberately
// avoids file_picker (gray_part_pitfalls.md §1).
//
// `channelName` must stay identical to the MethodChannel name in
// lib/relay/stage/portal_stage.dart; both are rotated together by
// tool/forge/mint.dart.
// ============================================================
class MainActivity : FlutterActivity() {
    private val channelName = "lantern/chooser"
    private val pickRequest = 0x5C31
    private var pendingResult: MethodChannel.Result? = null

    // The keyboard must never resize the window.
    //
    // Under the manifest's adjustResize the IME inset reaches the
    // WebView, and Chromium then scrolls the focused editable into
    // view by itself — that native scroll fights the JS lift and is
    // what makes the page jump. The same inset also un-hides the
    // navigation bar as a window inset, which shrinks the WebView
    // (a side bar in landscape, a bottom strip in portrait).
    //
    // ADJUST_NOTHING leaves the window untouched and lets the
    // keyboard float above it. Applied from API 30 only: since
    // Android 11 the IME inset is reported through
    // WindowInsets.Type.ime() no matter the soft-input mode, so
    // Flutter still knows the keyboard height and can hand it to the
    // page. Older releases only learn the height from a window
    // resize, so they keep adjustResize and Chromium's native scroll.
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.setSoftInputMode(
                WindowManager.LayoutParams.SOFT_INPUT_ADJUST_NOTHING,
            )
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method == "pick") {
                    val multiple = call.argument<Boolean>("multiple") ?: false
                    val mimes = call.argument<List<String>>("mimeTypes") ?: emptyList()
                    openChooser(multiple, mimes, result)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun openChooser(
        multiple: Boolean,
        mimes: List<String>,
        result: MethodChannel.Result,
    ) {
        // Resolve any abandoned request before starting a new one.
        pendingResult?.success(emptyList<String>())
        pendingResult = result

        val valid = mimes.filter { it.contains("/") }
        val intent = Intent(Intent.ACTION_GET_CONTENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            putExtra(Intent.EXTRA_ALLOW_MULTIPLE, multiple)
            when {
                valid.isEmpty() -> type = "*/*"
                valid.size == 1 -> type = valid[0]
                else -> {
                    type = "*/*"
                    putExtra(Intent.EXTRA_MIME_TYPES, valid.toTypedArray())
                }
            }
        }

        try {
            startActivityForResult(Intent.createChooser(intent, null), pickRequest)
        } catch (e: Exception) {
            pendingResult = null
            result.success(emptyList<String>())
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != pickRequest) return

        val result = pendingResult
        pendingResult = null
        if (result == null) return

        if (resultCode != Activity.RESULT_OK || data == null) {
            result.success(emptyList<String>())
            return
        }

        val uris = ArrayList<String>()
        val clip = data.clipData
        if (clip != null) {
            for (i in 0 until clip.itemCount) {
                uris.add(clip.getItemAt(i).uri.toString())
            }
        } else {
            data.data?.let { uris.add(it.toString()) }
        }
        result.success(uris)
    }
}
