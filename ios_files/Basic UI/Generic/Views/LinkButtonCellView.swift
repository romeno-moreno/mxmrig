import UIKit

class LinkButtonCellView: UIViewFromXib, UITextFieldDelegate {
    
    @IBOutlet weak var button: UIButton!
    
    var onClick: (() -> Void)?
    
    var title: String? {
        set {
            self.button.setTitle(newValue, for: .normal)
        }
        get {
            self.button.title(for: .normal)
        }
    }
    
    override func customInit() {
        super.customInit()
        
        button.addTarget(self, action: #selector(click), for: .touchUpInside)
    }

    @objc func click() {
        onClick?()
    }
}
