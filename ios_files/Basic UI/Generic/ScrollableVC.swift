import UIKit

class ScrollableVC: UIViewController {

    var cells: [UIView] = []
    var scrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        setupScrollView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadLayout()
    }
    
    func setupScrollView() {
        scrollView.frame = self.view.bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        self.view.addSubview(scrollView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if view.width != scrollView.contentSize.width {
            scrollView.contentSize.width = view.width
        }
    }
    
    func reloadLayout() {
        var currentY = CGFloat()
        for cell in cells {
            cell.removeFromSuperview()
            cell.frame = CGRect(x: 0, y: currentY, width: view.width, height: cell.height)
            cell.autoresizingMask = [.flexibleWidth]
            scrollView.addSubview(cell)
            currentY += cell.height
        }
        scrollView.contentSize = CGSize(width: self.view.width, height: currentY)
    }
}
