import UIKit
import WebKit
import AVFoundation

extension String {
    func htmlAttributedString() -> NSAttributedString? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }

        return try? NSAttributedString(
            data: data,
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
        )
    }
}

var slidingButtonWidth: CGFloat = 70

class MainVC: RootVC, LoggerBridgeDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var centerBarButton: UIButton!
    
    var backlightButton = SlidingButton(side: .left)
    var settingsButton = SlidingButton(side: .right)
    var informationButton = SlidingButton(side: .right, cornerRadius: false)
    var monerooceanButton = SlidingButton(side: .right)
    
    var isMiningTapped = false
    
    let backlightView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.isUserInteractionEnabled = true
        return view
    }()
    
    var text = NSMutableAttributedString()
    var isPaused = false
    
    var lastKnownBrightness: CGFloat = 0.0
    var lastKnownDonateValue = ConfigValues.donation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ConfigValues.isNewInstallation == true {
            ConfigValues.eraseAll()
            ConfigValues.isNewInstallation = false
        }
        
        RootVC.default = self
        
        self.backlightButton.imageView.image = UIImage(named: "bulb")
        self.backlightButton.onTap = turnOffBackight
        
        self.settingsButton.imageView.image = UIImage(named: "gear")
        self.settingsButton.onTap = showSettings
        
        self.informationButton.imageView.image = UIImage(named: "info")
        self.informationButton.onTap = showInformation
        self.informationButton.slidingButtonWidth = 60
        
        self.monerooceanButton.imageView.image = UIImage(named: "globe")
        self.monerooceanButton.onTap = showMoneroocean
        self.monerooceanButton.slidingButtonWidth = 60
        
        self.textView.textContainerInset.bottom = centerBarButton.height + 20

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(turnOnBackight))
        backlightView.addGestureRecognizer(recognizer)

        LoggerBridge.shared().delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(brightnessDidChange), name: UIScreen.brightnessDidChangeNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.addSubview(settingsButton)
        self.view.bringSubviewToFront(centerBarButton.superview!)
        
        settingsButton.addSlidingButtom(view: centerBarButton.superview)
        self.view.layoutIfNeeded()
        
        settingsButton.slideOut()
        UIView.animate(withDuration: 0.6) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !XmrigManager.shared().isMining() {
            welcomeMessage()
        }
    }
    
    func turnOffBackight() {
        lastKnownBrightness = UIScreen.main.brightness
        UIScreen.main.brightness = 0.0
        if let window = self.view.window {
            backlightView.frame = window.frame
            backlightView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            window.addSubview(backlightView)
            (self.navigationController as? CustomNavVC)?.statusBarHidden = true
        }
    }
    
    func showSettings() {
        let settingsVC = SettingsVC()
        settingsVC.onDismiss = { [weak self] in
            guard let self = self else {
                return
            }
            if self.updatesLoaded && self.lastKnownDonateValue != ConfigValues.donation {
                self.lastKnownDonateValue = ConfigValues.donation
                self.typeMessage(message: WelcomeMessageHelper.loadMessage())
            }
        }
        let navVC = CustomNavVC(rootViewController: settingsVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
    func showInformation() {
        SimpleMessage.showMessage(style: .actionSheet, title: "Show Information", message: nil, buttonActions: [
            SimpleMessage.ButtonAction(title: "Hashrate", block: {
                XmrigManager.shared().showHashrate()
            }, style: .default),
            SimpleMessage.ButtonAction(title: "Results", block: {
                XmrigManager.shared().showResults()
            }, style: .default),
            SimpleMessage.ButtonAction(title: "Connection", block: {
                XmrigManager.shared().showConnection()
            }, style: .default),
            SimpleMessage.ButtonAction(title: "Cancel", block: {}, style: .cancel)
        ])
    }
    
    func showMoneroocean() {
        let navVC = CustomNavVC(rootViewController: WebBrowserVC())
        self.present(navVC, animated: true, completion: nil)
    }
    
    // MARK: IBActions
    
    @IBAction func centerButtonTap(_ sender: Any) {
        if XmrigManager.shared().isMining() {
            if (isPaused) {
                XmrigManager.shared().resume()
                isPaused = false
            } else {
                XmrigManager.shared().pause()
                isPaused = true
            }
            self.centerBarButton.setImage(UIImage(named: isPaused ? "play" : "pause"), for: .normal)
        } else {
            isMiningTapped = true
            self.text = NSMutableAttributedString()
            self.textView.attributedText = text
            
            settingsButton.slideIn()
            
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            } completion: { _ in
                self.showButtonsDuringMining()
            }
        }
    }
    
    func showButtonsDuringMining() {
        self.view.addSubview(self.backlightButton)
        self.view.addSubview(self.monerooceanButton)
        self.view.addSubview(self.informationButton)
        self.view.bringSubviewToFront(self.centerBarButton.superview!)
        
        self.backlightButton.addSlidingButtom(view: self.centerBarButton.superview)
        self.informationButton.addSlidingButtom(view: self.centerBarButton.superview)
        self.monerooceanButton.addSlidingButtom(view: self.informationButton)
        self.view.layoutIfNeeded()
        
        self.backlightButton.slideOut()
        self.informationButton.slideOut()
        self.monerooceanButton.slideOut()
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.centerBarButton.setImage(UIImage(named: "pause"), for: .normal)
            DispatchQueue.global().async {
                XmrigManager.shared().startMining()
            }
        }
    }
    
    var updatesLoaded = false
    func welcomeMessage() {
        self.text = NSMutableAttributedString()
        self.textView.attributedText = text
        self.typeMessage(message: WelcomeMessageHelper.loadingMessage())
        
        WelcomeMessageHelper.logNewLaunchAndGetMessage { message in
            self.updatesLoaded = true
            self.currentlyTypingMessage = UUID().uuidString
            DispatchQueue.main.async {
                self.typeMessage(message: WelcomeMessageHelper.loadMessage())
            }
        }
    }
    
    var currentlyTypingMessage = ""
    func typeMessage(message: String) {
        if (isMiningTapped) {
            return
        }
        self.text = NSMutableAttributedString()
        self.textView.attributedText = self.text
        
        self.currentlyTypingMessage = UUID().uuidString
        
        self.typingMessage(
            text: message,
            originalMessage: self.currentlyTypingMessage,
            completion: {})
    }
    
    
    func log(_ string: String!) {
        DispatchQueue.main.async {
            let length = self.text.length
            let limit = 30000
            if length > limit {
                self.text = NSMutableAttributedString()
            }
            if let newLine = string.htmlAttributedString() {
                self.text.append(newLine)
            }
            //self.webView.loadHTMLString(string, baseURL: nil)
            self.textView.attributedText = self.text
            if self.textView.text.count > 0 {
                let location = self.textView.text.count - 1
                let bottom = NSMakeRange(location, 1)
                self.textView.scrollRangeToVisible(bottom)
            }
        }
    }
        
    @objc func brightnessDidChange() {
        if backlightView.superview != nil {
            UIScreen.main.brightness = 0.0
        }
    }
    
    @objc func turnOnBackight() {
        backlightView.removeFromSuperview()
        UIScreen.main.brightness = lastKnownBrightness
        (self.navigationController as? CustomNavVC)?.statusBarHidden = false
    }
    
    override var prefersStatusBarHidden: Bool
    {
         return (self.navigationController as? CustomNavVC)?.statusBarHidden == true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return (self.navigationController as? CustomNavVC)?.statusBarHidden == true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
