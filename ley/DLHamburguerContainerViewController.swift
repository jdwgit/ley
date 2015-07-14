//
//  DLHamburguerContainerViewController.swift
//  DLHamburguerMenu
//
//  Created by Nacho on 4/3/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

private let kDLHamburguerInitialContainerViewWidth: CGFloat = 250

/**
* 这个类包含的主要元素hamburguer容器视图：菜单和内容.
*/
class DLHamburguerContainerViewController: UIViewController {
    // structure
    // * weak 当不被引用时可以释放内存
    weak var hamburguerViewController: DLHamburguerViewController!      // root hamburguer view controller
    weak var viewController: shouye!
    var containerView: UIView!                                          // view containing the main content
    var containerOrigin = CGPointZero                                   // origin of container view
    var shouldAnimatePresentation = false                               // true if menu presentation should be animated.
    var backgroundFadingView: UIView!                                   // background view that fades content when menu shows up
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 准备背景 view
        backgroundFadingView = UIView(frame: CGRectNull)
        backgroundFadingView.backgroundColor = UIColor.blackColor()
        backgroundFadingView.alpha = 0.0
        view.addSubview(backgroundFadingView)
        // * 添加背景的点击事件（点击推出菜单）
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "tapGestureRecognized:")
        backgroundFadingView.addGestureRecognizer(gestureRecognizer)
        
        // 准备容器 view
        // * CGRectMake(横坐标,纵坐标,宽度,高度)
        containerView = UIView(frame: CGRectMake(0, 0, kDLHamburguerInitialContainerViewWidth, view.frame.size.height))
        // * clipsToBounds 如果子视图边界越过父视图将被剪掉（true）
        containerView.clipsToBounds = true
        self.view.addSubview(containerView)
        
        // 我们需要制定一个工具栏，菜单控制的内容不重叠的topbar.
        let toolbar = UIToolbar(frame: self.view.bounds)
        toolbar.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        toolbar.barStyle = self.hamburguerViewController.menuBackgroundStyle.toBarStyle()
        self.containerView.addSubview(toolbar)
        
        // 添加菜单控制器
        if self.hamburguerViewController.menuViewController != nil {
            self.addChildViewController(self.hamburguerViewController.menuViewController)
            self.hamburguerViewController.menuViewController.view.frame = self.containerView.bounds
            self.containerView.addSubview(self.hamburguerViewController.menuViewController.view)
            self.hamburguerViewController.menuViewController.didMoveToParentViewController(self)
        }
        self.view.addGestureRecognizer(self.hamburguerViewController.gestureRecognizer!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        println("侧滑菜单动画初始视图")
        if !hamburguerViewController.menuVisible {
            hamburguerViewController.menuViewController.view.frame = containerView.bounds
            switch (hamburguerViewController.menuDirection) {
            case .Left:
                self.setContainerFrame(CGRectMake(-self.hamburguerViewController.actualMenuViewSize.width, 0, self.hamburguerViewController.actualMenuViewSize.width, self.hamburguerViewController.actualMenuViewSize.height))
            case .Right:
                self.setContainerFrame(CGRectMake(self.view.frame.size.width, 0, self.hamburguerViewController.actualMenuViewSize.width, self.hamburguerViewController.actualMenuViewSize.height))
            case .Top:
                self.setContainerFrame(CGRectMake(0, -self.hamburguerViewController.actualMenuViewSize.height, self.hamburguerViewController.actualMenuViewSize.width, self.hamburguerViewController.actualMenuViewSize.height))
            case .Bottom:
                self.setContainerFrame(CGRectMake(0, self.view.frame.size.height, self.hamburguerViewController.actualMenuViewSize.width, self.hamburguerViewController.actualMenuViewSize.height))
            }
        }
        // 如果我们要做动画演示，现在就展示出来.
        if self.shouldAnimatePresentation { self.show() }
    }
    
    
    // MARK: - Frame, appearance and size adjustments
    
    func setContainerFrame(frame: CGRect) {
        var x:CGFloat = 0
        var y:CGFloat = 0
        var w:CGFloat = 0
        var h:CGFloat = 0
        // * 变灰区域视图
        // 计算覆盖阿尔法背景视图帧
        switch (hamburguerViewController.menuDirection) {
        case .Left:
            x = frame.origin.x + frame.size.width
            y = 0
            w = self.view.frame.width - frame.size.width - frame.origin.x
            h = self.view.frame.size.height
        case .Right:
            x = 0
            y = 0
            w = frame.origin.x
            h = self.view.frame.size.height
        case .Top:
            x = frame.origin.x
            y = frame.origin.y + frame.size.height
            w = frame.size.width
            h = self.view.frame.size.height
        case .Bottom:
            x = frame.origin.x
            y = 0
            w = frame.size.width
            h = frame.origin.y
        }
        // 分配覆盖和容器视图
        let shadowFrame = CGRectMake(x, y, w, h)
        self.backgroundFadingView.frame = shadowFrame
        self.containerView.frame = frame
    }
    
    func resizeToSize(size: CGSize) {
        var newFrame = CGRectZero
        // adjust size depending on menu direction.
        switch (self.hamburguerViewController.menuDirection) {
        case .Left:
            newFrame = CGRectMake(0, 0, size.width, size.height)
        case .Right:
            newFrame = CGRectMake(self.view.frame.size.width - size.width, 0, size.width, size.height)
        case .Top:
            newFrame = CGRectMake(0, 0, size.width, size.height)
        case .Bottom:
            newFrame = CGRectMake(0, self.view.frame.size.height - size.height, size.width, size.height)
        }
        
        // animated resizing.
        UIView.animateWithDuration(self.hamburguerViewController.animationDuration, animations: { () -> Void in
            self.setContainerFrame(newFrame)
            self.backgroundFadingView.alpha = self.hamburguerViewController.overlayAlpha
        })
    }
    
    // MARK: - Show and Hide the menu.
    
    /** Shows the menu. */
    func show() {
        println("侧滑菜单动画结束视图")
        // calculate the final frame for the menu
        var finalFrame = CGRectZero
        switch (self.hamburguerViewController.menuDirection) {
        case .Left:
//            finalFrame = CGRectMake(0, 0, self.hamburguerViewController.actualMenuViewSize.width*0.5, self.hamburguerViewController.actualMenuViewSize.height)
            finalFrame = CGRectMake(0, 0, 150, self.hamburguerViewController.actualMenuViewSize.height)
        case .Right:
            finalFrame = CGRectMake(self.view.frame.size.width - self.hamburguerViewController.actualMenuViewSize.width, 0, self.hamburguerViewController.actualMenuViewSize.width, self.hamburguerViewController.actualMenuViewSize.height)
        case .Top:
            finalFrame = CGRectMake(0, 0, self.hamburguerViewController.actualMenuViewSize.width, self.hamburguerViewController.actualMenuViewSize.height)
        case .Bottom:
            finalFrame = CGRectMake(0, self.view.frame.size.height - self.hamburguerViewController.actualMenuViewSize.height, self.hamburguerViewController.actualMenuViewSize.width, self.hamburguerViewController.actualMenuViewSize.height)
        }
        
        // set final frame animated
        UIView.animateWithDuration(self.hamburguerViewController.animationDuration, animations: { () -> Void in
            self.setContainerFrame(finalFrame)
            self.backgroundFadingView.alpha = self.hamburguerViewController.overlayAlpha
            }) { (success) -> Void in
                // inform the delegate.
                if self.hamburguerViewController.delegate != nil {
                    self.hamburguerViewController.delegate?.hamburguerViewController?(self.hamburguerViewController, didShowMenuViewController: self.hamburguerViewController.menuViewController)
                }
        }
    }
    
    /** Hides the menu. */
    func hide() {
        hideWithCompletion(nil)
    }
    
    /** Hides the menu with a completion closure. */
    func hideWithCompletion(completion: ((Void) -> Void)?) {
        println("侧滑菜单退回动画结束视图")
        // inform the delegate that the menu will hide
        self.hamburguerViewController.delegate?.hamburguerViewController?(self.hamburguerViewController, willHideMenuViewController: self.hamburguerViewController.menuViewController)
        
        // calculate new frame depending on menu direction
        var newFrame = CGRectZero
        switch (hamburguerViewController.menuDirection) {
        case .Left:
            newFrame = CGRectMake(-self.hamburguerViewController.actualMenuViewSize.width, 0, self.hamburguerViewController.actualMenuViewSize.width, self.hamburguerViewController.actualMenuViewSize.height)
        case .Right:
            newFrame = CGRectMake(self.view.frame.size.width, 0, self.hamburguerViewController.actualMenuViewSize.width, self.hamburguerViewController.actualMenuViewSize.height)
        case .Top:
            newFrame = CGRectMake(0, -self.hamburguerViewController.actualMenuViewSize.height, self.hamburguerViewController.actualMenuViewSize.width, self.hamburguerViewController.actualMenuViewSize.height)
        case .Bottom:
            newFrame = CGRectMake(0, self.view.frame.size.height, self.hamburguerViewController.actualMenuViewSize.width, self.hamburguerViewController.actualMenuViewSize.height)
        }
        
        // animate hiding.
        UIView.animateWithDuration(self.hamburguerViewController.animationDuration, animations: { () -> Void in
            self.setContainerFrame(newFrame)
            self.backgroundFadingView.alpha = 0
            }) { (success) -> Void in
                self.hamburguerViewController.menuVisible = false
                self.hamburguerViewController.hamburguerHideController(self)
                self.hamburguerViewController.delegate?.hamburguerViewController?(self.hamburguerViewController, didHideMenuViewController: self.hamburguerViewController.menuViewController)
                completion?()
        }
    }
    
    // MARK: - 手势识别
    // TAP: hide the menu
    func tapGestureRecognized(recognizer: UITapGestureRecognizer) {
        self.hide()
    }
    
    // PAN: animate menu appearance/dissapearace with the menu.
    func panGestureRecognized(recognizer: UIPanGestureRecognizer) {
        // inform the delegate
        self.hamburguerViewController.delegate?.hamburguerViewController?(self.hamburguerViewController, didPerformPanGesture: recognizer)
        // is the gesture recognizer enabled?
        if !self.hamburguerViewController.gestureEnabled { return }
        
        // React to recognizer
        let point = recognizer.translationInView(self.view)
        
        // start: 设置初始容器原点
        if recognizer.state == .Began { self.containerOrigin = self.containerView.frame.origin }
            // changed: adjust frame
        else if recognizer.state == .Changed {
            var frame = self.containerView.frame
            
            switch (hamburguerViewController.menuDirection) {
            case .Left:
                frame.origin.x = self.containerOrigin.x + point.x
                if frame.origin.x > 0 {
                    frame.origin.x = 0
                    if self.hamburguerViewController.desiredMenuViewSize == nil {
                        frame.size.width = self.hamburguerViewController.actualMenuViewSize.width + self.containerOrigin.x + point.x
                        if frame.size.width > self.view.frame.size.width { frame.size.width = self.view.frame.size.width }
                    }
                }
            case .Right:
                frame.origin.x = self.containerOrigin.x + point.x
                if frame.origin.x < self.view.frame.size.width - self.hamburguerViewController.actualMenuViewSize.width {
                    frame.origin.x = self.view.frame.size.width - self.hamburguerViewController.actualMenuViewSize.width
                    if self.hamburguerViewController.desiredMenuViewSize == nil {
                        frame.origin.x = self.containerOrigin.x + point.x
                        if frame.origin.x < 0 { frame.origin.x = 0 }
                        frame.size.width = self.view.frame.size.width - frame.origin.x
                    }
                }
            case .Top:
                frame.origin.y = self.containerOrigin.y + point.y
                if frame.origin.y > 0 {
                    frame.origin.y = 0
                    
                    if self.hamburguerViewController.desiredMenuViewSize == nil {
                        frame.size.height = self.hamburguerViewController.actualMenuViewSize.height + self.containerOrigin.y + point.y
                        if frame.size.height > self.view.frame.size.height { frame.size.height = self.view.frame.size.height }
                    }
                }
            case .Bottom:
                frame.origin.y = self.containerOrigin.y + point.y
                if frame.origin.y < self.view.frame.size.height - self.hamburguerViewController.actualMenuViewSize.height {
                    frame.origin.y = self.view.frame.size.height - self.hamburguerViewController.actualMenuViewSize.height
                    
                    if self.hamburguerViewController.desiredMenuViewSize == nil {
                        frame.origin.y = self.containerOrigin.y + point.y
                        if frame.origin.y < 0 { frame.origin.y = 0 }
                        frame.size.height = self.view.frame.size.height - frame.origin.y
                    }
                }
            }
            self.setContainerFrame(frame)
        }
            
            // end: 决定是否打开或关闭该位置的菜单
        else if recognizer.state == .Ended {
            switch (hamburguerViewController.menuDirection) {
            case .Left:
                if recognizer.velocityInView(self.view).x < 0 { self.hide() }
                else { self.show() }
            case .Right:
                if recognizer.velocityInView(self.view).x < 0 { self.show() }
                else { self.hide() }
            case .Top:
                if recognizer.velocityInView(self.view).y < 0 { self.hide() }
                else { self.show() }
            case .Bottom:
                if recognizer.velocityInView(self.view).y < 0 { self.show() }
                else { self.hide() }
            }
        }
    }
    
    // MARK: - Rotation and transition reacting.
    
    func fixLayoutWithDuration(duration: NSTimeInterval) {
        var newFrame = CGRectZero
        switch (hamburguerViewController.menuDirection) {
        case .Left:
            newFrame = CGRectMake(0, 0, self.hamburguerViewController.actualMenuViewSize.width, self.hamburguerViewController.actualMenuViewSize.height)
        case .Right:
            newFrame = CGRectMake(self.view.frame.size.width - self.hamburguerViewController.actualMenuViewSize.width, 0, self.hamburguerViewController.actualMenuViewSize.width, self.hamburguerViewController.actualMenuViewSize.height)
        case .Top:
            newFrame = CGRectMake(0, 0, self.hamburguerViewController.actualMenuViewSize.width, self.hamburguerViewController.actualMenuViewSize.height)
        case .Bottom:
            newFrame = CGRectMake(0, self.view.frame.size.height - self.hamburguerViewController.actualMenuViewSize.height, self.hamburguerViewController.actualMenuViewSize.width, self.hamburguerViewController.actualMenuViewSize.height)
        }
        self.setContainerFrame(newFrame)
        backgroundFadingView.alpha = hamburguerViewController.overlayAlpha
    }
    
    // iOS7 Rotation legacy support.
/**    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willAnimateRotationToInterfaceOrientation(toInterfaceOrientation, duration: duration)
        self.fixLayoutWithDuration(duration)
    }*/
    
    // iOS 8 Transition.
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        self.fixLayoutWithDuration(coordinator.transitionDuration())
    }
    
    
}

extension UIViewController {
    func findsHamburguerViewController() -> DLHamburguerContainerViewController? {
        var vc = self.parentViewController
        while vc != nil {
            // * as? 语法转换，把某类型当成某类型（强转）
            if let dlhvc = vc as? DLHamburguerContainerViewController { return dlhvc }
            else if vc != nil && vc?.parentViewController != vc { vc = vc!.parentViewController }
            else { vc = nil }
        }
        return nil
    }
}
