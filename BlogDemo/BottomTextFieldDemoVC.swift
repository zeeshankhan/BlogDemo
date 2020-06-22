import UIKit
import Foundation
import RxSwift
import RxCocoa

class BottomTextFieldDemoVC: UIViewController {

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = "Bottom TextField"
        view.backgroundColor = .white

        let commentTextField = UITextField()
        commentTextField.placeholder = "Please enter comments..."
        commentTextField.delegate = self
        view.addSubview(commentTextField)

        commentTextField.translatesAutoresizingMaskIntoConstraints = false
        let keyboardHeightConstraint: NSLayoutConstraint = commentTextField
            .bottomAnchor
            .constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)

        NSLayoutConstraint.activate([
            commentTextField.heightAnchor.constraint(equalToConstant: 48),
            commentTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            commentTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            keyboardHeightConstraint,
        ])


        /// Constrain input to the bottom of the view with dependency on keyboard
        let keyboardLayoutGuide = UILayoutGuide()
        view.addLayoutGuide(keyboardLayoutGuide)
        
        NotificationCenter.default.rx
            .keyboardHeight
            .subscribe(onNext: { [unowned self] notification in
                let height = max(0, notification.height - self.view.safeAreaInsets.bottom)
                keyboardHeightConstraint.constant = -height
                UIView.animate(withDuration: notification.animationDuration, animations: { [unowned self] in
                    self.view.layoutIfNeeded()
                })
            })
            .disposed(by: disposeBag)
    }
    
}

public typealias KeyboardHeightNotification = (animationDuration: TimeInterval, height: CGFloat)

extension Notification {
    func keyboardAnimationInfo() -> KeyboardHeightNotification? {
        guard let animationDuration: TimeInterval = (userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else { return nil }

        guard let height = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else {
            return nil
        }

        return (animationDuration, height)
    }
}

extension BottomTextFieldDemoVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
}

// MARK: - Keyboard related extension
extension Reactive where Base: NotificationCenter {
    
    /// Observable for the change of keyboard height that will be always on the main thread
    public var keyboardHeight: Observable<KeyboardHeightNotification> {
        return Observable.merge([
            notification(UIResponder.keyboardWillShowNotification).keyboardAnimationInfo(),
            notification(UIResponder.keyboardWillChangeFrameNotification).keyboardAnimationInfo(),
            notification(UIResponder.keyboardWillHideNotification).keyboardAnimationInfo().map({ ($0.animationDuration, 0.0) })
        ])
            .observeOn(MainScheduler.instance)
    }
}

extension ObservableType where Element == Notification {
    func keyboardAnimationInfo() -> Observable<KeyboardHeightNotification> {
        return map { notification -> KeyboardHeightNotification? in
            guard let animationDuration: TimeInterval = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else { return nil }
            
            guard let height = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else {
                return nil
            }
            
            return (animationDuration, height)
        }
        .filter { $0 != nil }.map { $0! }
    }
}
