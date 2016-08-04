//
//  CarouselView.swift
//  CHCarouselView
//
//  Created by Calvin on 8/5/16.
//  Copyright © 2016 CapsLock. All rights reserved.
//

import UIKit

public class CarouselView: UIScrollView {
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet public var views: [UIView] = []
    
    public var currentPage: Int = 0
    public var selectedCallback: ((currentPage: Int) -> ())?

    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.configure()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.configure()
    }
    
    override public func drawRect(rect: CGRect) {
    }
    
    // MARK: - Private Methods
    private func configure() {
        self.delegate = self
        self.pagingEnabled = true
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.scrollsToTop = false
    }
}

extension CarouselView: UIScrollViewDelegate {
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        
    }
}
