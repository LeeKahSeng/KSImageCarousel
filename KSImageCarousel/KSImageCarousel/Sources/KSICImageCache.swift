//
//  KSICImageCache.swift
//  KSImageCarousel
//
//  Created by Lee Kah Seng on 20/07/2017.
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

import Foundation

class KSICImageCache {
    
    // Singleton
    static let shared = KSICImageCache()
    
    private let cache = NSCache<AnyObject, UIImage>()
    private init() {
        cache.countLimit = 10 // Max cache 10 image
        cache.totalCostLimit = 10 * 1024 * 1024 // 10M
    }
    

    /// Fetch image from url. If already in cache, will use image in cache instead
    ///
    /// - Parameters:
    ///   - url: url of image
    ///   - completion: completion handler when image found in cache / download completed
    func fetchImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        // Check for cache before downloading image
        if let cachedImage = fetchFromCache(url) {
            // Image found in cache
            completion(cachedImage)
        } else {
            
            // Download image
            let task = URLSession.shared.dataTask(with: url) { [unowned self] (data, response, error) in
                if error == nil {
                    if let imageData = data, let image = UIImage(data: imageData) {
                        
                        self.cache.setObject(image, forKey: url.absoluteString as AnyObject, cost: imageData.count)
                        
                        DispatchQueue.main.async() {
                            completion(image)
                        }
                    }
                } else {
                    DispatchQueue.main.async() {
                        completion(nil)
                    }
                }
            }
            
            // Start download
            task.resume()
        }
    }
    
    
    /// Find image in cache base on URL string
    ///
    /// - Parameter url: url of image
    /// - Returns: image found in cache
    private func fetchFromCache(_ url: URL) -> UIImage? {
        return cache.object(forKey: url.absoluteString as AnyObject)
    }
}
