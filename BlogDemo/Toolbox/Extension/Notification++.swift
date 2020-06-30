import Foundation
import UIKit
import RxSwift

extension Notification {
    public var keyboardInfo: (animationDuration: TimeInterval, height: CGFloat)? {
        guard name != UIResponder.keyboardWillHideNotification else {
            return (0.0, 0)
        }

        guard let info = userInfo else { return nil }

        guard let frameValue = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return nil
        }

        let value = frameValue.cgRectValue.height
        guard let animationInfo = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else {
                return (0, value)
        }
        return (animationInfo.doubleValue, value)
    }
}
