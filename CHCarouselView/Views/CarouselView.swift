//
//  CarouselView.swift
//  CHCarouselView
//
//  Created by Calvin on 8/5/16.
//  Copyright © 2016 CapsLock. All rights reserved.
//

import UIKit

open class CarouselView: UIScrollView {
    @IBOutlet weak var pageControl: UIPageControl?
    @IBOutlet open var views: [UIView] = []
    
    @IBInspectable open var isInfinite: Bool = false
    @IBInspectable open var interval: Double = 0
    @IBInspectable open var animationDuration: Double = 0.3
    
    open var currentPage: Int {
        set {
            switch pageControl {
            case .none:
                self.currentPage = newValue
            case .some(let pageControl):
                pageControl.currentPage = newValue
            }
        }
        
        get {
            switch pageControl {
            case .none:
                return self.currentPage
            case .some(let pageControl):
                return pageControl.currentPage
            }
        }
    }
    open var selected: ((_ currentPage: Int) -> Void)?
    open var isPaused: Bool {
        return timer == nil
    }
    
    fileprivate var canInfinite: Bool {
        return isInfinite && views.count > 1
    }
    
    fileprivate enum ScrollDirection {
        case none
        case top
        case right
        case down
        case left
        
        init(fromPoint: CGPoint, toPoint: CGPoint) {
            if fromPoint.x - toPoint.x < 0 && fromPoint.y == toPoint.y {
                self = .left
                
            } else if fromPoint.x - toPoint.x > 0 && fromPoint.y == toPoint.y {
                self = .right
                
            } else if fromPoint.x == toPoint.x && fromPoint.y - toPoint.y < 0 {
                self = .down
                
            } else if fromPoint.x == toPoint.x && fromPoint.y - toPoint.y > 0 {
                self = .top
                
            } else {
                self = .none
            }
        }
    }
    
    fileprivate var timer: Timer?

    // MARK: Initializers
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
    
    // MARK: UIView Delegate
    open override func draw(_ rect: CGRect) {
        resetInfiniteContentShift()
        
        views
            .forEach {
                self.addSubview($0)
            }
        
        pageControl?.numberOfPages = views.count
        
        let viewsCountWithInfiniteMock = (canInfinite ? 2 : 0) + views.count
        
        self.contentSize = CGSize(width: CGFloat(viewsCountWithInfiniteMock) * self.bounds.width, height: self.bounds.height)
        self.contentOffset = canInfinite ? CGPoint(x: self.bounds.width, y: 0) : CGPoint.zero
        
        if canInfinite && interval > 0 {
            timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(autoScrollToNextPage(_:)), userInfo: nil, repeats: true)
        }
    }
    
    // MARK: - Override Methods
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        selected?(currentPage)
    }
    
    // MARK: - KVO Delegate
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        // Check condition with tracking for only prepare view when still scrolling.
        if keyPath == "contentOffset" && canInfinite && self.isTracking {
            guard let change = change, let oldOffset = (change[NSKeyValueChangeKey.oldKey] as AnyObject?)?.cgPointValue else {
                return
            }
            
            let newOffset = self.contentOffset
            
            prepareViewForInfiniteInlusion(ScrollDirection(fromPoint: oldOffset, toPoint: newOffset))
        }
    }
    
    // MARK: - Selectors
    internal func autoScrollToNextPage(_: AnyObject) {
        UIView.animate(withDuration: animationDuration, animations: { 
            var nextPage = self.currentPage + 1
            
            if self.canInfinite {
                nextPage = nextPage + 1
                
            } else if nextPage >= self.views.count {
                nextPage = 0
            }
            
            self.contentOffset = CGPoint(x: CGFloat(nextPage) * self.bounds.width, y: 0)
        }) 
    }
    
    // MARK: - Public Methods
    open func pause() {
        guard let _ = timer else { return }
        
        timer?.invalidate()
        timer = nil
    }
    
    open func start() {
        if let _ = timer { return }
        
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(autoScrollToNextPage(_:)), userInfo: nil, repeats: true)
    }
    
    // MARK: - Private Methods
    fileprivate func configure() {
        self.delegate = self
        self.isPagingEnabled = true
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.scrollsToTop = false
        
        self.addObserver(self, forKeyPath: "contentOffset", options: .old, context: nil)
    }
    
    fileprivate func prepareViewForInfiniteInlusion(_ direction: ScrollDirection) {
        let viewsCount = CGFloat(views.count)
        
        switch direction {
        case .left:
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

        case .right:
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
        case .top:
            break
        case .down:
            break
        default:
            break
        }
    }
    
    fileprivate func resetInfiniteContentShift() {
        views
            .enumerated()
            .forEach { (index: Int, view: UIView) in
                let indexShiftted = isInfinite ? index + 1 : index
                let viewOffset = CGPoint(x: CGFloat(indexShiftted) * self.bounds.width, y: 0)
                view.frame = CGRect(origin: viewOffset, size: self.bounds.size)
            }
    }
    
    fileprivate func shiftToRealViewPosition() {
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
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if canInfinite {
            resetInfiniteContentShift()
        }
    }
}
