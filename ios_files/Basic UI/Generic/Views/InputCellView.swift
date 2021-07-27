import UIKit
import RAGTextField

class InputCellView: UIViewFromXib, UITextFieldDelegate {
    
    @IBOutlet weak var textField: RAGTextField!
    
    var nextCellView: InputCellView?
    var onChange: ((InputCellView?) -> Void)?
    var isEdited = false
    var onTap: (()->Void)?
    
    var title: String? {
        set {
            self.textField.placeholder = newValue
        }
        get {
            self.textField.placeholder
        }
    }
    
    var value: String? {
        get {
            textField.text
        }
        set {
            textField.text = newValue
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
        
        textField.borderStyle = .none
        textField.placeholderMode = .scalesWhenEditing
        textField.placeholderScaleWhenEditing = 0.8
        textField.placeholderFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        textField.placeholderColor = UIColor.lightGray

        let backgroundView = OutlineView()
        backgroundView.lineWidth = 1
        backgroundView.lineColor = UIColor.lightGray
        backgroundView.cornerRadius = 8
        
        textField.returnKeyType = .next
        textField.delegate = self
        textField.autocorrectionType = .no
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func tap() {
        onTap?()
    }
    
    func reloadFrame() {
        self.layoutIfNeeded()
        self.frame.size.height = textField.frame.maxY + textField.y
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextCellView = nextCellView {
            nextCellView.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func textChanged(_ sender: Any) {
        isEdited = true
        onChange?(self)
    }
}
