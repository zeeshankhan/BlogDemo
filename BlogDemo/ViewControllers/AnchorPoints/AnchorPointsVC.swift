//
//  AnchorPointsVC.swift
//  BlogDemo
//
//  Created by Zeeshan Khan on 01/07/2020.
//  Copyright © 2020 Zeeshan. All rights reserved.
//

import UIKit

class AnchorPointsVC: UIViewController {

    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var label: UILabel!
    
    var anchorX: CGFloat = 0
    var anchorY: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        anchorX = myView.layer.anchorPoint.x
        anchorY = myView.layer.anchorPoint.y
        updateValues()
    }

    @IBAction func anchorXAction(_ sender: UISlider) {
        anchorX = CGFloat(sender.value)
        updateValues()
    }
    
    @IBAction func anchorYAction(_ sender: UISlider) {
        anchorY = CGFloat(sender.value)
        updateValues()
    }
    
    private func updateValues() {
        myView.layer.anchorPoint = CGPoint(x: anchorX, y: anchorY)
        let frame = "\(String(format: "%.2f", myView.frame.origin.x)), \(String(format: "%.2f", myView.frame.origin.y)),"
        let anchors = "\(String(format: "%.2f", anchorX)), \(String(format: "%.2f", anchorY)),"
        label.text = "Frame: \(frame)\nAnchors: " + anchors
    }
}
