import Foundation

class CustomError: LocalizedError {
    var errorMessage = ""
    var localizedDescription: String { return NSLocalizedString(errorMessage, comment: "") }
    
    var errorDescription: String { localizedDescription }
    
    init(_ message: String) {
        self.errorMessage = message
    }
    
    static func error(_ message: String) -> Error? {
        NSError(domain: "com.your", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
    }
    
    static func defaultError() -> Error {
        CustomError.error("Defaut Error")!
    }
}
