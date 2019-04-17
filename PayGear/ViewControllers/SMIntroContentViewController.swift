//
//  SMIntroContentViewController.swift
//  PayGear
//
//  Created by Amir Soltani on 4/8/18.
//  Copyright © 2018 Samsson. All rights reserved.
//

import UIKit

class SMIntroContentViewController: UIViewController {

    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    
    var msg = ""
    var img = UIImage()
    var iconImg = UIImage()
    var main = ""
    var sub = ""
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.imageView.image = img
        self.subTitle.text = sub
        self.mainTitle.text = main
        
    }
    
    
 

}
