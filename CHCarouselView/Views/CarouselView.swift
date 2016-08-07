//
//  CarouselView.swift
//  CHCarouselView
//
//  Created by Calvin on 8/5/16.
//  Copyright © 2016 CapsLock. All rights reserved.
//

import UIKit

public class CarouselView: UIScrollView {
    @IBOutlet weak var pageControl: UIPageControl?
    @IBOutlet public var views: [UIView] = []
    
    @IBInspectable public var isInfinite: Bool = false
    
    public var currentPage: Int {
        set {
            switch pageControl {
            case .None:
                self.currentPage = newValue
            case .Some(let pageControl):
                pageControl.currentPage = newValue
            }
        }
        
        get {
            switch pageControl {
            case .None:
                return self.currentPage
            case .Some(let pageControl):
                return pageControl.currentPage
            }
        }
    }
    public var selectedCallback: ((currentPage: Int) -> ())?
    
    private enum ScrollDirection {
        case None
        case Top
        case Right
        case Down
        case Left
        
        init(fromPoint: CGPoint, toPoint: CGPoint) {
            if fromPoint.x - toPoint.x < 0 && fromPoint.y == toPoint.y {
                self = .Left
                
            } else if fromPoint.x - toPoint.x > 0 && fromPoint.y == toPoint.y {
                self = .Right
                
            } else if fromPoint.x == toPoint.x && fromPoint.y - toPoint.y < 0 {
                self = .Down
                
            } else if fromPoint.x == toPoint.x && fromPoint.y - toPoint.y > 0 {
                self = .Top
                
            } else {
                self = .None
            }
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.configure()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.configure()
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    override public func drawRect(rect: CGRect) {
        views
            .enumerate()
            .forEach { (index: Int, view: UIView) in
                let viewOffset = CGPoint(x: CGFloat(index) * self.bounds.width, y: 0)
                view.frame = CGRect(origin: viewOffset, size: self.bounds.size)
            
                self.addSubview(view)
            }
        
        pageControl?.numberOfPages = views.count
        
        self.contentSize = CGSize(width: CGFloat(views.count) * self.bounds.width, height: self.bounds.height)
    }
    
    // MARK: - KVO Delegate
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "contentOffset" {
            
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    // MARK: - Private Methods
    private func configure() {
        self.delegate = self
        self.pagingEnabled = true
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.scrollsToTop = false
        
        self.addObserver(self, forKeyPath: "contentOffset", options: .Old, context: nil)
    }
}

// MARK: - ScrollViewDelegate
extension CarouselView: UIScrollViewDelegate {
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        let remainder: CGFloat = scrollView.contentOffset.x % self.bounds.width
        currentPage = Int(scrollView.contentOffset.x / self.bounds.size.width + ((remainder > self.bounds.size.width / 2) ? 1 : 0))
    }
}
