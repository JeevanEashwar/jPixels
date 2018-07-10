//
//  CropView.swift
//  jPixels
//
//  Created by Jeevan on 06/07/18.
//  Copyright © 2018 Jeevan. All rights reserved.
//

import UIKit
protocol CropIndicatorDelegate {
    func didPinch(sender: UIPinchGestureRecognizer)
    func handleEdgeNCornerPan(recognizer:UIPanGestureRecognizer)
}
class CropView: UIView {
    var delegate:CropIndicatorDelegate?
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    @IBAction func didPinch(sender: UIPinchGestureRecognizer) {
        delegate?.didPinch(sender: sender)
    }
    @IBAction func handleEdgeNCornerPan(recognizer:UIPanGestureRecognizer) {
        delegate?.handleEdgeNCornerPan(recognizer: recognizer)
    }
}
