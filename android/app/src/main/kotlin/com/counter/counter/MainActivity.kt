package com.counter.counter

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.content.ComponentName
import android.appwidget.AppWidgetManager

class MainActivity : FlutterActivity() {
  private val channel = "com.counter.counter/counter"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
      .setMethodCallHandler { call, result ->
      when (call.method) {
        "loadCounter" -> {
          val prefs = getSharedPreferences(CounterWidgetProvider.PREFERENCES_NAME, Context.MODE_PRIVATE)
          val savedCount = prefs.getInt(CounterWidgetProvider.COUNTER_KEY, 0)
          result.success(savedCount)
        }
        "saveCounter" -> {
          val countToSave = call.argument<Int>("count")
          if (countToSave != null) {
            getSharedPreferences(CounterWidgetProvider.PREFERENCES_NAME, Context.MODE_PRIVATE)
              .edit()
              .putInt(CounterWidgetProvider.COUNTER_KEY, countToSave)
              .apply()

            val manager = AppWidgetManager.getInstance(this)
            val component = ComponentName(this, CounterWidgetProvider::class.java)
            val widgetIds = manager.getAppWidgetIds(component)
            CounterWidgetProvider().onUpdate(this, manager, widgetIds)
            result.success(true)
          } else {
            result.error("INVALID_ARGUMENT", "Count argument is required", null)
          }
        }
        else -> {
          // Step 14: Handle unknown channel method names
          result.notImplemented()
        }
      }
      }
  }
}
