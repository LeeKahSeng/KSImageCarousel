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

protocol KSICCoordinator: class, KSICScrollerViewControllerDelegate {
    
    /// The carousel that being show on screen
    var carousel: KSICScrollerViewController? { get }
    
    /// The model (images that need to be show on carousel)
    var model: [KSImageCarouselDisplayable] { get }
    
    /// View model for the carousel, this array will always have 3 elements.
    /// The 3 elements consists of [prev page element, current page element, next page element]
    /// nil in carouselViewModel indicates that no more data to show and carousel will not be able to scroll to next page / previous page anymore
    var carouselViewModel: [KSImageCarouselDisplayable?] { get }
    
    /// Current page of the carousel
    var currentPage: Int { get }
    
    /// Add the carousel to it's container
    func showCarousel(inside container: UIView, of parentViewController: UIViewController)
    
    /// Go to next page
    func nextPage()
    
    /// Go to previous page
    func previousPage()
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
        
        parentViewController.addChildViewController(carousel)
        carousel.didMove(toParentViewController: parentViewController)
        
        // Carousel to follow container size
        container.addSameSizeSubview(carousel.view)
    }
}

// MARK: -

/// Carousel can only scroll until last page or first page when using this coordinator
public class KSICFiniteCoordinator: KSICCoordinator {

    let model: [KSImageCarouselDisplayable]
    
    private var _carousel: KSICScrollerViewController?
    var carousel: KSICScrollerViewController? {
        return _carousel
    }
    
    private var _currentPage: Int {
        didSet {
            print("Trigger callback on carousel due to model view changed")
            //                let vm = carouselViewModel
            //                carousel?.viewModelDidChanged?(vm)
        }
    }
    
    var currentPage: Int {
        return _currentPage
    }
    
    var carouselViewModel: [KSImageCarouselDisplayable?] {
        
        if model.count == 1 {
            // When model only have 1 element, should not have previous page or next page
            return [nil,
                    model[currentPage],
                    nil]
        } else {
            
            if isFirstPage {
                // When at first page, should not have model for previous page, thus set it to nil
                return [nil,
                        model[currentPage],
                        model[currentPage + 1]]
            } else if isLastPage {
                // When at last page, should not have model for previous page, thus set it to nil
                return [model[currentPage - 1],
                        model[currentPage],
                        nil]
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
    ///   - initialPage: Page to display when carousel first shown
    /// - Throws: emptyModel, pageOutOfRange
    public init(with model: [KSImageCarouselDisplayable], initialPage: Int) throws {
        
        // Make sure model is not empty
        guard model.count > 0 else {
            throw CoordinatorError.emptyModel
        }
        
        self.model = model
        self._currentPage = initialPage
        
        // Make sure initial page is in range
        guard isPageInRange(initialPage) else {
            throw CoordinatorError.pageOutOfRange
        }
    }
    
    // MARK: KSICCoordinator conformation
    public func showCarousel(inside container: UIView, of parentViewController: UIViewController) {
        
        //        let vm = viewModel(forPage: currentPage)
        _carousel = KSICScrollerViewController(withViewModel: carouselViewModel)
        _carousel!.delegate = self
        add(_carousel!, to: container, of: parentViewController)
    }

    func nextPage() {
        if currentPage == lastPage {
            return
        } else {
            let newPage = currentPage + 1
            try! goto(page: newPage)
        }
    }
    
    func previousPage() {
        if currentPage == firstPage {
            return
        } else {
            let newPage = currentPage - 1
            try! goto(page: newPage)
        }
    }
    
    // MARK: Private functions
    
    /// Go to a specific page
    ///
    /// - Parameter p: page number
    /// - Throws: pageOutOfRange
    private func goto(page p: Int) throws {
        
        // Make sure page is between first page and last page
        guard isPageInRange(p) else {
            // throw exception
            throw CoordinatorError.pageOutOfRange
        }
        
        _currentPage = p
    }
}

// MARK: KSICScrollerViewControllerDelegate
extension KSICCoordinator where Self == KSICFiniteCoordinator {
    func scrollerViewControllerDidFinishLayoutSubviews(_ viewController: KSICScrollerViewController) {
        
    }
    
    func scrollerViewControllerDidGotoNextPage(_ viewController: KSICScrollerViewController) {
        nextPage()
    }
    
    func scrollerViewControllerDidGotoPreviousPage(_ viewController: KSICScrollerViewController) {
        previousPage()
    }
}

// MARK: -

/// Carousel will be able to scroll infinitely when using this coordinator
public class KSICInfiniteCoordinator: KSICCoordinator {
    
    let model: [KSImageCarouselDisplayable]
    
    var _carousel: KSICScrollerViewController?
    var carousel: KSICScrollerViewController? {
        return _carousel
    }
    
    var _currentPage: Int {
        didSet {
            // Update view model of carousel
            _carousel?.viewModel = carouselViewModel
            
            // Center page should always be the current visible page
            _carousel?.scrollToCenterPage()
        }
    }
    var currentPage: Int {
        return _currentPage
    }
    
    var carouselViewModel: [KSImageCarouselDisplayable?] {
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
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - model: Model for carousel
    ///   - initialPage: Page to display when carousel first shown
    /// - Throws: emptyModel, pageOutOfRange
    public init(with model: [KSImageCarouselDisplayable], initialPage: Int) throws {
        
        // Make sure model is not empty
        guard model.count > 0 else {
            throw CoordinatorError.emptyModel
        }
        
        self.model = model
        self._currentPage = initialPage
        
        // Make sure initial page is in range
        guard isPageInRange(initialPage) else {
            throw CoordinatorError.pageOutOfRange
        }
    }
    
    // MARK: KSICCoordinator conformation
    public func showCarousel(inside container: UIView, of parentViewController: UIViewController) {
        _carousel = KSICScrollerViewController(withViewModel: carouselViewModel)
        _carousel!.delegate = self
        add(_carousel!, to: container, of: parentViewController)
    }
    
    func nextPage() {
        if currentPage == lastPage {
            try! goto(page: firstPage)
        } else {
            let newPage = currentPage + 1
            try! goto(page: newPage)
        }
    }
    
    func previousPage() {
        if currentPage == firstPage {
            try! goto(page: lastPage)
        } else {
            let newPage = currentPage - 1
            try! goto(page: newPage)
        }
    }
    
    // MARK: Private functions
    
    /// Go to a specific page
    ///
    /// - Parameter p: page number
    /// - Throws: pageOutOfRange
    private func goto(page p: Int) throws {
        
        // Make sure page is between first page and last page
        guard isPageInRange(p) else {
            // throw exception
            throw CoordinatorError.pageOutOfRange
        }
        
        _currentPage = p
    }
}

// MARK: KSICScrollerViewControllerDelegate
extension KSICCoordinator where Self == KSICInfiniteCoordinator {
    func scrollerViewControllerDidFinishLayoutSubviews(_ viewController: KSICScrollerViewController) {
        // Center page should always be the current visible page
        carousel?.scrollToCenterPage()
    }
    
    func scrollerViewControllerDidGotoNextPage(_ viewController: KSICScrollerViewController) {
        nextPage()
    }
    
    func scrollerViewControllerDidGotoPreviousPage(_ viewController: KSICScrollerViewController) {
        previousPage()
    }
}

