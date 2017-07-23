//
//  KSICCoordinator.swift
//  KSImageCarousel
//
//  Created by Lee Kah Seng on 28/05/2017.
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

public protocol KSICCoordinatorDelegate {
    
    /// Method triggered when image of carousel being tapped
    ///
    /// - Parameter index: model's index of the tapped image
    func carouselDidTappedImage(at index: Int, coordinator: KSICCoordinator)
}

extension KSICCoordinatorDelegate {
    // Optional delegte method
    public func carouselDidTappedImage(at index: Int, coordinator: KSICCoordinator) {}
}

public protocol KSICCoordinator: class, KSICScrollerViewControllerDelegate {
    
    /// The carousel that being show on screen
    var carousel: KSICScrollerViewController? { get }
    
    /// The model (images that need to be show on carousel)
    var model: [KSImageCarouselDisplayable] { get }
    
    /// The placeholder image to show while image being download
    var placeholderImage: UIImage? { get }
    
    /// A Boolean value that determines whether the activity indicator is visible when loading image to carousel. Default value is true. This value should be set before calling showCarousel(inside: of:)
    var shouldShowActivityIndicator: Bool { get }
    
    /// Style of the activity indicator that shown when loading image to carousel. Default value is gray. This value needs should be set before calling showCarousel(inside: of:)
    var activityIndicatorStyle: UIActivityIndicatorViewStyle { get }
    
    /// KSICCoordinator optional delegte
    var delegate: KSICCoordinatorDelegate? { get }
    
    /// View model for the carousel.
    /// The 3 elements consists of [prev page element, current page element, next page element]
    /// If model only have less than 3 element, view model will have less than 3 element as well
    var carouselViewModel: [KSImageCarouselDisplayable] { get }
    
    /// Page (index) of model that currently visible to user
    var currentPage: Int { get }
    
    /// Add the carousel to it's container
    func showCarousel(inside container: UIView, of parentViewController: UIViewController)
    
    /// Scroll carousel to next page (just like user swipe to left)
    func scrollToNextPage()

    /// Scroll carousel to previous page (just like user swipe to right)
    func scrollToPreviousPage()
}

extension KSICCoordinator {
    
    fileprivate var firstPage: Int {
        return 0
    }
    
    fileprivate var lastPage: Int {
        return model.count - 1
    }
    
    fileprivate var isFirstPage: Bool {
        return currentPage == firstPage
    }
    
    fileprivate var isLastPage: Bool {
        return currentPage == lastPage
    }
    
    /// Check to make sure the page number is in range (between first page & last page)
    ///
    /// - Parameter page: page number to check
    /// - Returns: True -> In range | False -> out of range
    fileprivate func isPageInRange(_ page: Int) -> Bool {
        return  (page >= firstPage && page <= lastPage)
    }

    /// Add carousel as child view controller and follow the size of the container view
    ///
    /// - Parameters:
    ///   - carousel: carousel to be added as child view controller
    ///   - container: container that contain the carousel
    ///   - parentViewController: parent view controller of the carousel
    fileprivate func add(_ carousel: KSICScrollerViewController, to container: UIView, of parentViewController: UIViewController) {
        
        // Note: automaticallyAdjustsScrollViewInsets of the parent view controller must be set to false so that content size of UIScrollView in KSICScrollerViewController is correct
        parentViewController.automaticallyAdjustsScrollViewInsets = false
        
        // Add KSICScrollerViewController as child view controller
        parentViewController.addChildViewController(carousel)
        carousel.didMove(toParentViewController: parentViewController)
        
        // Carousel to follow container size
        container.addSameSizeSubview(carousel.view)
    }
}

// MARK: -

/// Carousel can only scroll until last page or first page when using this coordinator
public class KSICFiniteCoordinator: KSICCoordinator {
    
    public var delegate: KSICCoordinatorDelegate?
    public let model: [KSImageCarouselDisplayable]
    public let placeholderImage: UIImage?
    public var shouldShowActivityIndicator = true
    public var activityIndicatorStyle: UIActivityIndicatorViewStyle = .gray
    public internal(set) var carousel: KSICScrollerViewController?

    public private(set) var currentPage: Int {
        didSet {
            // Note: Everytime current page being set, we will update carousel's viewModel (which will update images in carousel) and scroll carousel to subview that user should see
            
            // Update view model of carousel
            carousel?.viewModel = carouselViewModel
            
            // Scroll carousel (without animation) to subview that user should see
            swapCarouselSubview()
        }
    }
    
    public var carouselViewModel: [KSImageCarouselDisplayable] {
        
        if model.count == 1 {
            // When model have only 1 element
            return [model[0]]
            
        } else if model.count == 2 {
            // When model have only 2 elements
            return [model[0], model[1]]
            
        } else {
            // When model have only 3 or more elements
            if isFirstPage {
                
                return [model[currentPage],
                        model[currentPage + 1],
                        model[currentPage + 2]]
                
            } else if isLastPage {
                
                return [model[currentPage - 2],
                        model[currentPage - 1],
                        model[currentPage]]
                
            } else {
                
                return [model[currentPage - 1],
                        model[currentPage],
                        model[currentPage + 1]]
            }
        }
    }

    /// Initializer
    ///
    /// - Parameters:
    ///   - model: Model for carousel
    ///   - placeholderImage: Placeholder image to show when image being download
    ///   - initialPage: Page to display when carousel first shown
    /// - Throws: emptyModel, pageOutOfRange
    public init(with model: [KSImageCarouselDisplayable], placeholderImage: UIImage?, initialPage: Int) throws {
        
        // Make sure model is not empty
        guard model.count > 0 else {
            throw CoordinatorError.emptyModel
        }
        
        self.model = model
        self.placeholderImage = placeholderImage
        self.currentPage = initialPage
        
        // Make sure initial page is in range
        guard isPageInRange(initialPage) else {
            throw CoordinatorError.pageOutOfRange
        }
    }
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - model: Model for carousel
    ///   - initialPage: Page to display when carousel first shown
    /// - Throws: emptyModel, pageOutOfRange
    public convenience init(with model: [KSImageCarouselDisplayable], initialPage: Int) throws {
        try self.init(with: model, placeholderImage: nil, initialPage: initialPage)
    }
    
    // MARK: KSICCoordinator conformation
    public func showCarousel(inside container: UIView, of parentViewController: UIViewController) {
        carousel = KSICScrollerViewController(withViewModel: carouselViewModel, placeholderImage: placeholderImage, delegate: self)
        add(carousel!, to: container, of: parentViewController)
    }

    public func scrollToNextPage() {
        
        // Simulate action when user scroll carousel with finger. This will trigger scrollerViewControllerDidGotoNextPage and everything will run just the same like a real user interaction
        
        if isFirstPage {
            carousel?.scrollToCenterSubview(true)
        } else {
            carousel?.scrollToLastSubview(true)
        }
    }
    
    public func scrollToPreviousPage() {
        
        // Simulate action when user scroll carousel with finger. This will trigger scrollerViewControllerDidGotoPreviousPage and everything will run just the same like a real user interaction
        
        if isLastPage {
            carousel?.scrollToCenterSubview(true)
        } else {
            carousel?.scrollToFirstSubview(true)
        }
    }
    
    // MARK: Utilities functions
    
    /// Set current page number
    ///
    /// - Parameter p: page number
    /// - Throws: pageOutOfRange
    private func setPage(_ p: Int) throws {
        
        // Make sure page is between first page and last page
        guard isPageInRange(p) else {
            // throw exception
            throw CoordinatorError.pageOutOfRange
        }
        
        currentPage = p
    }
    
    /// +1 to page number - calling this will update currentPage -> update caoursel.viewModel -> update images in carousel -> scroll carousel to desire subview
    func increasePageByOne() {
        if currentPage == lastPage {
            return
        } else {
            let newPage = currentPage + 1
            try! setPage(newPage)
        }
    }
    
    /// -1 to page number - calling this will update currentPage -> update caoursel.viewModel -> update images in carousel -> scroll carousel to desire subview
    func reducePageByOne() {
        if currentPage == firstPage {
            return
        } else {
            let newPage = currentPage - 1
            try! setPage(newPage)
        }
    }
    
    /// Base on current page, scroll carousel (without animation) to subview that should be visible to user
    fileprivate func swapCarouselSubview() {
        if isFirstPage {
            // Scroll to first image view
            carousel?.scrollToFirstSubview(false)
        } else if isLastPage {
            // Scroll to last image view
            carousel?.scrollToLastSubview(false)
        } else {
            // Scroll to center image view
            carousel?.scrollToCenterSubview(false)
        }
    }
}

// MARK: KSICScrollerViewControllerDelegate
extension KSICCoordinator where Self == KSICFiniteCoordinator {
    public func scrollerViewControllerDidFinishLayoutSubviews(_ viewController: KSICScrollerViewController) {
        // Scroll carousel (without animation) to subview that user should see
        swapCarouselSubview()
    }
    
    public func scrollerViewControllerDidGotoNextPage(_ viewController: KSICScrollerViewController) {
        // Calling increasePageByOne() will update currentPage -> update caoursel.viewModel -> update images in carousel -> scroll carousel to desire subview
        increasePageByOne()
    }
    
    public func scrollerViewControllerDidGotoPreviousPage(_ viewController: KSICScrollerViewController) {
        // Calling reducePageByOne() will update currentPage -> update caoursel.viewModel -> update images in carousel -> scroll carousel to desire subview
        reducePageByOne()
    }
    
    public func scrollerViewControllerDidTappedImageView(at index: Int, viewController: KSICScrollerViewController) {
        delegate?.carouselDidTappedImage(at: currentPage, coordinator: self)
    }
    
    public func scrollerViewControllerShouldShowActivityIndicator() -> Bool {
        return shouldShowActivityIndicator
    }
    
    public func scrollerViewControllerShowActivityIndicatorStyle() -> UIActivityIndicatorViewStyle {
        return activityIndicatorStyle
    }
}

// MARK: -

/// Carousel will be able to scroll infinitely when using this coordinator
public class KSICInfiniteCoordinator: KSICCoordinator {
    
    public enum KSICAutoScrollDirection {
        case left
        case right
    }
    
    public var delegate: KSICCoordinatorDelegate?
    public let model: [KSImageCarouselDisplayable]
    public let placeholderImage: UIImage?
    public var shouldShowActivityIndicator = true
    public var activityIndicatorStyle: UIActivityIndicatorViewStyle = .gray
    public internal(set) var carousel: KSICScrollerViewController?
    
    public private(set) var currentPage: Int {
        didSet {
            
            // Note: Everytime current page being set, we will update carousel's viewModel (which will update images in carousel) and scroll carousel to subview that user should see
            
            // Update view model of carousel
            carousel?.viewModel = carouselViewModel
            
            // Scroll carousel (without animation) to subview that user should see
            swapCarouselSubview()
        }
    }
    
    public var carouselViewModel: [KSImageCarouselDisplayable] {
        if model.count == 1 {
            // When model only have 1 element, next page & previous page is same as current page
            return [model[currentPage],
                    model[currentPage],
                    model[currentPage]]
        } else {
            
            if isFirstPage {
                // When at first page, previous page should be last page
                return [model[lastPage],
                        model[currentPage],
                        model[currentPage + 1]]
            } else if isLastPage {
                // When at last page, next page should be first page
                return [model[currentPage - 1],
                        model[currentPage],
                        model[firstPage]]
            } else {
                return [model[currentPage - 1],
                        model[currentPage],
                        model[currentPage + 1]]
            }
        }
    }
    
    
    /// Timer object needed for auto scrolling
    lazy private var autoScrollTimer: Timer = Timer()
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - model: Model for carousel
    ///   - placeholderImage: Placeholder image to show when image being download
    ///   - initialPage: Page to display when carousel first shown
    /// - Throws: emptyModel, pageOutOfRange
    public init(with model: [KSImageCarouselDisplayable], placeholderImage: UIImage?, initialPage: Int) throws {
        
        // Make sure model is not empty
        guard model.count > 0 else {
            throw CoordinatorError.emptyModel
        }
        
        self.model = model
        self.placeholderImage = placeholderImage
        self.currentPage = initialPage
        
        // Make sure initial page is in range
        guard isPageInRange(initialPage) else {
            throw CoordinatorError.pageOutOfRange
        }
    }
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - model: Model for carousel
    ///   - initialPage: Page to display when carousel first shown
    /// - Throws: emptyModel, pageOutOfRange
    public convenience init(with model: [KSImageCarouselDisplayable], initialPage: Int) throws {
        try self.init(with: model, placeholderImage: nil, initialPage: initialPage)
    }
    
    // MARK: KSICCoordinator conformation
    public func showCarousel(inside container: UIView, of parentViewController: UIViewController) {
        carousel = KSICScrollerViewController(withViewModel: carouselViewModel, placeholderImage: placeholderImage, delegate: self)
        add(carousel!, to: container, of: parentViewController)
    }
    
    public func scrollToNextPage() {
        // Simulate action when user scroll carousel with finger. This will trigger scrollerViewControllerDidGotoNextPage and everything will run just the same like a real user interaction
        carousel?.scrollToLastSubview(true)
    }
    
    public func scrollToPreviousPage() {
        // Simulate action when user scroll carousel with finger. This will trigger scrollerViewControllerDidGotoPreviousPage and everything will run just the same like a real user interaction
        carousel?.scrollToFirstSubview(true)
    }
    
    // MARK: Public functions
    public func startAutoScroll(withDirection direction: KSICAutoScrollDirection, interval: TimeInterval) {
        switch direction {
        case .left:
            autoScrollTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { [unowned self] (timer) in
                self.scrollToNextPage()
            })
        case .right:
            autoScrollTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { [unowned self] (timer) in
                self.scrollToPreviousPage()
            })
        }
    }
    
    public func stopAutoScroll() {
        autoScrollTimer.invalidate()
    }
    
    
    // MARK: Utilities functions
    
    /// +1 to page number - calling this will update currentPage -> update caoursel.viewModel -> update images in carousel -> scroll carousel to desire subview
    func increasePageByOne() {
        if currentPage == lastPage {
            try! setPage(firstPage)
        } else {
            let newPage = currentPage + 1
            try! setPage(newPage)
        }
    }
    
    /// -1 to page number - calling this will update currentPage -> update caoursel.viewModel -> update images in carousel -> scroll carousel to desire subview
    func reducePageByOne() {
        if currentPage == firstPage {
            try! setPage(lastPage)
        } else {
            let newPage = currentPage - 1
            try! setPage(newPage)
        }
    }
    
    /// Set current page number
    ///
    /// - Parameter p: page number
    /// - Throws: pageOutOfRange
    private func setPage(_ p: Int) throws {
        
        // Make sure page is between first page and last page
        guard isPageInRange(p) else {
            // throw exception
            throw CoordinatorError.pageOutOfRange
        }
        
        currentPage = p
    }
    
    /// Base on current page, scroll carousel (without animation) to subview that should be visible to user
    fileprivate func swapCarouselSubview() {
        // Center page should always be the current visible page
        carousel?.scrollToCenterSubview(false)
    }
}

// MARK: KSICScrollerViewControllerDelegate
extension KSICCoordinator where Self == KSICInfiniteCoordinator {
    public func scrollerViewControllerDidFinishLayoutSubviews(_ viewController: KSICScrollerViewController) {
        // Scroll carousel (without animation) to subview that user should see
        swapCarouselSubview()
    }
    
    public func scrollerViewControllerDidGotoNextPage(_ viewController: KSICScrollerViewController) {
        // Calling increasePageByOne() will update currentPage -> update caoursel.viewModel -> update images in carousel -> scroll carousel to desire subview
        increasePageByOne()
    }
    
    public func scrollerViewControllerDidGotoPreviousPage(_ viewController: KSICScrollerViewController) {
        // Calling reducePageByOne() will update currentPage -> update caoursel.viewModel -> update images in carousel -> scroll carousel to desire subview
        reducePageByOne()
    }
    
    public func scrollerViewControllerDidTappedImageView(at index: Int, viewController: KSICScrollerViewController) {
        delegate?.carouselDidTappedImage(at: currentPage, coordinator: self)
    }
    
    public func scrollerViewControllerShouldShowActivityIndicator() -> Bool {
        return shouldShowActivityIndicator
    }
    
    public func scrollerViewControllerShowActivityIndicatorStyle() -> UIActivityIndicatorViewStyle {
        return activityIndicatorStyle
    }
}

