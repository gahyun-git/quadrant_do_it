//
//  QuadrantDoItWidget.swift
//  QuadrantDoItWidget
//
//  Created by gahyun on 5/26/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), title: "오늘의 할일 없음", summary: "매트릭스 요약 없음")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), title: "오늘의 할일 없음", summary: "매트릭스 요약 없음")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.com.example.quadrantDoIt")
        let title = userDefaults?.string(forKey: "today_todo") ?? "오늘의 할일 없음"
        let summary = userDefaults?.string(forKey: "matrix_summary") ?? "매트릭스 요약 없음"
        let entry = SimpleEntry(date: Date(), title: title, summary: summary)
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60*15)))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let title: String
    let summary: String
}

struct QuadrantDoItWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.title)
                .font(.headline)
                .padding(.bottom, 2)
            Text(entry.summary)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

struct QuadrantDoItWidget: Widget {
    let kind: String = "QuadrantDoItWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            QuadrantDoItWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Quadrant Do It")
        .description("오늘의 할일과 매트릭스 요약을 확인하세요.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
