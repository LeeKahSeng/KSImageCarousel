//
//  InfinityDemoViewController.swift
//  KSImageCarouselExample
//
//  Created by Lee Kah Seng on 23/07/2017.
//  Copyright © 2017 Lee Kah Seng. All rights reserved.
//

import UIKit
import KSImageCarousel

class InfinityDemoViewController: UIViewController {
    
    @IBOutlet weak var container: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup carousel
        setupCarousel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupCarousel() {
        
        // Create model for carousel
        let model = [
            UIImage(named: "Image-0.jpg")!,
            UIImage(named: "Image-1.jpg")!,
            UIImage(named: "Image-2.jpg")!,
            UIImage(named: "Image-3.jpg")!,
            UIImage(named: "Image-4.jpg")!,
            UIImage(named: "Image-5.jpg")!,
        ]
        
        // Use coordinator to show the carousel
        if let coordinator = try? KSICInfiniteCoordinator(with: model, initialPage: 0) {
            coordinator.showCarousel(inside: container, of: self)
            coordinator.delegate = self
            coordinator.startAutoScroll(withDirection: .left, interval: 2)
        }
    }
}

extension InfinityDemoViewController: KSICCoordinatorDelegate {
    
    func carouselDidTappedImage(at index: Int, coordinator: KSICCoordinator) {
        let alert = UIAlertController(title: "KSImageCarousel", message: "You tapped image at index \(index)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
