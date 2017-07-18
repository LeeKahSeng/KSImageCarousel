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

public protocol KSICScrollerViewControllerDelegate {
    func scrollerViewControllerDidGotoNextPage(_ viewController: KSICScrollerViewController)
    func scrollerViewControllerDidGotoPreviousPage(_ viewController: KSICScrollerViewController)
    func scrollerViewControllerDidFinishLayoutSubviews(_ viewController: KSICScrollerViewController)
    func scrollerViewControllerDidTappedImageView(at index: Int, viewController: KSICScrollerViewController)
}

public class KSICScrollerViewController: UIViewController {
    
    var delegate: KSICScrollerViewControllerDelegate?
    
    lazy fileprivate var scrollView: UIScrollView = UIScrollView()
    fileprivate var imageViews: [UIImageView] = []
    fileprivate var tapGestureRecognizers: [UITapGestureRecognizer?] = []
    
    /// This will be use to determine wether scroll view had scrolled to next page or previous page after scroll ended
    fileprivate var contentOffsetX: CGFloat = 0
    
    private var imageViewCount: Int {
        return viewModel.count
    }

    var viewModel: [KSImageCarouselDisplayable] {
        didSet {
            // Update scroll view with new view model
            setViewModelToScrollView()
        }
    }
    
    init(withViewModel vm: [KSImageCarouselDisplayable]) {
        
        viewModel = vm
        
        // Image views that later will be added to scroll view as subviews
        // The number of subviews needed will be same as number of view models provided
        for _ in vm.enumerated() {
            imageViews.append(UIImageView())
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("KSICScrollerViewController should not be use at interface builder. Please use KSICFiniteCoordinator / KSICInfiniteCoordinator")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        configureScrollView()
        setViewModelToScrollView()
    }
    
    override public func viewDidLayoutSubviews() {
        
        // Set scroll view content size
        let scrollViewWidth = scrollView.frame.width
        let scrollViewHeight = scrollView.frame.height
        scrollView.contentSize = CGSize(width: scrollViewWidth * CGFloat(imageViewCount), height: scrollViewHeight)
        
        // Layout image view in scroll view
        for i in 0..<imageViewCount {
            
            // Set image view frame
            let imageView = imageViews[i]
            imageView.frame = CGRect(x: scrollViewWidth * CGFloat(i), y: 0, width: scrollViewWidth, height: scrollViewHeight)
            scrollView.addSubview(imageView)
        }
        
        // After finish laying out image view, trigger delegate to coordinator to perform specific action
        delegate?.scrollerViewControllerDidFinishLayoutSubviews(self)
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - internal functions
    func scrollToCenterSubview(_ animated: Bool) {
        if imageViewCount < 3 {
            fatalError("scrollToCenterSubview() should only be called when viewModel have at least 3 elements.")
        }
        
        let scrollViewWidth = scrollView.bounds.size.width
        let scrollViewHeight = scrollView.bounds.size.height
        scrollView.scrollRectToVisible(CGRect(x: scrollViewWidth * 1, y: 0, width: scrollViewWidth, height: scrollViewHeight), animated: animated)
        
        // Keep track of the latest scroll view content offset x value
        contentOffsetX = scrollView.contentOffset.x
    }
    
    func scrollToFirstSubview(_ animated: Bool) {
        if imageViewCount < 1 {
            fatalError("scrollToFirstSubview() should only be called when viewModel have at least 1 element.")
        }
        
        let scrollViewWidth = scrollView.bounds.size.width
        let scrollViewHeight = scrollView.bounds.size.height
        scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: scrollViewWidth, height: scrollViewHeight), animated: animated)
        
        // Keep track of the latest scroll view content offset x value
        contentOffsetX = scrollView.contentOffset.x
    }
    
    func scrollToLastSubview(_ animated: Bool) {
        if imageViewCount < 1 {
            fatalError("scrollToLastSubview() should only be called when viewModel have at least 1 element.")
        }
        
        let scrollViewWidth = scrollView.bounds.size.width
        let scrollViewHeight = scrollView.bounds.size.height
        scrollView.scrollRectToVisible(CGRect(x: scrollViewWidth * CGFloat(imageViewCount - 1), y: 0, width: scrollViewWidth, height: scrollViewHeight), animated: animated)
        
        // Keep track of the latest scroll view content offset x value
        contentOffsetX = scrollView.contentOffset.x
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
            viewModel[index].createCarouselImage(completion: { (image) in
                imageView.image = image
            })
        }
    }
    
    fileprivate func scrollViewDidEndScrolling(withNewContentOffsetX newX: CGFloat, oldContentOffsetX oldX: CGFloat) {
        // TODO: Add unit test to make sure delegate trigger correctly
        if newX > oldX {
            // Next page
            // Trigger delegate and let coordinator decide what to do
            delegate?.scrollerViewControllerDidGotoNextPage(self)
        } else if newX < oldX {
            // Previous page
            // Trigger delegate and let coordinator decide what to do
            delegate?.scrollerViewControllerDidGotoPreviousPage(self)
        }
        
        contentOffsetX = newX
    }
    
    @objc fileprivate func imageViewDidTapped(regconizer: UITapGestureRecognizer) {
        
        let index = tapGestureRecognizers.index { (reg) -> Bool in
            return (reg == regconizer)
        }
        
        if let i = index {
            delegate?.scrollerViewControllerDidTappedImageView(at: i, viewController: self)
        }
    }
}

extension KSICScrollerViewController: UIScrollViewDelegate {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // Track the scroll view content offset when begin scrolling
        // This will be use to determine wether scroll view had scrolled to next page or previous page after scroll ended
        contentOffsetX = scrollView.contentOffset.x
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // This delegate will trigger after scroll view finish scrolling due to user interaction
        scrollViewDidEndScrolling(withNewContentOffsetX: scrollView.contentOffset.x, oldContentOffsetX: contentOffsetX)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // This delegate will trigger after scroll view is scrolled programatically using scrollRectToVisible()
        scrollViewDidEndScrolling(withNewContentOffsetX: scrollView.contentOffset.x, oldContentOffsetX: contentOffsetX)
    }
}
