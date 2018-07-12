//
//  DoodleViewController.swift
//  jPixels
//
//  Created by Jeevan on 10/07/18.
//  Copyright © 2018 Jeevan. All rights reserved.
//

import UIKit
protocol DoodleImageDelegate {
    func imageDoodled(_ image:UIImage?)
}
class DoodleViewController: UIViewController {
    
    //IBOutlets
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var scribbleSegmentControl: UISegmentedControl!
    @IBOutlet weak var editControlsView: UIView!
    @IBOutlet weak var allColorsView: UIView!
    @IBOutlet weak var widthsStack: UIStackView!
    @IBOutlet weak var editColorButton: UIButton!
    //Var & Constants
    var delegate:DoodleImageDelegate?
    var imageToBeDoodled:UIImage?
    
    var lineColor:UIColor = UIColor.white
    var lineWidth : CGFloat = 4
    var previousLocation : CGPoint = CGPoint()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.imageView.image = imageToBeDoodled
        
        let scribbleGesture = UIPanGestureRecognizer(target: self, action: #selector(handleScribblePan(recognizer:)))
        imageView.addGestureRecognizer(scribbleGesture)
        self.initAllColorsView()
    }
    private func initAllColorsView(){
        let gradient = CAGradientLayer()
        gradient.frame = allColorsView.bounds
        gradient.colors = appDelegate.getColorFromArray()
        gradient.startPoint = CGPoint(x:0.0, y:0.5)
        gradient.endPoint = CGPoint(x:1.0, y:0.5)
        gradient.locations = [0.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9]
        allColorsView.layer.insertSublayer(gradient, at: 0)
        
        let colorsPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleColorsPan(recognizer:)))
        let colorsTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleColorsTap(recognizer:)))
        allColorsView.addGestureRecognizer(colorsPanGesture)
        allColorsView.addGestureRecognizer(colorsTapGesture)
        
    }
    @objc func handleScribblePan(recognizer:UIPanGestureRecognizer) {
        if scribbleSegmentControl.selectedSegmentIndex == 0 {
            imageView.drawCircleOverImage(recognizer: recognizer,with: lineWidth, lineColor:lineColor)
        }else if scribbleSegmentControl.selectedSegmentIndex == 1{
            imageView.drawRectangleOverImage(recognizer: recognizer,with: lineWidth, lineColor:lineColor)
        }else if scribbleSegmentControl.selectedSegmentIndex == 2{
            imageView.drawLineOverImage(recognizer: recognizer,with: lineWidth, lineColor:lineColor)
        }else {
            imageView.drawFreeHand(recognizer: recognizer, previousLocation: previousLocation, with: lineWidth, lineColor: lineColor)
            previousLocation = recognizer.location(in: imageView)
        }
        
    }
    @objc func handleColorsPan(recognizer:UIPanGestureRecognizer) {
        guard let cView = recognizer.view else {return}
        let location = recognizer.location(in: cView)
        let indexOfColor = Int(floor(location.x / cView.frame.width * 10))
        let colorsArray = appDelegate.getColorFromArray()
        if indexOfColor > 0 && indexOfColor < colorsArray.count {
            lineColor = UIColor(cgColor: colorsArray[indexOfColor])
            editColorButton.backgroundColor = lineColor
        }
    }
    @objc func handleColorsTap(recognizer:UITapGestureRecognizer) {
        guard let cView = recognizer.view else {return}
        let location = recognizer.location(in: cView)
        let indexOfColor = Int(floor(location.x / cView.frame.width * 10))
        let colorsArray = appDelegate.getColorFromArray()
        if indexOfColor > 0 && indexOfColor < colorsArray.count {
            lineColor = UIColor(cgColor: colorsArray[indexOfColor])
            editColorButton.backgroundColor = lineColor
        }
    }
    @IBAction func cancel(_ sender : Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func done(_ sender : Any) {
        //remove close buttons of Doodle subViews
        for subView in imageView.subviews {
            if let closeButtonView = subView.subviews.last {
                closeButtonView.removeFromSuperview()
            }
        }
        //take screenshot and update source VC
        let doodledImage = imageView.snapshot(of: imageView.frame)
        delegate?.imageDoodled(doodledImage)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func chooseColorClicked(_ sender: Any) {
        allColorsView.isHidden = !allColorsView.isHidden
    }
    @IBAction func chooseLineWidthClicked(_ sender: Any) {
        widthsStack.isHidden = !widthsStack.isHidden
    }
    @IBAction func widthButtonClicked(_ sender: UIButton) {
        widthsStack.isHidden = true
        lineWidth = CGFloat(sender.tag * 2)
    }
}
//Doodle methods
extension UIImageView {
    func drawLineOverImage(recognizer:UIPanGestureRecognizer,with lineWidth:CGFloat, lineColor : UIColor) {
        let translation = recognizer.translation(in: self)
        var beganOrigin = CGPoint(x: 0, y: 0)
        if recognizer.state == .changed {
            guard let sublayer = self.layer.sublayers?.last else {return}
            sublayer.removeFromSuperlayer()
            guard let dummySubView = self.subviews.last else {return}
            beganOrigin = dummySubView.frame.origin
            dummySubView.removeFromSuperview()
        }
        if recognizer.state == .began || recognizer.state == .changed {
            var startPoint = recognizer.location(in: self)
            if recognizer.state == .began {
                beganOrigin = startPoint
                let dummyView = UIView(frame: CGRect(x: startPoint.x, y: startPoint.y, width: 0, height: 0))
                self.addSubview(dummyView)
            }else if recognizer.state == .changed {
                startPoint = beganOrigin
                let dummyView = UIView(frame: CGRect(x: beganOrigin.x, y: beganOrigin.y, width: 0, height: 0))
                self.addSubview(dummyView)
            }
            let endPoint = CGPoint(x: startPoint.x + translation.x, y: startPoint.y + translation.y)
            //design the path
            let linePath = UIBezierPath()
            linePath.move(to: startPoint)
            linePath.addLine(to: endPoint)
            //design path in layer
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = linePath.cgPath
            shapeLayer.strokeColor = lineColor.cgColor
            shapeLayer.lineWidth = lineWidth
            self.layer.addSublayer(shapeLayer)
            
        }
        
    }
    
    func drawCircleOverImage(recognizer:UIPanGestureRecognizer,with lineWidth:CGFloat, lineColor : UIColor) {
        var origin : CGPoint = CGPoint(x: 0, y: 0)
        let translation = recognizer.translation(in: self)
        let width = abs(translation.x)
        let height = abs(translation.y)
        if recognizer.state == .began {
            let originX = translation.x >= 0 ?
                recognizer.location(in: self).x:
                recognizer.location(in: self).x + translation.x
            
            let originY = translation.y >= 0 ?
                recognizer.location(in: self).y:
                recognizer.location(in: self).y + translation.y
            origin = CGPoint(x: originX, y: originY)
            
        } else if recognizer.state == .changed {
            guard let subView = self.subviews.last else {return}
            let originX = translation.x >= 0 ?
                subView.frame.origin.x:
                subView.frame.origin.x + subView.frame.width + translation.x
            
            let originY = translation.y >= 0 ?
                subView.frame.origin.y:
                subView.frame.origin.y + subView.frame.height + translation.y
            
            origin = CGPoint(x: originX, y: originY)
            subView.removeFromSuperview()
        }
        if recognizer.state == .began || recognizer.state == .changed {
            let rect = CGRect(x: origin.x, y: origin.y, width: width, height: height)
            let circleView = UIView(frame: rect)
            let ellipseRect = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
            let ellipsePath = UIBezierPath(ovalIn: ellipseRect)
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = ellipsePath.cgPath
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = lineColor.cgColor
            shapeLayer.lineWidth = lineWidth
            circleView.layer.addSublayer(shapeLayer)
            //add close button
            let closeButton = UIButton(frame: CGRect(x: circleView.frame.width - 20, y: 0, width: 20, height: 20))
            closeButton.setImage(UIImage(named: "close"), for: .normal)
            closeButton.addTarget(self, action: #selector(self.closeSelf(sender:)), for: .touchUpInside)
            circleView.addSubview(closeButton)
            self.addSubview(circleView)
        }
        
    }
    @objc func closeSelf(sender: UIButton) {
        sender.superview?.removeFromSuperview()
    }
    func drawRectangleOverImage(recognizer:UIPanGestureRecognizer,with lineWidth:CGFloat, lineColor : UIColor) {
        var origin : CGPoint = CGPoint(x: 0, y: 0)
        let translation = recognizer.translation(in: self)
        let width = abs(translation.x)
        let height = abs(translation.y)
        if recognizer.state == .began {
            let originX = translation.x >= 0 ?
                recognizer.location(in: self).x:
                recognizer.location(in: self).x + translation.x
            
            let originY = translation.y >= 0 ?
                recognizer.location(in: self).y:
                recognizer.location(in: self).y + translation.y
            origin = CGPoint(x: originX, y: originY)
            
        } else if recognizer.state == .changed {
            guard let subView = self.subviews.last else {return}
            let originX = translation.x >= 0 ?
                subView.frame.origin.x:
                subView.frame.origin.x + subView.frame.width + translation.x
            
            let originY = translation.y >= 0 ?
                subView.frame.origin.y:
                subView.frame.origin.y + subView.frame.height + translation.y
            
            origin = CGPoint(x: originX, y: originY)
            subView.removeFromSuperview()
        }
        if recognizer.state == .began || recognizer.state == .changed {
            let rect = CGRect(x: origin.x, y: origin.y, width: width, height: height)
            let rectangleView = UIView(frame: rect)
            let rectangleViewRect = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
            let rectangleViewPath = UIBezierPath(rect: rectangleViewRect)
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = rectangleViewPath.cgPath
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = lineColor.cgColor
            shapeLayer.lineWidth = lineWidth
            rectangleView.layer.addSublayer(shapeLayer)
            //add close button
            let closeButton = UIButton(frame: CGRect(x: rectangleView.frame.width - 20, y: 0, width: 20, height: 20))
            closeButton.setImage(UIImage(named: "close"), for: .normal)
            closeButton.addTarget(self, action: #selector(self.closeSelf(sender:)), for: .touchUpInside)
            rectangleView.addSubview(closeButton)
            self.addSubview(rectangleView)
        }
        
    }
    func drawFreeHand(recognizer:UIPanGestureRecognizer,previousLocation:CGPoint,with lineWidth:CGFloat, lineColor : UIColor) {
        if recognizer.state == .began {
            //draw location to translation
        }else{
            //draw prevLocation to current location
            let linePath = UIBezierPath()
            linePath.move(to: previousLocation)
            linePath.addLine(to: recognizer.location(in: self))
            let lineShape = CAShapeLayer()
            lineShape.strokeColor = lineColor.cgColor
            lineShape.lineWidth = lineWidth
            lineShape.path = linePath.cgPath
            self.layer.addSublayer(lineShape)
        }
    }
    
}
