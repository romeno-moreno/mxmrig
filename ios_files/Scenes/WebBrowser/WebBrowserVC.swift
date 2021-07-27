import Foundation
import WebKit

class WebBrowserVC: UIViewController, WKNavigationDelegate {
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 16.0/255.0, alpha: 1.0)
        webView.isHidden = true
        webView.navigationDelegate = self
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(refresh))
        
        loadPage()
    }
    
    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func refresh() {
        loadPage()
    }
    
    func loadPage() {
        self.webView.isHidden = true
        self.activityView.isHidden = false
        
        if let url = URL(string: "https://moneroocean.stream/?addr=\(ConfigValues.user)") {
            webView.load(URLRequest(url: url))
        }
    }
    
    //MARK: WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("mde = 'd';SwitchMode();", completionHandler: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.webView.isHidden = false
            self.activityView.isHidden = true
        }
    }
}
