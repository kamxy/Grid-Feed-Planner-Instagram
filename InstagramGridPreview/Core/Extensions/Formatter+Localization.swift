import Foundation

// MARK: - Date Extension

extension Date {
    func localizedString(dateStyle: DateFormatter.Style = .medium,
                        timeStyle: DateFormatter.Style = .short) -> String {
        return LocalizationHelper.shared.formatDateTime(self, dateStyle: dateStyle, timeStyle: timeStyle)
    }
    
    func localizedDate(style: DateFormatter.Style = .medium) -> String {
        return LocalizationHelper.shared.formatDate(self, style: style)
    }
    
    func localizedTime(style: DateFormatter.Style = .short) -> String {
        return LocalizationHelper.shared.formatTime(self, style: style)
    }
    
    func localizedRelative() -> String {
        return LocalizationHelper.shared.formatRelativeDate(self)
    }
    
    func localizedCustomFormat(_ format: String) -> String {
        return LocalizationHelper.shared.formatCustomDate(self, format: format)
    }
}

// MARK: - Number Extension

extension Double {
    func localizedString(style: NumberFormatter.Style = .decimal) -> String {
        return LocalizationHelper.shared.formatNumber(self, style: style)
    }
    
    func localizedPercentage() -> String {
        return LocalizationHelper.shared.formatPercentage(self)
    }
    
    func localizedCurrency(currencyCode: String = Locale.current.currency?.identifier ?? "USD") -> String {
        return LocalizationHelper.shared.formatCurrency(self, currencyCode: currencyCode)
    }
}

// MARK: - File Size Extension

extension Int64 {
    var localizedFileSize: String {
        return LocalizationHelper.shared.formatFileSize(self)
    }
}

// MARK: - Duration Extension

extension TimeInterval {
    func localizedDuration(units: NSCalendar.Unit = [.hour, .minute],
                          style: DateComponentsFormatter.UnitsStyle = .full) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = style
        formatter.allowedUnits = units
        formatter.calendar?.locale = Locale.current
        return formatter.string(from: self) ?? ""
    }
}

// MARK: - Measurement Extension

extension Measurement {
    func localizedString(unitStyle: MeasurementFormatter.UnitStyle = .medium) -> String {
        let formatter = MeasurementFormatter()
        formatter.locale = Locale.current
        formatter.unitStyle = unitStyle
        return formatter.string(from: self)
    }
}

// MARK: - List Formatting Extension

extension Array where Element == String {
    func localizedList() -> String {
        let formatter = ListFormatter()
        formatter.locale = Locale.current
        return formatter.string(from: self) ?? ""
    }
} 