//
//  KSICScrollerViewController.swift
//  KSImageCarousel
//
//  Created by Lee Kah Seng on 01/06/2017.
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

protocol KSICScrollerViewControllerDelegate {
    func scrollerViewControllerDidGotoNextPage(_ viewController: KSICScrollerViewController)
    func scrollerViewControllerDidGotoPreviousPage(_ viewController: KSICScrollerViewController)
}

class KSICScrollerViewController: UIViewController {

    // View model should always have 3 elements
    private let viewModelCount = 3
    
    var delegate: KSICScrollerViewControllerDelegate?
    
    lazy var scrollView: UIScrollView = UIScrollView()
    lazy var imageViews: [UIImageView] = [UIImageView(), UIImageView(), UIImageView()]
    var tapGestureRecognizers: [UITapGestureRecognizer?] = []
    
    /// This will be use to determine wether scroll view had scrolled to next page or previous page after scroll ended
    var contentOffsetX: CGFloat = 0

    var viewModel: [KSImageCarouselDisplayable?] {
        didSet {
            if viewModel.count != viewModelCount {
                fatalError("View model must have \(viewModelCount) elements")
            }
            viewModelDidChanged()
        }
    }
    
    init(withViewModel vm: [KSImageCarouselDisplayable?]) {
        
        viewModel = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("KSICScrollerViewController should not be use at interface builder. Please use KSICFiniteCoordinator / KSICInfiniteCoordinator")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureScrollView()
        setViewModelToScrollView()
    }
    
    override func viewDidLayoutSubviews() {
        
        // Set scroll view content size
        let scrollViewWidth = scrollView.frame.width
        let scrollViewHeight = scrollView.frame.height
        scrollView.contentSize = CGSize(width: scrollViewWidth * CGFloat(viewModelCount), height: scrollViewHeight)
        
        // Layout image view in scroll view
        for (index, imageView) in imageViews.enumerated() {
            
            // Set image view frame
            imageView.frame = CGRect(x: scrollViewWidth * CGFloat(index), y: 0, width: scrollViewWidth, height: scrollViewHeight)
            scrollView.addSubview(imageView)
        }
        
        // After finish laying out image view, display center page (as first page) to user.
        scrollToCenterPage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - fileprivate functions
    fileprivate func configureScrollView() {
        scrollView.backgroundColor = .gray
        view.addSameSizeSubview(scrollView)
        
        // Configure scrollView
        self.scrollView.isPagingEnabled = true
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.scrollsToTop = false
        self.scrollView.delegate = self
        
        // Add tap gesture recognizer to image view
        for imageView in imageViews {
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewDidTapped(regconizer:)))
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(tapGestureRecognizer)

            // Keep instance of tap gesture recognizer in array
            tapGestureRecognizers.append(tapGestureRecognizer)
        }
    }
    
    fileprivate func setViewModelToScrollView() {
        
        // Set image from view model to image view
        for (index, imageView) in imageViews.enumerated() {
            viewModel[index]?.createCarouselImage(completion: { (image) in
                imageView.image = image
            })
        }
    }
    
    fileprivate func viewModelDidChanged() {
        
        // Show image in scroll view
        setViewModelToScrollView()
        
        // Center page is always to page to show to user. Thus scroll to center page
        scrollToCenterPage()
    }
    
    fileprivate func scrollToCenterPage() {

        let scrollViewWidth = scrollView.bounds.size.width
        let scrollViewHeight = scrollView.bounds.size.height
        scrollView.scrollRectToVisible(CGRect(x: scrollViewWidth * 1, y: 0, width: scrollViewWidth, height: scrollViewHeight), animated: false)
        
        // Keep track of the latest scroll view content offset x value
        contentOffsetX = scrollView.contentOffset.x
    }
    
    fileprivate func scrollViewDidEndScrolling(withNewContentOffsetX newX: CGFloat, oldContentOffsetX oldX: CGFloat) {
       // TODO: Add Unit test for this
        
        if newX > oldX {
            // When the new content offset x is greater than half
            print("next")
            // Trigger delegate
            delegate?.scrollerViewControllerDidGotoNextPage(self)
        } else if newX < oldX {
            // Previous page
            print("prev")
            // Trigger delegate
            delegate?.scrollerViewControllerDidGotoPreviousPage(self)
        }
        
        contentOffsetX = newX
    }
    
    @objc fileprivate func imageViewDidTapped(regconizer: UITapGestureRecognizer) {
        
        let index = tapGestureRecognizers.index { (reg) -> Bool in
            return (reg == regconizer)
        }
        print("tap: \(index)")
    }
}

extension KSICScrollerViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // Track the scroll view content offset when begin scrolling
        // This will be use to determine wether scroll view had scrolled to next page or previous page after scroll ended
        contentOffsetX = scrollView.contentOffset.x
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // This delegate will trigger after scroll view finish scrolling due to user interaction
        scrollViewDidEndScrolling(withNewContentOffsetX: scrollView.contentOffset.x, oldContentOffsetX: contentOffsetX)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // This delegate will trigger after scroll view is scrolled programatically using scrollRectToVisible()
        scrollViewDidEndScrolling(withNewContentOffsetX: scrollView.contentOffset.x, oldContentOffsetX: contentOffsetX)
    }
}
