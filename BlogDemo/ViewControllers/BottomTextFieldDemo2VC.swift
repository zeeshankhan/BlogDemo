import UIKit
import Foundation

class BottomTextFieldDemo2VC: UIViewController, UITextFieldDelegate {

    private var keyboardHeightConstraint: NSLayoutConstraint!

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

        /// Constrain input to the bottom of the view with dependency on keyboard
        let keyboardLayoutGuide = UILayoutGuide()
        view.addLayoutGuide(keyboardLayoutGuide)
        keyboardHeightConstraint = keyboardLayoutGuide.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)

        NSLayoutConstraint.activate([
            keyboardLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            keyboardLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            keyboardHeightConstraint,
        ])

        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 48),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor, constant: -16),
        ])
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(handleNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        nc.addObserver(self, selector: #selector(handleNotification), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        nc.addObserver(self, selector: #selector(handleNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
        
    @objc private func handleNotification(notification: Notification) {
        guard let info = notification.keyboardAnimationInfo() else { return }

        let height = max(0, info.height - view.safeAreaInsets.bottom)
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
