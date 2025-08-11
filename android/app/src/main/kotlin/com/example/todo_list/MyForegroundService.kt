
package com.example.todo_list
import android.content.Context
import android.app.Service
import android.widget.RemoteViews
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import com.example.todo_list.R

class MyForegroundService : Service() {

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        createNotificationChannel()

        // Intents for buttons
        val acceptIntent = Intent(this, NotificationActionReceiver::class.java).apply {
            action = "ACTION_ACCEPT"
        }
        val declineIntent = Intent(this, NotificationActionReceiver::class.java).apply {
            action = "ACTION_DECLINE"
        }

        val acceptPendingIntent = PendingIntent.getBroadcast(
            this, 0, acceptIntent, PendingIntent.FLAG_IMMUTABLE
        )
        val declinePendingIntent = PendingIntent.getBroadcast(
            this, 1, declineIntent, PendingIntent.FLAG_IMMUTABLE
        )

        val remoteViews = RemoteViews(packageName, R.layout.custom_notification)

        // Set click actions for buttons
        remoteViews.setOnClickPendingIntent(R.id.btn_accept, acceptPendingIntent)
        remoteViews.setOnClickPendingIntent(R.id.btn_decline, declinePendingIntent)

        val notification = NotificationCompat.Builder(this, "call_channel")
            .setSmallIcon(R.mipmap.ic_launcher) // required
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setCustomContentView(remoteViews)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setAutoCancel(true)
            .build()

        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(1, notification)

        startForeground(1, notification)

        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "call_channel",
                "Call Notifications",
                NotificationManager.IMPORTANCE_HIGH
            )
            getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }
    }

}
