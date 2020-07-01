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
        }
        return view
    }()

    private var toastWindow: UIWindow?
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
        }, completion: nil)
    }

    public func hide() {
        guard let window = toastWindow else { return }

        UIView.animate(withDuration: Constants.animationDuration, delay: 0, options: .curveEaseIn, animations: {
            window.layer.anchorPoint.y = Constants.hiddenAnchorY
        }, completion: { _ in
            self.toastWindow = nil
        })
    }

    private func setupUI(text: String, backgroundColor: UIColor, textColor: UIColor) -> UIWindow {
        toastLabel.text = text
        toastLabel.textColor = textColor
        toastLabel.backgroundColor = backgroundColor
        toastView.backgroundColor = backgroundColor

        let window = UIWindow()
        window.backgroundColor = backgroundColor
        window.isHidden = false

        window.addSubview(toastView)
        constrain(window, toastView) { window, view in
            view.edges == window.edges
        }

        let viewHeight = height(for: text) + window.safeAreaInsets.top + Constants.textBottomPadding
        window.frame = .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: viewHeight)
        return window
    }

    private func height(for text: String) -> CGFloat {
        let width = UIScreen.main.bounds.width - (Constants.textSidePadding * 2)
        let boundingBox = text.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude),
                                            options: .usesLineFragmentOrigin,
                                            attributes: [.font: Constants.font],
                                            context: nil)
        return ceil(boundingBox.height)
    }
}
