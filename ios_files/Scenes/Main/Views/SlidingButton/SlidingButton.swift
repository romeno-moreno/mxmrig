import Foundation

class SlidingButton: UIViewFromXib {
    
    static var cornerRadius: CGFloat = 18
    
    var bufferSize: CGFloat = 20
    var slidingButtonWidth: CGFloat = 70
    
    @IBOutlet weak var imageView: UIImageView!
    
    enum Side {
        case left
        case right
    }
    
    var side = Side.left
    var widthConstraint: NSLayoutConstraint!
    
    var onTap: (()->Void)?
    
    init(side: Side, cornerRadius: Bool = true) {
        super.init()
        self.side = side
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor.red
        widthConstraint = NSLayoutConstraint(
            item: self,
            attribute: .width,
            relatedBy: .equal,
            toItem: .none,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 0
        )
        
        NSLayoutConstraint.activate([widthConstraint])
        NSLayoutConstraint.activate([
            NSLayoutConstraint(
                item: imageView as Any,
                attribute: side == .left ? .leading: .trailing,
                relatedBy: .equal,
                toItem: imageView.superview,
                attribute: side == .left ? .leading: .trailing,
                multiplier: 1,
                constant: 0),
        ])
        if cornerRadius {
            self.layer.cornerRadius = Self.cornerRadius
            self.layer.masksToBounds = true
        }
    }
    
    func addSlidingButtom(view: UIView?) {
        NSLayoutConstraint.activate([
            NSLayoutConstraint(
                item: self,
                attribute: side == .left ? .trailing : .leading,
                relatedBy: .equal,
                toItem: view,
                attribute: side == .left ? .leading : .trailing,
                multiplier: 1,
                constant: side == .left ? self.bufferSize : -self.bufferSize),
            NSLayoutConstraint(
                item: self,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: view,
                attribute: .centerY,
                multiplier: 1,
                constant: 0),
        ])
    }
    
    @IBAction func tap(_ sender: Any) {
        onTap?()
    }
    
    func slideOut() {
        self.widthConstraint.constant = slidingButtonWidth + self.bufferSize
    }
    
    func slideIn() {
        self.widthConstraint.constant = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
