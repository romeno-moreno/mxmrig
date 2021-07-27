import UIKit

extension UINavigationController {
    open override var childForHomeIndicatorAutoHidden: UIViewController? {
        return topViewController
    }
}

class CustomNavVC: UINavigationController {
    
    var statusBarHidden = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
            setNeedsUpdateOfHomeIndicatorAutoHidden()
            UIApplication.shared.isStatusBarHidden = statusBarHidden;
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
