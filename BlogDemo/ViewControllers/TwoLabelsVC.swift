import UIKit

/// Content size can be defined in Vertical and Horizontal axis.

/// Hugging priority comes into action when available content size is more than the total size of the content.
///
/// ** The one with higher priority hugs its content more and make the other expand more than its intinsic content.
///
/// Content hugging priority comes in action when there is lesser content to display, than the available size.
/// Content compression resistance priority is exactly opposite. It comes into action when content requires more size than the available, when multilines.
///
/// With this long text, both “Product” and “Apple Macbook Pro Retina 2013” cannot fit together without truncating/diminishing.
/// But the who decides which one should truncate? Its the content compression resistance priority.
///
/// ** So if we set content compression resistance priority of primary label higher than the secondary label, the secondary label would truncate.
/// And when, content compression resistance priority of primary label is set lower than the secondary label, the primary label would truncate.


// https://medium.com/@dineshk1389/content-hugging-and-compression-resistance-in-ios-35a0e8f19118
class TwoLabelsVC: UIViewController {

    lazy var primaryLabel : UILabel = {
        let primaryLabel = UILabel()
        primaryLabel.text = "Apple macbook-pro retina 200 M1 pro ultra"
        primaryLabel.numberOfLines = 0
        primaryLabel.textColor = UIColor.blue
        primaryLabel.backgroundColor = UIColor.lightGray
        primaryLabel.translatesAutoresizingMaskIntoConstraints = false
        return primaryLabel
    }()

    lazy var secondaryLabel : UILabel = {
        let secondaryLabel = UILabel()
        secondaryLabel.text = "Product"
        secondaryLabel.numberOfLines = 1
        secondaryLabel.textColor = UIColor.red
        secondaryLabel.backgroundColor = UIColor.cyan
        secondaryLabel.translatesAutoresizingMaskIntoConstraints = false
        return secondaryLabel
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(primaryLabel)
        view.addSubview(secondaryLabel)

        NSLayoutConstraint.activate([
            primaryLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            primaryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            primaryLabel.trailingAnchor.constraint(equalTo: secondaryLabel.leadingAnchor, constant: -16),

            secondaryLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            secondaryLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),
        ])

//        primaryLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
//        secondaryLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        primaryLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        secondaryLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }

}
