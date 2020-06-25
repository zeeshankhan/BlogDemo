import UIKit

public final class Toast {

    private enum Constants {
        static let animationDuration: TimeInterval = 0.3
        static let font: UIFont = .systemFont(ofSize: 13, weight: .medium)
        static let textSidePadding: CGFloat = 8
        static let textBottomPadding: CGFloat = 8
    }

    static public let shared = Toast()
    private init() {}

    private var toastWindow: UIWindow?

    public func show(text: String, backgroundColor: UIColor = .red, textColor: UIColor = .white) {
        
        /// Hide old
        toastWindow = nil

        /// Setup new
        let window = setupUI(text: text, backgroundColor: backgroundColor, textColor: textColor)
        toastWindow = window

        /// Show new
        window.transform = CGAffineTransform(translationX: 0, y: -window.frame.height)
        UIView.animate(withDuration: Constants.animationDuration, delay: 0, options: .curveEaseOut, animations: {
            window.transform = .identity
        }, completion: nil)
    }

    public func hide() {

        guard let window = toastWindow else { return }

        UIView.animate(withDuration: Constants.animationDuration, delay: 0, options: .curveEaseIn, animations: {
            window.transform = CGAffineTransform(translationX: 0, y: -window.frame.height)
        }, completion: { _ in
            self.toastWindow?.transform = .identity
            self.toastWindow = nil
        })
    }
    
    private func setupUI(text: String, backgroundColor: UIColor, textColor: UIColor) -> UIWindow {
        let view = UIView()
        view.backgroundColor = backgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.numberOfLines = 0
        label.backgroundColor = backgroundColor
        label.textColor = textColor
        label.font = Constants.font
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.textSidePadding),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.textSidePadding),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -Constants.textBottomPadding)
        ])
        
        let window = UIWindow()
        window.backgroundColor = backgroundColor
        window.isHidden = false
        
        window.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: window.topAnchor),
            view.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            view.bottomAnchor.constraint(equalTo: window.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: window.trailingAnchor)
        ])
        
        let viewHeight = height(for: text) + window.safeAreaInsets.top + Constants.textBottomPadding
        window.frame = .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: viewHeight)

        return window
    }

    private func height(for text: String) -> CGFloat {
        let width = UIScreen.main.bounds.width - (Constants.textSidePadding * 2)
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [.font: Constants.font],
                                            context: nil)
        let textHeight = ceil(boundingBox.height)
        return textHeight
    }
}
