//
//  CropViewController.swift
//  jPixels
//
//  Created by Jeevan on 10/07/18.
//  Copyright © 2018 Jeevan. All rights reserved.
//

import UIKit
protocol ImageCropDelegate{
    func imageCropped(_ image : UIImage?)
}
class CropViewController: UIViewController {
    
    @IBOutlet var cropIndicatorView: CropView!
    @IBOutlet var imageView: UIImageView!
    // Corners
    @IBOutlet var topRightView:UIView!
    @IBOutlet var bottomRightView:UIView!
    @IBOutlet var topLeftView:UIView!
    @IBOutlet var bottomLeftView:UIView!
    // Edges
    @IBOutlet var topView:UIView!
    @IBOutlet var rightView:UIView!
    @IBOutlet var leftView:UIView!
    @IBOutlet var bottomView:UIView!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    //var & constants
    var imageToBeCropped : UIImage?
    var delegate:ImageCropDelegate?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.imageView.image = imageToBeCropped
        addCropView()
        appDelegate.addShadow(inputView: doneButton)
        appDelegate.addShadow(inputView: cancelButton)
        appDelegate.addShadow(inputView: imageView)
    }
    private func addCropView(){
        cropIndicatorView.frame = CGRect(x: 0, y: 0, width: imageView.frame.width/2, height: imageView.frame.height/2)
        cropIndicatorView.layer.borderColor = UIColor.white.cgColor
        cropIndicatorView.layer.borderWidth = 2.0
        imageView.addSubview(cropIndicatorView)
        imageView.bringSubviewToFront(cropIndicatorView)
        cropIndicatorView.center = imageView.center
        cropIndicatorView.delegate = self
    }
    private func translateAndTransform(recognizer:UIPanGestureRecognizer,shouldOriginXChange:Bool,shouldOriginYChange:Bool,isXAxis:Bool,isOppositeXBehaviour:Bool,isOppositeYBehaviour:Bool){
        if recognizer.state == .began || recognizer.state == .changed {
            // 1. gather requirements
            let translation = recognizer.translation(in: self.imageView)
            let newWidth = isOppositeXBehaviour ?
                cropIndicatorView.frame.width - translation.x :
                cropIndicatorView.frame.width + translation.x
            let newHeight = isOppositeYBehaviour ?
                cropIndicatorView.frame.height - translation.y :
                cropIndicatorView.frame.height + translation.y
            let isXWithinBounds = newWidth > 0 && newWidth < imageView.frame.width
            let isYWithinBounds = newHeight > 0 && newHeight < imageView.frame.height
            if isXAxis {
                // 2. X - axis :  width change & origin X
                if isXWithinBounds {
                    cropIndicatorView.frame.size = CGSize(width: newWidth, height:  cropIndicatorView.frame.height)
                    if shouldOriginXChange {
                        let newOriginX = cropIndicatorView.frame.origin.x + translation.x
                        
                        cropIndicatorView.frame.origin = CGPoint(x: newOriginX, y: cropIndicatorView.frame.origin.y)
                    }
                }
            }else {
                // 3. Y - axis :  height change & origin Y
                if isYWithinBounds {
                    cropIndicatorView.frame.size = CGSize(width: cropIndicatorView.frame.width, height: newHeight)
                    if shouldOriginYChange {
                        let newOriginY = cropIndicatorView.frame.origin.y + translation.y
                        
                        cropIndicatorView.frame.origin = CGPoint(x: cropIndicatorView.frame.origin.x, y: newOriginY)
                    }
                }
            }
            
        }
        
    }
    @IBAction func cancel(_ sender : Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func done(_ sender : Any) {
        //take screenshot and update source VC
        cropIndicatorView.removeFromSuperview()
        let translatedRect = self.imageView.convert(cropIndicatorView.frame, to: self.imageView)
        let croppedImage = self.imageView.snapshot(of: translatedRect)
        delegate?.imageCropped(croppedImage)
        dismiss(animated: true, completion: nil)
        
    }
}
//Crop Indicator delegates
extension CropViewController : CropIndicatorDelegate {
    
    func didPinch(sender: UIPinchGestureRecognizer) {
        // Change the size of the crop indicator with pinch in/out
        let scale = sender.scale
        if let view = sender.view {
            let newWidth = view.frame.width * scale
            let newHeight = view.frame.height * scale
            let isXWithinBounds = newWidth > 0 && newWidth < imageView.frame.width
            let isYWithinBounds = newHeight > 0 && newHeight < imageView.frame.height
            if isXWithinBounds && isYWithinBounds {
                view.transform = CGAffineTransform(scaleX: scale, y: scale)
            }else if !isXWithinBounds && !isYWithinBounds{
                view.frame = imageView.frame
            }else {
                if !isXWithinBounds {
                    view.transform = CGAffineTransform(scaleX: 1, y: scale)
                }
                if !isYWithinBounds {
                    view.transform = CGAffineTransform(scaleX: scale, y: 1)
                }
            }
            view.frame.origin = CGPoint(x: 0, y: 0)
        }
        //sender.scale = 1
    }
    func handleEdgeNCornerPan(recognizer:UIPanGestureRecognizer) {
        guard  let hotCornerView = recognizer.view else {
            return
        }
        switch hotCornerView {
        case topView:
            self.translateAndTransform(recognizer: recognizer,
                                       shouldOriginXChange: false,
                                       shouldOriginYChange: true,
                                       isXAxis:false,
                                       isOppositeXBehaviour:false,
                                       isOppositeYBehaviour:true)
            recognizer.setTranslation(CGPoint.zero, in: self.imageView)
        case rightView:
            self.translateAndTransform(recognizer: recognizer,
                                       shouldOriginXChange: false,
                                       shouldOriginYChange: false,
                                       isXAxis: true,
                                       isOppositeXBehaviour:false,
                                       isOppositeYBehaviour:false)
            recognizer.setTranslation(CGPoint.zero, in: self.imageView)
        case bottomView:
            self.translateAndTransform(recognizer: recognizer,
                                       shouldOriginXChange: false,
                                       shouldOriginYChange: false,
                                       isXAxis: false,
                                       isOppositeXBehaviour:false,
                                       isOppositeYBehaviour:false)
            recognizer.setTranslation(CGPoint.zero, in: self.imageView)
        case leftView:
            self.translateAndTransform(recognizer: recognizer,
                                       shouldOriginXChange: true,
                                       shouldOriginYChange: false,
                                       isXAxis: true,
                                       isOppositeXBehaviour:true,
                                       isOppositeYBehaviour:false)
            recognizer.setTranslation(CGPoint.zero, in: self.imageView)
        case topRightView:
            self.translateAndTransform(recognizer: recognizer,
                                       shouldOriginXChange: false,
                                       shouldOriginYChange: true,
                                       isXAxis:false,
                                       isOppositeXBehaviour:false,
                                       isOppositeYBehaviour:true)
            self.translateAndTransform(recognizer: recognizer,
                                       shouldOriginXChange: false,
                                       shouldOriginYChange: false,
                                       isXAxis: true,
                                       isOppositeXBehaviour:false,
                                       isOppositeYBehaviour:false)
            recognizer.setTranslation(CGPoint.zero, in: self.imageView)
        case bottomRightView:
            self.translateAndTransform(recognizer: recognizer,
                                       shouldOriginXChange: false,
                                       shouldOriginYChange: false,
                                       isXAxis: false,
                                       isOppositeXBehaviour:false,
                                       isOppositeYBehaviour:false)
            self.translateAndTransform(recognizer: recognizer,
                                       shouldOriginXChange: false,
                                       shouldOriginYChange: false,
                                       isXAxis: true,
                                       isOppositeXBehaviour:false,
                                       isOppositeYBehaviour:false)
            recognizer.setTranslation(CGPoint.zero, in: self.imageView)
        case bottomLeftView:
            self.translateAndTransform(recognizer: recognizer,
                                       shouldOriginXChange: false,
                                       shouldOriginYChange: false,
                                       isXAxis: false,
                                       isOppositeXBehaviour:false,
                                       isOppositeYBehaviour:false)
            self.translateAndTransform(recognizer: recognizer,
                                       shouldOriginXChange: true,
                                       shouldOriginYChange: false,
                                       isXAxis: true,
                                       isOppositeXBehaviour:true,
                                       isOppositeYBehaviour:false)
            recognizer.setTranslation(CGPoint.zero, in: self.imageView)
        case topLeftView:
            self.translateAndTransform(recognizer: recognizer,
                                       shouldOriginXChange: false,
                                       shouldOriginYChange: true,
                                       isXAxis:false,
                                       isOppositeXBehaviour:false,
                                       isOppositeYBehaviour:true)
            self.translateAndTransform(recognizer: recognizer,
                                       shouldOriginXChange: true,
                                       shouldOriginYChange: false,
                                       isXAxis: true,
                                       isOppositeXBehaviour:true,
                                       isOppositeYBehaviour:false)
            recognizer.setTranslation(CGPoint.zero, in: self.imageView)
        case cropIndicatorView:
            //Drag the crop indicator view around the imageView
            if recognizer.state == .began || recognizer.state == .changed {
                let translation = recognizer.translation(in: self.imageView)
                if let view = recognizer.view {
                    let newX = view.frame.origin.x + translation.x
                    let newY = view.frame.origin.y + translation.y
                    let is_x_Within_Bounds = newX >= 0 && newX + view.frame.width <= imageView.frame.width
                    let is_y_Within_Bounds = newY >= 0 && newY + view.frame.height <= imageView.frame.height
                    if is_x_Within_Bounds && is_y_Within_Bounds {
                        view.frame.origin = CGPoint(x:newX,
                                                    y:newY)
                    }
                }
                recognizer.setTranslation(CGPoint.zero, in: self.imageView)
            }
        default:
            print("")
        }
    }
}
