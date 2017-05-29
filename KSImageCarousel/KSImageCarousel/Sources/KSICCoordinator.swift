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

protocol KSICCoordinator: class {
    var carousel: KSICImageScrollerViewController? { get }
    var model: [String] { get }
    var carouselViewModel: [String?] { get }
    var currentPage: Int { get }
    
    func showCarousel()
    func nextPage()
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
    
    fileprivate func isPageInRange(_ page: Int) -> Bool {
        return  (page >= firstPage && page <= lastPage)
    }
}


class KSICFiniteCoordinator: KSICCoordinator {
    
    let model: [String]
    
    private var _carousel: KSICImageScrollerViewController?
    var carousel: KSICImageScrollerViewController? {
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
    
    var carouselViewModel: [String?] {
        if isFirstPage {
            // First page
            return [nil,
                    model[currentPage],
                    model[currentPage + 1]]
        } else if isLastPage {
            // Last page
            return [model[currentPage - 1],
                    model[currentPage],
                    nil]
        } else {
            return [model[currentPage - 1],
                    model[currentPage],
                    model[currentPage + 1]]
        }
    }
    
    init(with model: [String], initialPage: Int) throws {
        
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
    
    // Private
    private func goto(page p: Int) throws {
        
        // Make sure page is between first page and last page
        guard isPageInRange(p) else {
            // throw exception
            throw CoordinatorError.pageOutOfRange
        }
        
        _currentPage = p
    }

    
    // Implementation for Coordinator
    public func showCarousel() {
        //        let vm = viewModel(forPage: currentPage)
        _carousel = KSICImageScrollerViewController()
        //        carousel.delegate = self
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
}


class KSICInFiniteCoordinator: KSICCoordinator {
    
    let model: [String]
    
    var _carousel: KSICImageScrollerViewController?
    var carousel: KSICImageScrollerViewController? {
        return _carousel
    }
    
    var _currentPage: Int {
        didSet {
            print("Trigger callback on carousel due to model view changed")
            //                let vm = carouselViewModel
            //                carousel?.viewModelDidChanged?(vm)
        }
    }
    var currentPage: Int {
        return _currentPage
    }
    
    var carouselViewModel: [String?] {
        if isFirstPage {
            // First page
            return [model[lastPage],
                    model[currentPage],
                    model[currentPage + 1]]
        } else if isLastPage {
            // Last page
            return [model[currentPage - 1],
                    model[currentPage],
                    model[firstPage]]
        } else {
            return [model[currentPage - 1],
                    model[currentPage],
                    model[currentPage + 1]]
        }
    }
    
    init(with model: [String], initialPage: Int) throws {
        
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
    
    // Private
    private func goto(page p: Int) throws {
        
        // Make sure page is between first page and last page
        guard isPageInRange(p) else {
            // throw exception
            throw CoordinatorError.pageOutOfRange
        }
        
        _currentPage = p
    }
    
    // Implementation for Coordinator
    public func showCarousel() {
        //        let vm = viewModel(forPage: currentPage)
        _carousel = KSICImageScrollerViewController()
        //        carousel.delegate = self
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
}

