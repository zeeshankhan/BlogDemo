import UIKit
import Cartography

public final class Toast {

    private enum Constants {
        static let animationDuration: TimeInterval = 0.3
        static let font: UIFont = .systemFont(ofSize: 13, weight: .medium)
        static let textSidePadding: CGFloat = 8
        static let textBottomPadding: CGFloat = 8
        static let defaultAnchorY: CGFloat = 0.5
        static let hiddenAnchorY: CGFloat = 1.5
    }

    private lazy var toastLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = Constants.font
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()

    private lazy var toastView: UIView = {
        let view = UIView()
        view.addSubview(toastLabel)
        constrain(view, toastLabel) { view, label in
            label.leading == view.leading + Constants.textSidePadding
            label.trailing == view.trailing - Constants.textSidePadding
            label.bottom == view.bottom - Constants.textBottomPadding
            label.top == view.safeAreaLayoutGuide.top
        }
        return view
    }()

    private var toastWindow: ToastWindow?
    static public let shared = Toast()
    private init() {}

    public func show(text: String, backgroundColor: UIColor = .red, textColor: UIColor = .white) {

        /// Hide old
        toastWindow = nil

        /// Setup new
        let window = setupUI(text: text, backgroundColor: backgroundColor, textColor: textColor)
        toastWindow = window

        /// Show new
        window.layer.anchorPoint.y = Constants.hiddenAnchorY
        UIView.animate(withDuration: Constants.animationDuration, delay: 0, options: .curveEaseOut, animations: {
            window.layer.anchorPoint.y = Constants.defaultAnchorY
        })
    }

    public func hide() {
        guard let window = toastWindow else { return }

        UIView.animate(withDuration: Constants.animationDuration, delay: 0, options: .curveEaseIn, animations: {
            window.layer.anchorPoint.y = Constants.hiddenAnchorY
        }, completion: { _ in
            self.toastWindow = nil
        })
    }

    private func setupUI(text: String, backgroundColor: UIColor, textColor: UIColor) -> ToastWindow {
        toastLabel.text = text
        toastLabel.textColor = textColor
        toastLabel.backgroundColor = backgroundColor
        toastView.backgroundColor = backgroundColor

        let window = ToastWindow()
        window.backgroundColor = .clear
        window.isHidden = false
        window.addSubview(toastView)
        constrain(window, toastView) { window, view in
            view.top == window.top
            view.leading == window.leading
            view.trailing == window.trailing
        }

        return window
    }
}

private class ToastWindow: UIWindow {
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        guard view != self else { return nil }
        return view
    }
}
