import WidgetKit
import SwiftUI

struct CountDownWidget: Widget {
    let kind: String = "CDWidgetExtension"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: CountDownProvider()
        ) { entry in
            CountDownWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("イベント")
        .description("大切な日までの残り日数を表示します。")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryInline, .accessoryCircular, .accessoryRectangular])
    }
}

struct CountDownWidget_Previews: PreviewProvider {
    static var previews: some View {
        let sampleEvent = Event(
            title: "旅行",
            targetDate: Calendar.current.date(byAdding: .day, value: 12, to: Date()) ?? Date(),
            emoji: "✈️"
        )
        
        let entry = CountDownEntry(
            date: Date(),
            event: sampleEvent
        )
        
        Group {
            CountDownWidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            CountDownWidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            CountDownWidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .accessoryInline))
            
            CountDownWidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .accessoryCircular))
            
            CountDownWidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
        }
    }
}