//
//  CHCarouselViewUITests.swift
//  CHCarouselViewUITests
//
//  Created by Calvin on 8/5/16.
//  Copyright © 2016 CapsLock. All rights reserved.
//

import XCTest
import Kingfisher

@testable import CHCarouselView

class CHCarouselViewUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_selectable() {
        app.scrollViews.element.tap()
        
        let alertView = app.alerts.element
        
        XCTAssertTrue(alertView.staticTexts["You selected page: 0 in carousel."].exists, "CarouselView should be selectable and pop alert.")
    }
    
    func test_autoSlide() {
        let xctExpectation = expectation(description: "Wait for carousel auto slide.")
        let carouselView = app.scrollViews.element
        let alertView = self.app.alerts.element
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 12.5) {
            carouselView.tap()
            
            XCTAssertTrue(alertView.staticTexts["You selected page: 3 in carousel."].exists, "CarouselView should auto slides to last view.")
            
            alertView.buttons["OK"].tap()
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 16.5) {
            carouselView.tap()
            
            XCTAssertTrue(alertView.staticTexts["You selected page: 0 in carousel."].exists, "CarouselView should auto slides to first view.")
            
            alertView.buttons["OK"].tap()
            
            xctExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 30.0) { e in
            XCTAssertTrue(e == nil, "Everything not completed in 30.0 sec.")
        }
    }
    
    func test_changeContentView() {
        let xctExpectation = expectation(description: "Wait for carousel auto slide.")
        let carouselView = self.app.scrollViews.element
        let alertView = self.app.alerts.element
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4.5) { [unowned self] in
            carouselView.tap()
            
            XCTAssertTrue(alertView.staticTexts["You selected page: 1 in carousel."].exists, "CarouselView should auto slides to second view.")
            
            alertView.buttons["OK"].tap()
            
            self.app.buttons["Change Content To Colored Views"].tap()
            carouselView.tap()
            
            XCTAssertTrue(alertView.staticTexts["You selected page: 0 in carousel."].exists, "CarouselView should reset to first view.")
            alertView.buttons["OK"].tap()
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 12.5) {
            carouselView.tap()
            
            XCTAssertTrue(alertView.staticTexts["You selected page: 1 in carousel."].exists, "CarouselView should auto slides to second view after change content.")
            
            xctExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 20.0) { e in
            XCTAssertTrue(e == nil, "Everything not completed in 10.0 sec.")
        }
    }
}
