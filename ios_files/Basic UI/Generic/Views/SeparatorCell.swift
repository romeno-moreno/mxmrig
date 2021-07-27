import UIKit

class SeparatorCell: UIViewFromXib {
    override func customInit() {
        super.customInit()
        self.subviews.first?.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
    }
}
