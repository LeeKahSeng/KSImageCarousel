//
//  ViewController.swift
//  KSImageCarouselExample
//
//  Created by Lee Kah Seng on 24/05/2017.
//  Copyright © 2017 Lee Kah Seng. All rights reserved.
//

import UIKit
import KSImageCarousel

class ViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create model for carousel
        let model = [UIImage(named: "red")!,
                     UIImage(named: "green")!,
                     UIImage(named: "blue")!,
                     UIImage(named: "yellow")!,
                     UIImage(named: "black")!,
                     UIImage(named: "purple")!,
                     ]
        
        if let coordinator = try? KSICFiniteCoordinator(with: model, initialPage: 0) {
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

