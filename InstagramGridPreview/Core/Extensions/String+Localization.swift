import Foundation

extension String {
    static func localized(_ key: StringKey) -> String {
        return key.localized
    }
    
    static func localized(_ key: StringKey, arguments: CVarArg...) -> String {
        return String(format: key.localized, arguments: arguments)
    }
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localized(with arguments: CVarArg...) -> String {
        return String(format: self.localized, arguments: arguments)
    }
} 