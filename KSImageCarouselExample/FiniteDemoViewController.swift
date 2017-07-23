//
//  FiniteDemoViewController.swift
//  KSImageCarouselExample
//
//  Created by Lee Kah Seng on 23/07/2017.
//  Copyright © 2017 Lee Kah Seng. All rights reserved.
//

import UIKit
import KSImageCarousel

class FiniteDemoViewController: UIViewController {

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
            URL(string: "https://via.placeholder.com/375x281/403ADA/FFFFFF?text=Image-0")!,
            URL(string: "https://via.placeholder.com/375x281/5D0F25/FFFFFF?text=Image-1")!,
            URL(string: "https://via.placeholder.com/375x281/83B002/FFFFFF?text=Image-2")!,
            URL(string: "https://via.placeholder.com/375x281/1B485D/FFFFFF?text=Image-3")!,
            URL(string: "https://via.placeholder.com/375x281/E6581C/FFFFFF?text=Image-4")!,
            ]
        
        // Use coordinator to show the carousel
        if let coordinator = try? KSICFiniteCoordinator(with: model, initialPage: 0) {
            coordinator.activityIndicatorStyle = .white
            coordinator.showCarousel(inside: container, of: self)
            coordinator.delegate = self
        }
    }

}

extension FiniteDemoViewController: KSICCoordinatorDelegate {
    
    func carouselDidTappedImage(at index: Int, coordinator: KSICCoordinator) {
        let alert = UIAlertController(title: "KSImageCarousel", message: "You tapped image at index \(index)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

