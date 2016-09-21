//
//  ViewController.swift
//  CHCarouselView
//
//  Created by Calvin on 8/5/16.
//  Copyright © 2016 CapsLock. All rights reserved.
//

import UIKit
import Kingfisher

class ViewController: UIViewController {
    @IBOutlet weak var carouselView: CarouselView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageUrls = [
            "https://dl.dropboxusercontent.com/u/108987767/Meme/01_Cupido.jpg",
            "https://dl.dropboxusercontent.com/u/108987767/Meme/bugs_everywhere.png",
            "https://dl.dropboxusercontent.com/u/108987767/Meme/p56an6SZj5_d.gif",
            "https://dl.dropboxusercontent.com/u/108987767/Meme/1557643_489616404482423_780202608_n.jpg",
        ]
        
        carouselView.selected = { [unowned self] (currentPage: Int) in
            let alertController = UIAlertController(title: nil, message: "You selected page: \(currentPage) in carousel.", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        carouselView.views = imageUrls
                                .map { url -> UIImageView in
                                    let imageView = UIImageView()
                                    imageView.kf.setImage(with: URL(string: url)!)
                                    imageView.contentMode = .scaleAspectFill
                                    imageView.clipsToBounds = true
                                    
                                    return imageView
                                }
    }
}

