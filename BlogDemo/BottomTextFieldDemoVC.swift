import UIKit
import Foundation

class BottomTextFieldDemoVC: UIViewController {

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

        /// Constrain input to the bottom of the view with dependency on keyboard
        let keyboardLayoutGuide = UILayoutGuide()
        view.addLayoutGuide(keyboardLayoutGuide)
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(handleNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        nc.addObserver(self, selector: #selector(handleNotification), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        nc.addObserver(self, selector: #selector(handleNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
        
    @objc private func handleNotification(notification: Notification) {
        guard let info = notification.keyboardAnimationInfo() else { return }

        let height = max(bottomPadding, info.height - view.safeAreaInsets.bottom + bottomPadding)
        keyboardHeightConstraint.constant = -height
        UIView.animate(withDuration: info.animationDuration) {
            self.view.layoutIfNeeded()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension BottomTextFieldDemoVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
}

extension Notification {
    func keyboardAnimationInfo() -> (animationDuration: TimeInterval, height: CGFloat)? {
        guard name != UIResponder.keyboardWillHideNotification else {
            return (0.0, 0)
        }

        guard let animationDuration: TimeInterval = (userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else { return nil }

        guard let height = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else {
            return nil
        }

        return (animationDuration, height)
    }
}
