package com.example.todo_list

import android.content.*
import android.net.Uri // Import Uri
import android.widget.Toast

class NotificationActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            "ACTION_ACCEPT" -> {
                val deepLinkUri = Uri.parse("todoapp://example.com/add_task") // Your deep link URI
                val addTaskIntent = Intent(context, MainActivity::class.java).apply {
                    action = Intent.ACTION_VIEW // Crucial: Set action to ACTION_VIEW
                    data = deepLinkUri          // Set the data URI
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                context.startActivity(addTaskIntent)
            }

            "ACTION_DECLINE" -> {
                val deepLinkUri = Uri.parse("todoapp://example.com/settings") // Your deep link URI
                val settingsIntent = Intent(context, MainActivity::class.java).apply {
                    action = Intent.ACTION_VIEW // Crucial: Set action to ACTION_VIEW
                    data = deepLinkUri          // Set the data URI
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                context.startActivity(settingsIntent)
            }
        }
    }
}