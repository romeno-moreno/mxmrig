import Foundation

extension Date {
    var timestamp: Int {
        Int(self.timeIntervalSince1970)
    }
}
