package com.counter.counter

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.os.Build
import android.util.TypedValue
import android.view.View
import android.widget.RemoteViews
import androidx.core.widget.RemoteViewsCompat
import com.counter.counter.R

class CounterWidgetProvider : AppWidgetProvider() {
  override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
    val prefs = context.getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE)
    val count = prefs.getInt(COUNTER_KEY, 0)
    val transparency = prefs.getInt(TRANSPARENCY_KEY, DEFAULT_TRANSPARENCY).coerceIn(0, 100)
    val shadow = prefs.getInt(SHADOW_KEY, DEFAULT_SHADOW).coerceIn(0, 100)

    for (appWidgetId in appWidgetIds) {
      val views = RemoteViews(context.packageName, R.layout.counter_widget)
      views.setTextViewText(R.id.counter_widget_value, "$count")
      views.setFloat(
        R.id.counter_widget_background,
        "setAlpha",
        (100 - transparency) / 100f,
      )

      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        views.setViewVisibility(R.id.counter_widget_shadow, View.GONE)
        RemoteViewsCompat.setViewElevationDimen(
          views,
          R.id.counter_widget_background,
          shadow * 0.16f,
          TypedValue.COMPLEX_UNIT_DIP,
        )
      } else {
        views.setViewVisibility(R.id.counter_widget_shadow, View.VISIBLE)
        views.setFloat(R.id.counter_widget_shadow, "setAlpha", shadow / 100f)
      }
      appWidgetManager.updateAppWidget(appWidgetId, views)
    }
  }

  companion object {
    const val PREFERENCES_NAME = "counter_prefs"
    const val COUNTER_KEY = "counter"
    const val TRANSPARENCY_KEY = "widget_transparency"
    const val SHADOW_KEY = "widget_shadow"
    const val DEFAULT_TRANSPARENCY = 22
    const val DEFAULT_SHADOW = 50
  }
}
