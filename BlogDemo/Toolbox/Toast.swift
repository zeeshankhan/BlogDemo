import UIKit
import Cartography

private enum Constants {
    static let animationDuration: TimeInterval = 0.3
    static let font: UIFont = .systemFont(ofSize: 13, weight: .medium)
    static let textSidePadding: CGFloat = 8
    static let textTopPadding: CGFloat = 4 /// Used when status bar shows location blue var
    static let textBottomPadding: CGFloat = 8
    static let defaultAnchorY: CGFloat = 0.5
    static let hiddenAnchorY: CGFloat = 1.5
}

public final class Toast {

    /// We need to have view controller as root of toast window as
    /// if Toast is presented before main application window becomes active
    private lazy var toastVC = ToastViewController()
    private var toastWindow: ToastWindow?
    static public let shared = Toast()
    private init() {}

    public func show(text: String, backgroundColor: UIColor = .red, textColor: UIColor = .white) {

        /// Hide old window
        toastWindow = nil

        /// Setup new window
        setupUI(text: text, backgroundColor: backgroundColor, textColor: textColor)

        /// Show the toast by animating window's anchor point
        toastWindow?.layer.anchorPoint.y = Constants.hiddenAnchorY
        UIView.animate(withDuration: Constants.animationDuration, delay: 0, options: .curveEaseOut, animations: {
            self.toastWindow?.layer.anchorPoint.y = Constants.defaultAnchorY
        })
    }

    public func hide() {
        /// return if window is already nil
        guard let window = toastWindow else { return }

        /// Hide the toast by animating window's anchor point and then set nil to window to completely remove it
        UIView.animate(withDuration: Constants.animationDuration, delay: 0, options: .curveEaseIn, animations: {
            window.layer.anchorPoint.y = Constants.hiddenAnchorY
        }, completion: { _ in
            self.toastWindow = nil
        })
    }

    private func setupUI(text: String, backgroundColor: UIColor, textColor: UIColor) {
        toastVC.setText(text, backgroundColor: backgroundColor, textColor: textColor)
        
        let window = ToastWindow()
        window.backgroundColor = .clear
        window.isHidden = false
        window.rootViewController = toastVC
        toastWindow = window

        /// If toast is presented before application's main window appears,
        /// we need to set toast window level one up to make sure it overlaps the app window
        window.windowLevel = .init(UIWindow.Level.normal.rawValue + 1)
    }
}

private class ToastWindow: UIWindow {
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        guard view != self else { return nil }
        return view
    }
}

private class ToastViewController: UIViewController {

    private lazy var toastLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = Constants.font
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
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        view.layer.shadowRadius = 5
        view.layer.masksToBounds = false
        return view
    }()

    open override func loadView() {
        view = OverlayView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(toastView)
        constrain(view, toastView) { container, toast in
            toast.top == container.top
            toast.leading == container.leading
            toast.trailing == container.trailing
        }
    }

    fileprivate func setText(_ text: String, backgroundColor: UIColor, textColor: UIColor) {
        toastLabel.text = text
        toastLabel.textColor = textColor
        toastLabel.backgroundColor = backgroundColor
        toastView.backgroundColor = backgroundColor
    }
}

private class OverlayView: UIView {
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        guard view != self else { return nil }
        return view
    }
}
