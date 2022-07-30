import UIKit
import Foundation

// Draw a rectangle from two points of a diagonal line

class RectangleFromDiagonal: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.isMultipleTouchEnabled = false
    }

    // MARK: Drawing
    var startPoint: CGPoint?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let first = touches.first else { return }
        let point = first.location(in: self.view)
        startPoint = point
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {}

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let first = touches.first else { return }
        let c = first.location(in: self.view)

        guard let a = startPoint else { return }

        let b = CGPoint(x: a.x, y: c.y)
        let d = CGPoint(x: c.x, y: a.y)

        let subview = UIView(frame: CGRect(origin: a, size: CGSize(width: d.x-a.x, height: b.y - a.y)))
        subview.backgroundColor = .red
        view.addSubview(subview)
    }    
}
