package com.nachiket.wultra_flutter

import android.os.Build
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.wultra_ssl_pinning"
    private lateinit var sslPinningHandler: WultraSslPinningHandler

    @RequiresApi(Build.VERSION_CODES.O)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        sslPinningHandler = WultraSslPinningHandler(applicationContext)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initCertStore" -> {
                    val success = sslPinningHandler.initCertStore()
                    result.success(success)
                }
                "getUpdateOnFingerprints" -> {
                    val message = sslPinningHandler.getUpdateOnFingerprints()
                    result.success(message)
                }
                else -> result.notImplemented()
            }
        }
    }
}
