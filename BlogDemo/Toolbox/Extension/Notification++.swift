import Foundation
import UIKit
import RxSwift

extension Notification {
    public func keyboardAnimationInfo() -> (animationDuration: TimeInterval, height: CGFloat)? {
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
