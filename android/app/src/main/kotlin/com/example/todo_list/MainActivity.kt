package com.example.todo_list

import android.content.Intent
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log // Import Log for debugging

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.todo_list/call_service"
    // private val NAVIGATION_CHANNEL = "com.example.todo_list/navigation" // No longer needed for navigation

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "startCallService") {
                    val intent = Intent(this, MyForegroundService::class.java)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(intent)
                    } else {
                        startService(intent)
                    }
                    result.success(null)
                }
                if(call.method == "stopCallService") {
                    val intent = Intent(this, MyForegroundService::class.java)
                    stopService(intent)
                    result.success(null)
                }
            }

        // No need for a navigation channel listener here if using deep links directly
    }

    // getInitialRoute() might still be called, but go_router will handle the deep link from the Intent's data
    override fun getInitialRoute(): String? {
        val route = intent?.data?.path // For deep links, the path is typically the route
        Log.d("MainActivity", "getInitialRoute (Deep Link): $route, URI: ${intent?.data}")
        return route ?: "/"
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent) // Always update the activity's intent
        val deepLinkUri = intent.data
        if (deepLinkUri != null) {
            Log.d("MainActivity", "onNewIntent (Deep Link): Received URI: $deepLinkUri")
            // go_router will automatically process this URI when Flutter engine resumes/attaches
            // No explicit MethodChannel call needed here
        }
    }
}