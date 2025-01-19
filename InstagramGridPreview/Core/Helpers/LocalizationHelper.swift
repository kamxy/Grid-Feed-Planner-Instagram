import Foundation

final class LocalizationHelper {
    static let shared = LocalizationHelper()
    
    private let dateFormatter: DateFormatter
    private let numberFormatter: NumberFormatter
    private let byteCountFormatter: ByteCountFormatter
    private let relativeDateFormatter: RelativeDateTimeFormatter
    
    private init() {
        dateFormatter = DateFormatter()
        numberFormatter = NumberFormatter()
        byteCountFormatter = ByteCountFormatter()
        relativeDateFormatter = RelativeDateTimeFormatter()
        
        updateFormatters()
        
        // Observe language changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateFormatters),
            name: NSLocale.currentLocaleDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func updateFormatters() {
        let currentLocale = Locale.current
        
        dateFormatter.locale = currentLocale
        numberFormatter.locale = currentLocale
        // ByteCountFormatter automatically uses system locale
        relativeDateFormatter.locale = currentLocale
        
        // Configure number formatter defaults
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
    }
    
    // MARK: - Date Formatting
    
    func formatDate(_ date: Date, style: DateFormatter.Style = .medium) -> String {
        dateFormatter.dateStyle = style
        return dateFormatter.string(from: date)
    }
    
    func formatTime(_ date: Date, style: DateFormatter.Style = .short) -> String {
        dateFormatter.timeStyle = style
        return dateFormatter.string(from: date)
    }
    
    func formatDateTime(_ date: Date, dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .short) -> String {
        dateFormatter.dateStyle = dateStyle
        dateFormatter.timeStyle = timeStyle
        return dateFormatter.string(from: date)
    }
    
    func formatRelativeDate(_ date: Date) -> String {
        return relativeDateFormatter.localizedString(for: date, relativeTo: Date())
    }
    
    // MARK: - Number Formatting
    
    func formatNumber(_ number: Double, style: NumberFormatter.Style = .decimal) -> String {
        numberFormatter.numberStyle = style
        return numberFormatter.string(from: NSNumber(value: number)) ?? String(number)
    }
    
    func formatPercentage(_ number: Double) -> String {
        numberFormatter.numberStyle = .percent
        return numberFormatter.string(from: NSNumber(value: number)) ?? "\(number)%"
    }
    
    func formatCurrency(_ amount: Double, currencyCode: String = "USD") -> String {
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = currencyCode
        return numberFormatter.string(from: NSNumber(value: amount)) ?? String(amount)
    }
    
    func formatFileSize(_ bytes: Int64) -> String {
        return byteCountFormatter.string(fromByteCount: bytes)
    }
    
    // MARK: - Date Components
    
    func formatDateComponents(_ components: DateComponents, style: DateComponentsFormatter.UnitsStyle = .full) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = style
        formatter.maximumUnitCount = 2
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute]
        return formatter.string(from: components) ?? ""
    }
    
    // MARK: - Custom Date Formats
    
    func formatCustomDate(_ date: Date, format: String) -> String {
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    // MARK: - Helpers
    
    func isRTL() -> Bool {
        return Locale.characterDirection(forLanguage: Locale.current.language.languageCode?.identifier ?? "") == .rightToLeft
    }
    
    func currentLanguageCode() -> String {
        return Locale.current.language.languageCode?.identifier ?? "en"
    }
    
    func currentLanguageName() -> String {
        return Locale.current.language.languageCode?.identifier.localizedCapitalized ?? "English"
    }
} 