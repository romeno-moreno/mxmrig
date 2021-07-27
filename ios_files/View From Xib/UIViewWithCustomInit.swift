import UIKit

class UIViewWithCustomInit: UIView {
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 0))
        customInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    func customInit() {
    }
}
