//
//  ViewController.swift
//  jPixels
//
//  Created by Jeevan on 06/07/18.
//  Copyright © 2018 Jeevan. All rights reserved.
//

import UIKit
extension UIView {
    
    /// Create snapshot
    ///
    /// - parameter rect: The `CGRect` of the portion of the view to return. If `nil` (or omitted),
    ///                   return snapshot of the whole view.
    ///
    /// - returns: Returns `UIImage` of the specified portion of the view.
    
    func snapshot(of rect: CGRect? = nil) -> UIImage? {
        // snapshot entire view
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let wholeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // if no `rect` provided, return image of whole view
        
        guard let image = wholeImage, let rect = rect else { return wholeImage }
        
        // otherwise, grab specified `rect` of image
        
        let scale = image.scale
        let scaledRect = CGRect(x: rect.origin.x * scale, y: rect.origin.y * scale, width: rect.size.width * scale, height: rect.size.height * scale)
        guard let cgImage = image.cgImage?.cropping(to: scaledRect) else { return nil }
        return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
    }
    
}
class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    @IBOutlet var imageView: UIImageView!

    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var previewButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    var originalImage = UIImage(named: "bg")
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imagePicker.delegate = self
        appDelegate.addShadow(inputView: imageView)
        appDelegate.addShadow(inputView: resetButton)
        appDelegate.addShadow(inputView: previewButton)
        appDelegate.addShadow(inputView: uploadButton)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
            originalImage = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    //MARK: - IBActions
    @IBAction func previewClicked(_ sender: Any) {
        performSegue(withIdentifier: "preview", sender: self)
    }
    @IBAction func reset(_ sender: Any) {
        imageView.image = originalImage
    }
    
    @IBAction func uploadClicked(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "Choose From", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            print("camera")
        })

        let photosAction = UIAlertAction(title: "Photos", style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            print("photos")
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:
        {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        optionMenu.addAction(photosAction)
        optionMenu.addAction(cameraAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    @IBAction func scribbleClicked(_ sender: Any) {
        performSegue(withIdentifier: "doodle", sender: self)
    }
    @IBAction func cropClicked(_ sender: Any) {
        performSegue(withIdentifier: "crop", sender: self)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "preview" {
            let pVC = segue.destination as! PreviewViewController
            pVC.previewImage = self.imageView.image
        }else if segue.identifier == "crop" {
            let cVC = segue.destination as! CropViewController
            cVC.imageToBeCropped = self.imageView.image
            cVC.delegate = self
        }else if segue.identifier == "doodle" {
            let dVC = segue.destination as! DoodleViewController
            dVC.imageToBeDoodled = self.imageView.image
            dVC.delegate = self
        }
    }
   
}
//ImageCroppedDelegate
extension ViewController:ImageCropDelegate {
    func imageCropped(_ image: UIImage?) {
        self.imageView.image = image
    }
}
//DoodleDelegate
extension ViewController:DoodleImageDelegate {
    func imageDoodled(_ image: UIImage?) {
        self.imageView.image = image
    }
}



