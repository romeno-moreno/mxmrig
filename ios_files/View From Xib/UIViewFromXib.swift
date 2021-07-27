import UIKit

class UIViewFromXib: UIViewWithCustomInit {
    
    var xibClass: AnyClass?
    
    override func customInit() {
        super.customInit()
        loadViewFromNib()
    }
    
    func loadViewFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nibName = NSStringFromClass(xibClass ?? type(of: self)).components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        let objects = nib.instantiate(withOwner: self, options: nil)
        for object in objects {
            if let view = object as? UIView {
                view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.frame = view.bounds
                self.addSubview(view)
            }
        }
    }
}
