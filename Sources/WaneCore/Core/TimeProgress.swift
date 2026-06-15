import Foundation

struct ProgressInfo: Identifiable, Equatable {
    let dimension: TimeDimension
    let progress: Double
    let detail: String

    var id: TimeDimension { dimension }

    var percentText: String {
        "\(Int((progress * 100).rounded()))%"
    }
}

enum TimeProgress {
    static func snapshot(
        now: Date = Date(),
        calendar: Calendar = .current,
        workStart: TimeOfDay = PreferenceStore.workStart,
        workEnd: TimeOfDay = PreferenceStore.workEnd,
        dimensions: [TimeDimension] = PreferenceStore.enabledDimensions
    ) -> [ProgressInfo] {
        dimensions.map {
            progress(for: $0, now: now, calendar: calendar, workStart: workStart, workEnd: workEnd)
        }
    }

    static func progress(
        for dimension: TimeDimension,
        now: Date,
        calendar inputCalendar: Calendar = .current,
        workStart: TimeOfDay = PreferenceStore.workStart,
        workEnd: TimeOfDay = PreferenceStore.workEnd
    ) -> ProgressInfo {
        var calendar = inputCalendar
        calendar.firstWeekday = 2

        switch dimension {
        case .today:
            return dayProgress(now: now, calendar: calendar, workStart: workStart, workEnd: workEnd)
        case .week:
            return intervalProgress(
                dimension: dimension,
                now: now,
                interval: calendar.dateInterval(of: .weekOfYear, for: now),
                detail: weekDetail(now: now, calendar: calendar)
            )
        case .month:
            return intervalProgress(
                dimension: dimension,
                now: now,
                interval: calendar.dateInterval(of: .month, for: now),
                detail: monthDetail(now: now, calendar: calendar)
            )
        case .year:
            return intervalProgress(
                dimension: dimension,
                now: now,
                interval: calendar.dateInterval(of: .year, for: now),
                detail: yearDetail(now: now, calendar: calendar)
            )
        }
    }

    private static func dayProgress(
        now: Date,
        calendar: Calendar,
        workStart: TimeOfDay,
        workEnd: TimeOfDay
    ) -> ProgressInfo {
        let start = workStart.date(on: now, calendar: calendar)
        var end = workEnd.date(on: now, calendar: calendar)
        if end <= start {
            end = calendar.date(byAdding: .day, value: 1, to: end) ?? end
        }

        let total = end.timeIntervalSince(start)
        let elapsed = now.timeIntervalSince(start)
        let progress = clamp(elapsed / total)

        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.dateFormat = "HH:mm"

        return ProgressInfo(
            dimension: .today,
            progress: progress,
            detail: L10n.text(
                "time.workdayDetail",
                formatter.string(from: now),
                Int((progress * 100).rounded())
            )
        )
    }

    private static func intervalProgress(
        dimension: TimeDimension,
        now: Date,
        interval: DateInterval?,
        detail: String
    ) -> ProgressInfo {
        guard let interval else {
            return ProgressInfo(dimension: dimension, progress: 0, detail: detail)
        }

        let progress = clamp(now.timeIntervalSince(interval.start) / interval.duration)
        return ProgressInfo(dimension: dimension, progress: progress, detail: detail)
    }

    private static func weekDetail(now: Date, calendar: Calendar) -> String {
        let weekday = calendar.component(.weekday, from: now)
        let mondayBasedDay = ((weekday + 5) % 7) + 1
        return L10n.text("time.dayOf", mondayBasedDay, 7)
    }

    private static func monthDetail(now: Date, calendar: Calendar) -> String {
        let day = calendar.component(.day, from: now)
        let days = calendar.range(of: .day, in: .month, for: now)?.count ?? 30
        return L10n.text("time.dayOf", day, days)
    }

    private static func yearDetail(now: Date, calendar: Calendar) -> String {
        let day = calendar.ordinality(of: .day, in: .year, for: now) ?? 1
        let days = calendar.range(of: .day, in: .year, for: now)?.count ?? 365
        return L10n.text("time.dayOf", day, days)
    }

    private static func clamp(_ value: Double) -> Double {
        max(0, min(1, value.isFinite ? value : 0))
    }
}
