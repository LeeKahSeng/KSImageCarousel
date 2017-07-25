# KSImageCarousel

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods](https://img.shields.io/cocoapods/v/KSFacebookButton.svg)](http://cocoapods.org/pods/KSFacebookButton)
[![Platform](https://img.shields.io/cocoapods/p/KSFacebookButton.svg?)](http://cocoadocs.org/docsets/KSFacebookButton)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/Carthage/Carthage/master/LICENSE.md)

KSImageCarousel is a lightweight image carousel which can easily adapt to different type of image source. KSImageCarousel support both finite and infinite scrolling mode. Just instantiate KSImageCarousel with your desire UIImages or image URLs and it will do all the work for you.


## Requirements
* Xcode 8 or later
* iOS 10.3 or later
* Swift 3.0 or later


## Features
* Infinite scrolling mode
* Finite scrolling mode
* Auto scroll
* Support ```UIImage``` and ```URL``` as image source
* Can easily adapt to other image source


## Example
Clone or download the source code and launch the project with ```KSImageCarouselExample.xcworkspace```. The example include sample code of using both infinite and finite scrolling mode.

![](https://thumbs.gfycat.com/UnhappyVariableIberianmole-size_restricted.gif)


## Installation
### CocoaPods
``` ruby
pod 'KSImageCarousel'
```

### Carthage
1. Create and update Cartfile
``` ruby
github "LeeKahSeng/KSImageCarousel"
```
2. Build the framework using terminal
```
carthage update
```
3. After finish building the framework using Carthage, open XCode and select you project in the project navigator.
4. At ```Build Phases``` tab, add ```KSImageCarousel.framework``` to ```Link Binary with Libraries```.
5. At ```General``` tab, add ```KSImageCarousel.framework``` to ```Embedded Binaries```.

### Manually
1. Download the project.
2. Drag the ```Sources``` folder in ```\KSImageCarousel\KSImageCarousel``` into your Xcode project.
3. Add ```import UIKit``` to all the source code that causing compile error. 
4. Build & run.


## How to use
KSImageCarousel is developed using coordinator pattern. Thus to start using KSImageCarousel, create a ```KSICInfiniteCoordinator``` or ```KSICFiniteCoordinator``` and use it to show the carousel in the desire container view.

Make sure you import KSImageCarousel if you are using CocoaPods or Carthage.
```swift
import KSImageCarousel
```

To use KSImageCarousel with finite scrolling mode.
```swift
// Create container view
let carouselContainer = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 150))
view.addSubview(carouselContainer)
        
// Create array of image source
let model = [
    URL(string: "https://via.placeholder.com/375x281/403ADA/FFFFFF?text=Image-0")!,
    URL(string: "https://via.placeholder.com/375x281/5D0F25/FFFFFF?text=Image-1")!,
    URL(string: "https://via.placeholder.com/375x281/83B002/FFFFFF?text=Image-2")!,
    URL(string: "https://via.placeholder.com/375x281/1B485D/FFFFFF?text=Image-3")!,
    URL(string: "https://via.placeholder.com/375x281/E6581C/FFFFFF?text=Image-4")!,
    ]
        
// Use coordinator to show the carousel
if let coordinator = try? KSICFiniteCoordinator(with: model, placeholderImage: nil, initialPage: 0) {
    coordinator.activityIndicatorStyle = .white
    coordinator.showCarousel(inside: carouselContainer, of: self)
}
```

To use KSImageCarousel with infinite scrolling mode
```swift
// Create container view
let carouselContainer = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 150))
view.addSubview(carouselContainer)
        
// Create array of image source
let model = [
    URL(string: "https://via.placeholder.com/375x281/403ADA/FFFFFF?text=Image-0")!,
    URL(string: "https://via.placeholder.com/375x281/5D0F25/FFFFFF?text=Image-1")!,
    URL(string: "https://via.placeholder.com/375x281/83B002/FFFFFF?text=Image-2")!,
    URL(string: "https://via.placeholder.com/375x281/1B485D/FFFFFF?text=Image-3")!,
    URL(string: "https://via.placeholder.com/375x281/E6581C/FFFFFF?text=Image-4")!,
    ]

// Use coordinator to show the carousel
if let coordinator = try? KSICInfiniteCoordinator(with: model, placeholderImage: nil, initialPage: 0) {
    coordinator.activityIndicatorStyle = .white
    coordinator.showCarousel(inside: carouselContainer, of: self)
}
```

To enable auto scrolling for KSICInfiniteCoordinator
```swift
coordinator.startAutoScroll(withDirection: .left, interval: 1)
```

To hide / show the activity indicator view when image being downloaded
```swift
coordinator.shouldShowActivityIndicator = true
```

To change the activity indicator view style
```swift
coordinator.activityIndicatorStyle = .white
```

Please note that both ```shouldShowActivityIndicator``` and ```activityIndicatorStyle``` needs to be set before calling ```showCarousel(inside: UIView, of: UIViewController)```

To detect tap event on the carousel, just conform to ```KSICCoordinatorDelegate``` and implement ```carouselDidTappedImage(at index: Int, coordinator: KSICCoordinator)```

Feel free to clone or download the source code and checkout the KSImageCarouselExample project which highlights how to use KSImageCarousel correctly.

### Adapt to use other type of image source
Currently KSImageCarousel support both ```UIImage``` and ```URL``` as image source. However, there might be situation where you need KSImageCarousel to support other image source such as Base64, byte array, etc., or you would prefer to use your project's own image downloader instead of the build-in downloader of KSImageCarousel. What you need to do is just create a custom image provider class and conform to ```KSImageCarouselDisplayable``` protocol.

Sample class to support Base64 image source:
```swift
class Base64ImageProvider {
    
    let base64: String
    
    init(_ base64: String) {
        self.base64 = base64
    }
    
    func covertToImage(completion: @escaping (UIImage?) -> Void) {
        
        /*** Code to covert Base64 to UIImage here ***/
        let convsionResult = UIImage()
        /*********************************************/
        
        // Call completion handler with the conversion result
        completion(convsionResult)
    }
}


extension Base64ImageProvider: KSImageCarouselDisplayable {
    
    func createCarouselImage(completion: @escaping (UIImage?, KSImageCarouselDisplayable) -> Void) {
        covertToImage { (image) in
            completion(image, self)
        }
    }
    
    func isEqual(to displayable: KSImageCarouselDisplayable) -> Bool {
        if let provider = displayable as? Base64ImageProvider {
            return base64 == provider.base64
        } else {
            return false
        }
    }
}
```
Sample class to use other image downloader:
```swift
class ImageProvider {
    
    let url: URL
    
    init(_ url: URL) {
        self.url = url
    }
    
    func downloadImage(completion: @escaping (UIImage?) -> Void) {
        
        /*** Code to download image using you own downloader class here ***/
        let downloadResult = UIImage()
        /******************************************************************/
        
        // Call completion handler with the conversion result
        completion(downloadResult)
    }
}


extension ImageProvider: KSImageCarouselDisplayable {

    func createCarouselImage(completion: @escaping (UIImage?, KSImageCarouselDisplayable) -> Void) {
        downloadImage { (downloadedImage) in
            completion(downloadedImage, self)
        }
    }
    
    func isEqual(to displayable: KSImageCarouselDisplayable) -> Bool {
        if let provider = displayable as? ImageProvider {
            return url == provider.url
        } else {
            return false
        }
    }
}
```


## License

This code is distributed under the terms and conditions of the [MIT license](LICENSE).
