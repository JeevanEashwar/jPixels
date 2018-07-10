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
    
    //Var & Constants
    var delegate:DoodleImageDelegate?
    var imageToBeDoodled:UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.imageView.image = imageToBeDoodled
        
        let scribbleGesture = UIPanGestureRecognizer(target: self, action: #selector(handleScribblePan(recognizer:)))
        imageView.addGestureRecognizer(scribbleGesture)
    }
    @objc func handleScribblePan(recognizer:UIPanGestureRecognizer) {
        if scribbleSegmentControl.selectedSegmentIndex == 0 {
            imageView.drawCircleOverImage(recognizer: recognizer)
        }else if scribbleSegmentControl.selectedSegmentIndex == 1{
            imageView.drawRectangleOverImage(recognizer: recognizer)
        }else {
            imageView.drawLineOverImage(recognizer: recognizer)
        }
        
    }
    @IBAction func cancel(_ sender : Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func done(_ sender : Any) {
        //take screenshot and update source VC
        let doodledImage = imageView.snapshot(of: imageView.frame)
        delegate?.imageDoodled(doodledImage)
        dismiss(animated: true, completion: nil)
    }
}
//Doodle methods
extension UIImageView {
    func drawLineFromPoint(start : CGPoint, toPoint end:CGPoint, ofColor lineColor: UIColor, inView view:UIView) {
        
        //design the path
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        
        //design path in layer
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = 1.0
        
        view.layer.addSublayer(shapeLayer)
    }
    func drawLineOverImage(recognizer:UIPanGestureRecognizer) {
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
            shapeLayer.strokeColor = UIColor.white.cgColor
            shapeLayer.lineWidth = 4.0
            self.layer.addSublayer(shapeLayer)
            
        }
        
    }
    
    func drawCircleOverImage(recognizer:UIPanGestureRecognizer) {
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
            shapeLayer.strokeColor = UIColor.white.cgColor
            shapeLayer.lineWidth = 4.0
            circleView.layer.addSublayer(shapeLayer)
            self.addSubview(circleView)
        }
        
    }
    func drawRectangleOverImage(recognizer:UIPanGestureRecognizer) {
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
            shapeLayer.strokeColor = UIColor.white.cgColor
            shapeLayer.lineWidth = 4.0
            rectangleView.layer.addSublayer(shapeLayer)
            self.addSubview(rectangleView)
        }
        
    }
    
}
