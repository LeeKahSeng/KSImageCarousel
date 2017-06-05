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
    
    enum TestImage {
        case black
        case white
        case green
        case red
        case blue
        case gray
        
        var name: String {
            switch self {
            case .black:
                return "black"
            case .white:
                return "white"
            case .green:
                return "green"
            case .red:
                return "red"
            case .blue:
                return "blue"
            case .gray:
                return "gray"
            }
        }
    }
    
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
        let dummyModel = [createTestImage(.black),
                          createTestImage(.white),
                          createTestImage(.blue)]
        let dummyInitialPage = 1
        
        // Test KSICFiniteCoordinator
        let coordinator = try? KSICFiniteCoordinator(with: dummyModel, initialPage: dummyInitialPage)
        XCTAssertNotNil(coordinator)
        
        // Test KSICInfiniteCoordinator
        let coordinator2 = try? KSICInfiniteCoordinator(with: dummyModel, initialPage: dummyInitialPage)
        XCTAssertNotNil(coordinator2)
    }
    
    func testCoordinatorInitFail() {
        
        // Create test data
        let dummyModel = [createTestImage(.black),
                          createTestImage(.white),
                          createTestImage(.blue)]
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

        // Test KSICInfiniteCoordinator
        // Out of range
        XCTAssertThrowsError(try KSICInfiniteCoordinator(with: dummyModel, initialPage: dummyInitialPage)) { error in
            XCTAssertEqual(error as? CoordinatorError, CoordinatorError.pageOutOfRange)
        }
        
        // Empty model
        XCTAssertThrowsError(try KSICInfiniteCoordinator(with: [], initialPage: 0)) { error in
            XCTAssertEqual(error as? CoordinatorError, CoordinatorError.emptyModel)
        }
    }

    func testFiniteCoordonatorPageNavigation() {
        
        // Create test data
        let dummyModel = [createTestImage(.black),
                          createTestImage(.white),
                          createTestImage(.gray),
                          createTestImage(.red),
                          createTestImage(.green),
                          createTestImage(.blue)]
        
        let dummyInitialPage = 0
        
        let coordinator = try! KSICFiniteCoordinator(with: dummyModel, initialPage: dummyInitialPage)
        
        // Test initial view model value
        var currentPage = dummyInitialPage
        var expectedViewModel = [dummyModel[currentPage], dummyModel[currentPage + 1], dummyModel[currentPage + 2]]
        var actualViewModel = coordinator.carouselViewModel
        XCTAssertTrue(compare(viewModel1: expectedViewModel, viewModel2: actualViewModel))
        
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
        expectedViewModel = [dummyModel[currentPage - 2], dummyModel[currentPage - 1], dummyModel[currentPage]]
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
        expectedViewModel = [dummyModel[currentPage], dummyModel[currentPage + 1], dummyModel[currentPage + 2]]
        actualViewModel = coordinator.carouselViewModel
        XCTAssertTrue(compare(viewModel1: expectedViewModel, viewModel2: actualViewModel), "Expected view model: \(expectedViewModel), but get \(actualViewModel)")
    }

    func testFiniteCoordonatorPageNavigation_1elementInModel() {
        // Create test data
        let dummyModel = [createTestImage(.black)]
        let dummyInitialPage = 0
        
        let coordinator = try! KSICFiniteCoordinator(with: dummyModel, initialPage: dummyInitialPage)
     
        // Test initial view model value
        let currentPage = dummyInitialPage
        let expectedViewModel = [dummyModel[currentPage]]
        var actualViewModel = coordinator.carouselViewModel
        XCTAssertTrue(compare(viewModel1: expectedViewModel, viewModel2: actualViewModel), "Expected view model: \(expectedViewModel), but get \(actualViewModel)")
        
        // Go to next page 3 times
        let nextPageCount = 3
        for _ in 0..<nextPageCount {
            coordinator.nextPage()
        }
        
        // Test view model value
        actualViewModel = coordinator.carouselViewModel
        XCTAssertTrue(compare(viewModel1: expectedViewModel, viewModel2: actualViewModel), "Expected view model: \(expectedViewModel), but get \(actualViewModel)")
        
        
        // Go to previous page 2 times
        let prevPageCount = 2
        for _ in 0..<prevPageCount {
            coordinator.previousPage()
        }
        
        // Test view model value
        actualViewModel = coordinator.carouselViewModel
        XCTAssertTrue(compare(viewModel1: expectedViewModel, viewModel2: actualViewModel), "Expected view model: \(expectedViewModel), but get \(actualViewModel)")
    }

    func testInFiniteCoordonatorPageNavigation() {
        
        // Create test data
        let dummyModel = [createTestImage(.black),
                          createTestImage(.white),
                          createTestImage(.gray),
                          createTestImage(.red),
                          createTestImage(.green),
                          createTestImage(.blue)]
        let dummyInitialPage = 0
        
        let coordinator = try! KSICInfiniteCoordinator(with: dummyModel, initialPage: dummyInitialPage)
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
    
    func testInfiniteCoordonatorPageNavigation_1elementInModel() {
        // Create test data
        let dummyModel = [createTestImage(.black)]
        let dummyInitialPage = 0
        
        let coordinator = try! KSICInfiniteCoordinator(with: dummyModel, initialPage: dummyInitialPage)
        
        // Test initial view model value
        let currentPage = dummyInitialPage
        let expectedViewModel = [dummyModel[currentPage], dummyModel[currentPage], dummyModel[currentPage]]
        var actualViewModel = coordinator.carouselViewModel
        XCTAssertTrue(compare(viewModel1: expectedViewModel, viewModel2: actualViewModel), "Expected view model: \(expectedViewModel), but get \(actualViewModel)")
        
        // Go to next page 3 times
        let nextPageCount = 3
        for _ in 0..<nextPageCount {
            coordinator.nextPage()
        }
        
        // Test view model value
        actualViewModel = coordinator.carouselViewModel
        XCTAssertTrue(compare(viewModel1: expectedViewModel, viewModel2: actualViewModel), "Expected view model: \(expectedViewModel), but get \(actualViewModel)")
        
        
        // Go to previous page 2 times
        let prevPageCount = 2
        for _ in 0..<prevPageCount {
            coordinator.previousPage()
        }
        
        // Test view model value
        actualViewModel = coordinator.carouselViewModel
        XCTAssertTrue(compare(viewModel1: expectedViewModel, viewModel2: actualViewModel), "Expected view model: \(expectedViewModel), but get \(actualViewModel)")
    }

    
    // MARK: - Utilities
    func compare(viewModel1 vm1: [KSImageCarouselDisplayable], viewModel2 vm2: [KSImageCarouselDisplayable]) -> Bool {
        
        for i in 0..<vm1.count {
            let img1 = vm1[i] as! UIImage
            let img2 = vm2[i] as! UIImage
            
            if !compare(image1: img1, image2: img2) {
                return false
            }
        }
        
        return true
    }
    
    func compare(image1 img1: UIImage, image2 img2: UIImage) -> Bool {
        
        let data1 = UIImagePNGRepresentation(img1)!
        let data2 = UIImagePNGRepresentation(img2)!
        
        return data1 == data2
    }
    
    func createTestImage(_ img: TestImage) -> UIImage {
        return UIImage(named: img.name, in: Bundle(for: KSImageCarouselTests.self), compatibleWith: nil)!
    }
    
}
