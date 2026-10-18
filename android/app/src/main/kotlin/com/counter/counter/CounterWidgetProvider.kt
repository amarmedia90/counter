package com.counter.counter

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import com.counter.counter.R

class CounterWidgetProvider : AppWidgetProvider() {
  override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
    val count = context
      .getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE)
      .getInt(COUNTER_KEY, 0)

    for (appWidgetId in appWidgetIds) {
      val views = RemoteViews(context.packageName, R.layout.counter_widget)
      views.setTextViewText(R.id.counter_widget_value, "$count")
      appWidgetManager.updateAppWidget(appWidgetId, views)
    }
  }

  companion object {
    const val PREFERENCES_NAME = "counter_prefs"
    const val COUNTER_KEY = "counter"
  }
}
