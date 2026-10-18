package com.counter.counter

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.SharedPreferences
import android.content.Context
import android.content.ContextImpl

class MainActivity : FlutterActivity() {
  private val channel = "com.counter.counter/counter"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    
    MethodChannel(channel).setMethodCallHandler { call, result ->
      when (call.method) {
        "loadCounter" -> {
          // Step 9: Load counter from SharedPreferences
          val prefs = getSharedPreferences("counter_prefs", Context.MODE_PRIVATE) as SharedPreferences
          val savedCount = prefs.getInt("counter", 0)
          result.success(savedCount)
        }
        "saveCounter" -> {
          val countToSave = call.argument<Int>("count")
          if (countToSave != null) {
            // Step 12: Save to SharedPreferences
            val prefs = getSharedPreferences("counter_prefs", Context.MODE_PRIVATE) as SharedPreferences
            prefs.edit().putInt("counter", countToSave).apply()
            // Step 13: (This will be handled by the WidgetProvider later)
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