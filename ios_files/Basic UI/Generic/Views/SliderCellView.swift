import UIKit

class SliderCellView: UIViewFromXib, UITextFieldDelegate {
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    var nextCellView: InputCellView?
    var onChange: ((_ value: Double) -> Void)?
    var isEdited = false
    
    var title: String? {
        set {
            self.titleLabel.text = newValue
        }
        get {
            self.titleLabel.text
        }
    }
    
    var value: Double {
        get {
            Double(slider.value)
        }
        set {
            slider.value = Float(newValue)
            onChange?(value)
        }
    }
    
    init(title: String) {
        super.init()
        self.title = title
    }
    
    override init() {
        super.init()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func customInit() {
        super.customInit()
        
        slider.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
    }
    
    @objc func valueChanged() {
        onChange?(value)
    }

}
