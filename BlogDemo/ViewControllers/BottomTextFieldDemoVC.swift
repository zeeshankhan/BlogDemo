import UIKit
import Foundation

class BottomTextFieldDemoVC: UIViewController, UITextFieldDelegate {

    private var keyboardHeightConstraint: NSLayoutConstraint!
    private let bottomPadding: CGFloat = 20

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Bottom TextField"
        view.backgroundColor = .white

        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "Please enter comments..."
        textField.delegate = self
        view.addSubview(textField)

        textField.translatesAutoresizingMaskIntoConstraints = false
        keyboardHeightConstraint = textField
            .bottomAnchor
            .constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -bottomPadding)

        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 48),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            keyboardHeightConstraint,
        ])

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(handleNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        nc.addObserver(self, selector: #selector(handleNotification), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        nc.addObserver(self, selector: #selector(handleNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
        
    @objc private func handleNotification(notification: Notification) {
        guard let info = notification.keyboardInfo else { return }

        let height = max(bottomPadding, info.height - view.safeAreaInsets.bottom + bottomPadding)
        keyboardHeightConstraint.constant = -height
        UIView.animate(withDuration: info.animationDuration) {
            self.view.layoutIfNeeded()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
}
