//
//  ShadowPlayVC.swift
//  BlogDemo
//
//  Created by Zeeshan Khan on 03/07/2020.
//  Copyright © 2020 Zeeshan. All rights reserved.
//

import UIKit

class ShadowPlayVC: UIViewController {

    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var radius: UILabel!
    @IBOutlet weak var offsetHeight: UILabel!
    @IBOutlet weak var offsetWidth: UILabel!
    @IBOutlet weak var opacity: UILabel!
    @IBOutlet weak var corner: UILabel!
    @IBOutlet weak var shadowPathCRadius: UILabel!
    private var offset = CGSize(width: 0, height: 6.0)

    override func viewDidLoad() {
        super.viewDidLoad()

        myView.layer.shadowPath = nil
        myView.layer.cornerRadius = 15.0
        myView.layer.shadowColor = UIColor.black.cgColor
        myView.layer.shadowOpacity = 1
        myView.layer.shadowOffset = offset
        myView.layer.shadowRadius = 6
        myView.layer.masksToBounds = false
    }

    @IBAction func radiusAction(_ sender: UISlider) {
        myView.layer.shadowRadius = CGFloat(sender.value)
        radius.text = "Radius [0-50]: \(Int(sender.value))"
    }
    
    @IBAction func offsetHeightAction(_ sender: UISlider) {
        offset.height = CGFloat(sender.value)
        offsetHeight.text = "OffsetH [0-10]: \(Int(sender.value))"
        myView.layer.shadowOffset = offset
    }

    @IBAction func offsetWidthAction(_ sender: UISlider) {
        offset.width = CGFloat(sender.value)
        offsetWidth.text = "OffsetW [0-100]: \(Int(sender.value))"
        myView.layer.shadowOffset = offset
    }

    @IBAction func opacityAction(_ sender: UISlider) {
        myView.layer.shadowOpacity = sender.value
        opacity.text = "Opacity[0-1]: \(String(format: "%.1f", sender.value))"
    }

    @IBAction func cornerRadiusAction(_ sender: UISlider) {
        myView.layer.cornerRadius = CGFloat(sender.value)
        corner.text = "CornerRadius: \(String(format: "%.1f", sender.value))"
    }

    @IBAction func shadowPathCRadiusAction(_ sender: UISlider) {
        myView.layer.shadowPath = sender.value > 0 ? UIBezierPath(roundedRect: myView.bounds, cornerRadius: CGFloat(sender.value)).cgPath : nil
        shadowPathCRadius.text = "ShadowPathCornerR: \(String(format: "%.1f", sender.value))"
    }
}
