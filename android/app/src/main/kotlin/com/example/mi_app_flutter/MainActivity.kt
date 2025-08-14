package com.petmatch

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Configuración adicional para Google Sign-In
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "google_sign_in_config").setMethodCallHandler { call, result ->
            when (call.method) {
                "getWebClientId" -> {
                    // Retornar el Web Client ID desde recursos
                    val webClientId = resources.getString(R.string.default_web_client_id)
                    result.success(webClientId)
                }
                else -> result.notImplemented()
            }
        }
    }
}
