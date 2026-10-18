package com.counter.counter

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import com.counter.counter.R // Assuming R is generated and refers to the correct resources

class CounterWidgetProvider : AppWidgetProvider() {

  override fun onUpdate(
      context: Context,
      appWidgetManager: AppWidgetManager,
      appWidgetIds: IntArray) {
    for (appWidgetId in appWidgetIds) {
      // Read the counter value from SharedPreferences (matching MainActivity.kt)
      val prefs = context.getSharedPreferences("counter_prefs", Context.MODE_PRIVATE) as android.content.SharedPreferences
      val count = prefs.getInt("counter", 0)

      val views = RemoteViews(context.packageName, R.layout.counter_widget)
      
      // Set the counter value
      views.setTextViewText(R.id.counter_widget_value, "$count")
      
      // Update the widget instance
      appWidgetManager.updateAppWidget(appWidgetId, views)
    }
  }
}