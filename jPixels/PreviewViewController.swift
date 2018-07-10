//
//  PreviewViewController.swift
//  jPixels
//
//  Created by Jeevan on 09/07/18.
//  Copyright © 2018 Jeevan. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var previewImage:UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageView.image = previewImage ?? UIImage(named: "bg")!
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
