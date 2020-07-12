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
    private var cornerRadius = CGFloat(0.0)

    override func viewDidLoad() {
        super.viewDidLoad()

        myView.layer.shadowPath = nil
        myView.layer.cornerRadius = cornerRadius
        myView.layer.shadowColor = UIColor.black.cgColor
        myView.layer.shadowOpacity = 1
        myView.layer.shadowOffset = offset
        myView.layer.shadowRadius = 6
        myView.layer.masksToBounds = false
    }

    @IBAction func radiusAction(_ sender: UISlider) {
        myView.layer.shadowRadius = CGFloat(sender.value)
        radius.text = "ShadowRadius: \(Int(sender.value))"
    }
    
    @IBAction func offsetHeightAction(_ sender: UISlider) {
        offset.height = CGFloat(sender.value)
        offsetHeight.text = "OffsetH: \(Int(sender.value))"
        myView.layer.shadowOffset = offset
    }

    @IBAction func offsetWidthAction(_ sender: UISlider) {
        offset.width = CGFloat(sender.value)
        offsetWidth.text = "OffsetW: \(Int(sender.value))"
        myView.layer.shadowOffset = offset
    }

    @IBAction func opacityAction(_ sender: UISlider) {
        myView.layer.shadowOpacity = sender.value
        opacity.text = "Opacity: \(String(format: "%.1f", sender.value))"
    }

    @IBAction func cornerRadiusAction(_ sender: UISlider) {
        cornerRadius = CGFloat(sender.value)
        myView.layer.cornerRadius = cornerRadius
        corner.text = "CornerRadius: \(String(format: "%.1f", cornerRadius))"
    }

    @IBAction func shadowPathCRadiusAction(_ sender: UISlider) {
        myView.layer.shadowPath = sender.value > 0 ? UIBezierPath(roundedRect: myView.bounds, cornerRadius: CGFloat(sender.value)).cgPath : nil
        shadowPathCRadius.text = "ShadPathCornerR: \(String(format: "%.1f", sender.value))"
    }

}
