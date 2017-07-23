//
//  KSICFakeScrollerViewController.swift
//  KSImageCarousel
//
//  Created by Lee Kah Seng on 23/07/2017.
//  Copyright © 2017 Lee Kah Seng. All rights reserved.
//

import Foundation
@testable import KSImageCarousel

class KSICFakeScrollerViewController: KSICScrollerViewController {
    
    var scrollToCenterSubviewCalled: Bool
    var scrollToFirstSubviewCalled: Bool
    var scrollToLastSubviewCalled: Bool
    
    init(withViewModel vm: [KSImageCarouselDisplayable]) {
        
        scrollToCenterSubviewCalled = false
        scrollToFirstSubviewCalled = false
        scrollToLastSubviewCalled = false
        
        super.init(withViewModel: vm, placeholderImage: nil, delegate: KSICFakeScrollerViewControllerDelegate())
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func scrollToCenterSubview(_ animated: Bool) {
        scrollToCenterSubviewCalled = true
    }
    
    override func scrollToFirstSubview(_ animated: Bool) {
        scrollToFirstSubviewCalled = true
    }
    
    override func scrollToLastSubview(_ animated: Bool) {
        scrollToLastSubviewCalled = true
    }
    
    func resetStatus() {
        scrollToCenterSubviewCalled = false
        scrollToFirstSubviewCalled = false
        scrollToLastSubviewCalled = false
    }
}

class KSICFakeScrollerViewControllerDelegate: KSICScrollerViewControllerDelegate {
    func scrollerViewControllerDidGotoNextPage(_ viewController: KSICScrollerViewController) { }
    func scrollerViewControllerDidGotoPreviousPage(_ viewController: KSICScrollerViewController) { }
    func scrollerViewControllerDidFinishLayoutSubviews(_ viewController: KSICScrollerViewController) { }
    func scrollerViewControllerDidTappedImageView(at index: Int, viewController: KSICScrollerViewController) { }
    func scrollerViewControllerShouldShowActivityIndicator() -> Bool { return true }
    func scrollerViewControllerShowActivityIndicatorStyle() -> UIActivityIndicatorViewStyle { return .gray }
}
