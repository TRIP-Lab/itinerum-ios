
import UIKit


class HeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var arrowLabel: UILabel?
    var headerTapBlock:(()->Void)?
    
    var item: Info? {
        didSet {
            guard let item = item else {
                return
            }
            
            titleLabel?.text = item.title
            setCollapsed(collapsed: item.isCollapsed)
        }
    }
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapHeader)))
    }
    
    @objc private func didTapHeader() {
        if let block = self.headerTapBlock {
            DispatchQueue.main.async {
                block()
            }
        }
    }

    func setCollapsed(collapsed: Bool) {
        arrowLabel?.rotate(collapsed ? 0.0 : .pi)
    }
}


extension UIView {
    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        
        animation.toValue = toValue
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        self.layer.add(animation, forKey: nil)
    }
}
