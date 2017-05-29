//
//  KSImageCarouselTests.swift
//  KSImageCarouselTests
//
//  Created by Lee Kah Seng on 24/05/2017.
//  Copyright © 2017 Lee Kah Seng. All rights reserved.
//

import XCTest
@testable import KSImageCarousel

class KSImageCarouselTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCoordinatorInitSuccessful() {
  
        // Create test data
        let dummyModel = ["1", "2", "3", "4"]
        let dummyInitialPage = 1
        
        // Test KSICFiniteCoordinator
        let coordinator = try? KSICFiniteCoordinator(with: dummyModel, initialPage: dummyInitialPage)
        XCTAssertNotNil(coordinator)
        
        // Test KSICInFiniteCoordinator
        let coordinator2 = try? KSICInFiniteCoordinator(with: dummyModel, initialPage: dummyInitialPage)
        XCTAssertNotNil(coordinator2)
    }
    
    func testCoordinatorInitFail() {
        
        // Create test data
        let dummyModel = ["1", "2", "3", "4"]
        let dummyInitialPage = 10
        
        // Test KSICFiniteCoordinator
        // Out of range
        XCTAssertThrowsError(try KSICFiniteCoordinator(with: dummyModel, initialPage: dummyInitialPage)) { error in
            XCTAssertEqual(error as? CoordinatorError, CoordinatorError.pageOutOfRange)
        }
        
        // Empty model
        XCTAssertThrowsError(try KSICFiniteCoordinator(with: [], initialPage: 0)) { error in
            XCTAssertEqual(error as? CoordinatorError, CoordinatorError.emptyModel)
        }

        // Test KSICInFiniteCoordinator
        // Out of range
        XCTAssertThrowsError(try KSICInFiniteCoordinator(with: dummyModel, initialPage: dummyInitialPage)) { error in
            XCTAssertEqual(error as? CoordinatorError, CoordinatorError.pageOutOfRange)
        }
        
        // Empty model
        XCTAssertThrowsError(try KSICInFiniteCoordinator(with: [], initialPage: 0)) { error in
            XCTAssertEqual(error as? CoordinatorError, CoordinatorError.emptyModel)
        }
    }
    
    func testFiniteCoordonatorPageNavigation() {
        
        // Create test data
        let dummyModel = ["1", "2", "3", "4", "5", "6"]
        let dummyInitialPage = 0
        
        let coordinator = try! KSICFiniteCoordinator(with: dummyModel, initialPage: dummyInitialPage)
        
        // Test initial view model value
        var currentPage = dummyInitialPage
        var expectedViewModel = [nil, dummyModel[currentPage], dummyModel[currentPage + 1]]
        var actualViewModel = coordinator.carouselViewModel
        XCTAssertTrue(compare(viewModel1: expectedViewModel, viewModel2: actualViewModel), "Expected view model: \(expectedViewModel), but get \(actualViewModel)")
        
        // Go to next page 3 times
        var nextPageCount = 3
        for _ in 0..<nextPageCount {
            coordinator.nextPage()
        }
        
        // Test view model value
        currentPage += nextPageCount
        expectedViewModel = [dummyModel[currentPage - 1], dummyModel[currentPage], dummyModel[currentPage + 1]]
        actualViewModel = coordinator.carouselViewModel
        XCTAssertTrue(compare(viewModel1: expectedViewModel, viewModel2: actualViewModel), "Expected view model: \(expectedViewModel), but get \(actualViewModel)")
        
        // Go to next page 5 times
        nextPageCount = 5
        for _ in 0..<nextPageCount {
            coordinator.nextPage()
        }
        
        // Test view model value
        currentPage = dummyModel.count - 1
        expectedViewModel = [dummyModel[currentPage - 1], dummyModel[currentPage], nil]
        actualViewModel = coordinator.carouselViewModel
        XCTAssertTrue(compare(viewModel1: expectedViewModel, viewModel2: actualViewModel), "Expected view model: \(expectedViewModel), but get \(actualViewModel)")
        
        
        // Go to previous page 2 times
        var prevPageCount = 2
        for _ in 0..<prevPageCount {
            coordinator.previousPage()
        }
        
        // Test view model value
        currentPage -= prevPageCount
        expectedViewModel = [dummyModel[currentPage - 1], dummyModel[currentPage], dummyModel[currentPage + 1]]
        actualViewModel = coordinator.carouselViewModel
        XCTAssertTrue(compare(viewModel1: expectedViewModel, viewModel2: actualViewModel), "Expected view model: \(expectedViewModel), but get \(actualViewModel)")
        
        
        // Go to previous page 10 times
        prevPageCount = 10
        for _ in 0..<prevPageCount {
            coordinator.previousPage()
        }
        
        // Test view model value
        currentPage = 0
        expectedViewModel = [nil, dummyModel[currentPage], dummyModel[currentPage + 1]]
        actualViewModel = coordinator.carouselViewModel
        XCTAssertTrue(compare(viewModel1: expectedViewModel, viewModel2: actualViewModel), "Expected view model: \(expectedViewModel), but get \(actualViewModel)")
    }
    
    func testInFiniteCoordonatorPageNavigation() {
        
        // Create test data
        let dummyModel = ["1", "2", "3", "4", "5", "6"]
        let dummyInitialPage = 0
        
        let coordinator = try! KSICInFiniteCoordinator(with: dummyModel, initialPage: dummyInitialPage)
        let lastPage = dummyModel.count - 1
        
        // Test initial view model value
        var currentPage = dummyInitialPage
        var expectedViewModel = [dummyModel[lastPage], dummyModel[currentPage], dummyModel[currentPage + 1]]
        var actualViewModel = coordinator.carouselViewModel
        XCTAssertTrue(compare(viewModel1: expectedViewModel, viewModel2: actualViewModel), "Expected view model: \(expectedViewModel), but get \(actualViewModel)")

        // Go to next page 3 times
        var nextPageCount = 3
        for _ in 0..<nextPageCount {
            coordinator.nextPage()
        }
        
        // Test view model value
        currentPage += nextPageCount
        expectedViewModel = [dummyModel[currentPage - 1], dummyModel[currentPage], dummyModel[currentPage + 1]]
        actualViewModel = coordinator.carouselViewModel
        XCTAssertTrue(compare(viewModel1: expectedViewModel, viewModel2: actualViewModel), "Expected view model: \(expectedViewModel), but get \(actualViewModel)")

        
        // Go to next page 5 times
        nextPageCount = 5
        for _ in 0..<nextPageCount {
            coordinator.nextPage()
        }
        
        // Test view model value
        currentPage = 2
        expectedViewModel = [dummyModel[currentPage - 1], dummyModel[currentPage], dummyModel[currentPage + 1]]
        actualViewModel = coordinator.carouselViewModel
        XCTAssertTrue(compare(viewModel1: expectedViewModel, viewModel2: actualViewModel), "Expected view model: \(expectedViewModel), but get \(actualViewModel)")

        
        // Go to previous page 4 times
        var prevPageCount = 4
        for _ in 0..<prevPageCount {
            coordinator.previousPage()
        }
        
        // Test view model value
        currentPage = 4
        expectedViewModel = [dummyModel[currentPage - 1], dummyModel[currentPage], dummyModel[currentPage + 1]]
        actualViewModel = coordinator.carouselViewModel
        XCTAssertTrue(compare(viewModel1: expectedViewModel, viewModel2: actualViewModel), "Expected view model: \(expectedViewModel), but get \(actualViewModel)")


        // Go to previous page 10 times
        prevPageCount = 10
        for _ in 0..<prevPageCount {
            coordinator.previousPage()
        }
        
        // Test view model value
        currentPage = 0
        expectedViewModel = [dummyModel[lastPage], dummyModel[currentPage], dummyModel[currentPage + 1]]
        actualViewModel = coordinator.carouselViewModel
        XCTAssertTrue(compare(viewModel1: expectedViewModel, viewModel2: actualViewModel), "Expected view model: \(expectedViewModel), but get \(actualViewModel)")
    }

    
    // MARK: - Utilities
    func compare(viewModel1 vm1: [String?], viewModel2 vm2: [String?]) -> Bool {
        return (vm1[0] == vm2[0] &&
                vm1[1] == vm2[1] &&
                vm1[2] == vm2[2])
    }
    
}
