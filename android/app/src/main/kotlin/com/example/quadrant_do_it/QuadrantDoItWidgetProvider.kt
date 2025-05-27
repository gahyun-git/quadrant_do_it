package com.example.quadrantdoit.widget

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import com.example.quadrantdoit.R
import es.antonborri.home_widget.HomeWidgetProvider

class QuadrantDoItWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        super.onUpdate(context, appWidgetManager, appWidgetIds)
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout)
            val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
            val title = prefs.getString("today_todo", "오늘의 할일 없음")
            val summary = prefs.getString("matrix_summary", "매트릭스 요약 없음")
            views.setTextViewText(R.id.widgetTitle, title)
            views.setTextViewText(R.id.widgetSummary, summary)
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}