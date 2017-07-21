//
//  KSImageCarouselDisplayable.swift
//  KSImageCarousel
//
//  Created by Lee Kah Seng on 30/05/2017.
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

import Foundation
import UIKit

public protocol KSImageCarouselDisplayable {
    
    
    /// Create / generate / download image that needs to be show on carousell
    ///
    /// - Parameter completion: Completion handler when image is ready. This closure should accept the image and the KSImageCarouselDisplayable that provide the image
    func createCarouselImage(completion: @escaping (UIImage?, KSImageCarouselDisplayable) -> Void)
    
    
    /// Act as equatable checker to compare 2 KSImageCarouselDisplayable. This is needed to make sure the image will show in the correct image view of the carousel when createCarouselImage completion handler trigger . However if the KSImageCarouselDisplayable able to create the image instantly, then just return true in this function
    ///
    /// - Parameter displayable: KSImageCarouselDisplayable to compare
    /// - Returns: true -> both is the same; false -> both is not the same
    func isEqual(to displayable: KSImageCarouselDisplayable) -> Bool
}

extension UIImage: KSImageCarouselDisplayable {

    public func createCarouselImage(completion: @escaping (UIImage?, KSImageCarouselDisplayable) -> Void) {
        completion(self, self)
    }
    
    public func isEqual(to displayable: KSImageCarouselDisplayable) -> Bool {
        return true
    }
}

extension URL: KSImageCarouselDisplayable {

    public func createCarouselImage(completion: @escaping (UIImage?, KSImageCarouselDisplayable) -> ()) {
        KSICImageCache.shared.fetchImage(from: self) { (image) in
            completion(image, self)
        }
    }

    public func isEqual(to displayable: KSImageCarouselDisplayable) -> Bool {
        if let url = displayable as? URL {
            return url == self
        } else {
            return false
        }
    }
}
