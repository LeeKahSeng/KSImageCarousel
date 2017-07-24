//
//  KSICImageView.swift
//  KSImageCarousel
//
//  Created by Lee Kah Seng on 22/07/2017.
//  Copyright © 2017 Lee Kah Seng. All rights reserved. (https://github.com/LeeKahSeng/KSImageCarousel)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//

import UIKit


/// UIImageView subclass that have UIActivityIndicatorView as subview. This allow activity indicator to be shown at the center of the imageView while waiting for image to be downloaded
class KSICImageView: UIImageView {

    lazy var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        commonInit()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        
        commonInit()
    }
    
    private func commonInit() {
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        addSubview(activityIndicator)
        
        // Make activity indicator center
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    
        let centerX = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant:0)
        let centerY = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant:0)
        addConstraints([centerX , centerY])
    }
    
    /// Start animating activity indicator
    func startLoading() {
        activityIndicator.startAnimating()
    }
    
    /// Stop animating activity indicator
    func stopLoading() {
        activityIndicator.stopAnimating()
    }
}
