import UIKit

extension UIWindow {
    static var keyWindow: UIWindow? {
        if let window = UIApplication.shared.delegate?.window {
            return window
        }
        return UIApplication.shared.windows.first
    }
    
    static var safeAreas: UIEdgeInsets {
        return UIWindow.keyWindow?.safeAreaInsets ?? UIEdgeInsets()
    }
    
    static var rootVC: UIViewController? {
        return RootVC.default
    }
}
