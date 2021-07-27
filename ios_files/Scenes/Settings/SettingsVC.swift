import Foundation

class SettingsVC: ScrollableVC {
    
    let urlCell = InputCellView()
    let userCell = InputCellView()
    let passwordCell = InputCellView()
    let donationLevelCell = SliderCellView()
    
    let wipeDataCell = LinkButtonCellView()
    
    var onDismiss: (()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.backgroundColor = UIColor.black
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close))
        self.view.backgroundColor = UIColor(white: 4.0/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        
        urlCell.title = "Pool URL"
        urlCell.value = ConfigValues.url
        urlCell.textField.textColor = UIColor.white
        urlCell.textField.isEnabled = false
        urlCell.textField.isUserInteractionEnabled = false
        urlCell.onTap = {
            SimpleMessage.showMessage(
                vc: self,
                title: "",
                message: "Changing pool url is not allowed in monerooean edition of mXMRig.\nPlease, download the regular version",
                buttonActions: [
                    SimpleMessage.ButtonAction(title: "Download", block: {
                        let url = "https://www.mxmrig.com"
                        if let url = URL(string: url) {
                            UIApplication.shared.open(url)
                        }
                    }, style: .default),
                    SimpleMessage.ButtonAction(title: "Cancel", style: .cancel)
                ])
        }
        
        userCell.title = "User (Wallet Address)"
        userCell.value = ConfigValues.user
        userCell.textField.textColor = UIColor.white
        userCell.onChange = {[weak self] _ in
            if let user = self?.userCell.value {
                ConfigValues.user = user
            }
        }
        
        passwordCell.title = "Password (Device Name)"
        passwordCell.value = ConfigValues.password
        passwordCell.textField.textColor = UIColor.white
        passwordCell.onChange = {[weak self] _ in
            if let password = self?.passwordCell.value {
                ConfigValues.password = password
            }
        }
        
        wipeDataCell.title = "Erase All Data"
        wipeDataCell.button.setTitleColor(Theme.redColor, for: .normal)
        wipeDataCell.onClick = eraseAllData
        
        donationLevelCell.title = "Donation"
        donationLevelCell.slider.minimumValue = Float(5) / 100.0
        donationLevelCell.onChange = { [weak self] newValue in
            let newValueInt = Int((newValue * 100).rounded())
            self?.donationLevelCell.valueLabel.text = "\(newValueInt) %"
            ConfigValues.donation = newValueInt
        }
        donationLevelCell.value = Double(ConfigValues.donation) / 100
        
        self.cells = [
            urlCell,
            SeparatorCell(),
            userCell,
            SeparatorCell(),
            passwordCell,
            SeparatorCell(),
            donationLevelCell,
            SeparatorCell(),
            wipeDataCell
        ]
        
        setTheme()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        onDismiss?()
    }
    
    func setTheme() {
        for cell in cells {
            cell.backgroundColor = self.view.backgroundColor
        }
    }
    
    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func eraseAllData() {
        ConfigManager.clearConfig()
        ConfigValues.eraseAll()
        self.dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
