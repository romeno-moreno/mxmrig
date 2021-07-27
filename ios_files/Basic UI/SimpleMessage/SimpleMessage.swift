import UIKit

class SimpleMessage {
    
    class ButtonAction {
        var title = ""
        var block: (() -> Void)?
        var style = UIAlertAction.Style.default
        
        init(title: String, block: (() -> Void)? = nil, style: UIAlertAction.Style = .default) {
            self.title = title
            self.block = block
            self.style = style
        }
    }
    
    static func showError(vc: UIViewController? = nil, message: String?) {
        self.showMessage(vc: vc, title: "Error", message: message)
    }
    
    static func showMessage(vc: UIViewController? = nil, title: String?, message: String?) {
        self.showMessage(vc: vc, title: title, message: message, buttonActions: [ButtonAction(title: "OK", block: nil, style: .default)])
    }
    
    static func showMessage(vc: UIViewController? = nil, style: UIAlertController.Style = .alert, title: String?, message: String?, buttonActions: [ButtonAction]) {
        var vc = vc
        if vc == nil {
            vc = RootVC.default
        }
        var style = style
        if UIDevice.current.userInterfaceIdiom != .phone {
            style = .alert
        }
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: style)
        for action in buttonActions {
            alertVC.addAction(UIAlertAction(title: action.title, style: action.style, handler: { (_) in
                action.block?()
            }))
        }
        DispatchQueue.main.async {
            vc?.present(alertVC, animated: true, completion: nil)
        }
    }
}
