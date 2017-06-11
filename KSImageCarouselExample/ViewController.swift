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
                     UIImage(named: "purple")!]
        
        // Use coordinator to show the carousel
        if let coordinator = try? KSICInfiniteCoordinator(with: model, initialPage: 0) {
            coordinator.showCarousel(inside: containerView, of: self)
            coordinator.delegate = self
            coordinator.startAutoScroll(withDirection: .right, interval: 2)
        }
        
        
//        if let coordinator = try? KSICFiniteCoordinator(with: model, initialPage: 0) {
//            coordinator.showCarousel(inside: containerView, of: self)
//            coordinator.delegate = self
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: KSICCoordinatorDelegate {
    
    func carouselDidTappedImage(at index: Int, coordinator: KSICCoordinator) {
        print("tapped: \(index) | \(coordinator)")
    }

}

