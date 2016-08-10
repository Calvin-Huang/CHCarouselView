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
    
    private var canInfinite: Bool {
        return isInfinite && views.count > 1
    }
    
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
    
    private var timer: NSTimer?

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
        
        timer?.invalidate()
        timer = nil
    }
    
    override public func drawRect(rect: CGRect) {
        resetInfiniteContentShift()
        
        views
            .forEach {
                self.addSubview($0)
            }
        
        pageControl?.numberOfPages = views.count
        
        let viewsCountWithInfiniteMock = (canInfinite ? 2 : 0) + views.count
        
        self.contentSize = CGSize(width: CGFloat(viewsCountWithInfiniteMock) * self.bounds.width, height: self.bounds.height)
        self.contentOffset = canInfinite ? CGPoint(x: self.bounds.width, y: 0) : CGPointZero
    }
    
    // MARK: - Override Methods
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        guard let selectedCallback = selectedCallback else {
            return
        }
        
        selectedCallback(currentPage: currentPage)
    }
    
    // MARK: - KVO Delegate
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        // Check condition with tracking for only prepare view when still scrolling.
        if keyPath == "contentOffset" && canInfinite && self.tracking {
            guard let change = change, let oldOffset = change[NSKeyValueChangeOldKey]?.CGPointValue() else {
                return
            }
            
            let newOffset = self.contentOffset
            
            prepareViewForInfiniteInlusion(ScrollDirection(fromPoint: oldOffset, toPoint: newOffset))
            
        }
    }
    
    // MARK: - Selectors
    public func autoScrollToNextPage(_: AnyObject) {
        
    }
    
    // MARK: - Private Methods
    private func configure() {
        self.delegate = self
        self.pagingEnabled = true
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.scrollsToTop = false
        
        self.addObserver(self, forKeyPath: "contentOffset", options: .Old, context: nil)
        
        if canInfinite {
            timer = NSTimer(timeInterval: 0.2, target: self, selector: #selector(autoScrollToNextPage(_:)), userInfo: nil, repeats: true)
        }
    }
    
    private func prepareViewForInfiniteInlusion(direction: ScrollDirection) {
        let viewsCount = CGFloat(views.count)
        
        switch direction {
        case .Left:
            if self.contentOffset.x <= self.bounds.size.width {
                guard let lastView = views.last else {
                    return
                }
                
                lastView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
                
            } else if self.contentOffset.x >= viewsCount * self.bounds.size.width {
                guard let firstView = views.first else {
                    return
                }
                
                firstView.frame = CGRect(x: (viewsCount + 1) * self.bounds.size.width, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
                
            } else {
                resetInfiniteContentShift()
            }

        case .Right:
            if self.contentOffset.x >= viewsCount * self.bounds.size.width {
                guard let firstView = views.first else {
                    return
                }
                
                firstView.frame = CGRect(x: (viewsCount + 1) * self.bounds.size.width, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
                
            } else if self.contentOffset.x <= self.bounds.size.width {
                guard let lastView = views.last else {
                    return
                }
                
                lastView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
                
            } else {
                resetInfiniteContentShift()
            }
        case .Top:
            break
        case .Down:
            break
        default:
            break
        }
    }
    
    private func resetInfiniteContentShift() {
        views
            .enumerate()
            .forEach { (index: Int, view: UIView) in
                let indexShiftted = isInfinite ? index + 1 : index
                let viewOffset = CGPoint(x: CGFloat(indexShiftted) * self.bounds.width, y: 0)
                view.frame = CGRect(origin: viewOffset, size: self.bounds.size)
            }
    }
    
    private func shiftToRealViewPosition() {
        let viewsCount = CGFloat(views.count)
        
        if self.contentOffset.x <= 0 {
            self.contentOffset = CGPoint(x: viewsCount * self.bounds.size.width, y: 0)
            
            resetInfiniteContentShift()
            
        } else if self.contentOffset.x >= (viewsCount + 1) * self.bounds.size.width {
            self.contentOffset = CGPoint(x: self.bounds.size.width, y: 0)
            
            resetInfiniteContentShift()
        }

    }
}

// MARK: - ScrollViewDelegate
extension CarouselView: UIScrollViewDelegate {
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        let offsetX: Int = Int(scrollView.contentOffset.x)
        let width: Int = Int(self.bounds.width)
        
        let remainder: Int = offsetX % width
        var page: Int = offsetX / width + ((remainder > width / 2) ? 1 : 0)
        
        if canInfinite {
            if page == 0 {
                page = views.count - 1
                
            } else if page == views.count + 1 {
                page = 0
                
            } else {
                page = page - 1
            }
            
            shiftToRealViewPosition()
        }
        
        currentPage = page
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if canInfinite {
            resetInfiniteContentShift()
        }
    }
}
