//
//  DLHamburguerViewController.swift
//  DLHamburguerMenu
//
//  Created by Nacho on 4/3/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

/** 菜单外观方向 */
enum DLHamburguerMenuPlacement: Int {
    case Left = 0, Right, Top, Bottom
}

/** 菜单的视觉风格 */
enum DLHamburguerMenuBackgroundStyle: Int {
    case Light = 0, Dark = 1
    
    func toBarStyle() -> UIBarStyle {
        return UIBarStyle(rawValue: self.rawValue)!
    }
}

// Constants
private let kDLHamburguerMenuSpan: CGFloat = 50.0

/**
* dlhamburguerviewcontroller主要是VC管理内容视图控制器和视图控制器的菜单.
* 这些视图控制器将包含在主容器视图控制器中.
* menuviewcontroller将显示当平移或调用showmenuviewcontroller方法.
* contentviewcontroller将包含应用程序的主要内容的VC，也许UINavigationController.
*/
class DLHamburguerViewController: UIViewController {
    // pan gesture recognizer.
    var gestureRecognizer: UIPanGestureRecognizer?
    var gestureEnabled = true
    
    // appearance
    var overlayAlpha: CGFloat = 0.3                        // % 背景的黑暗衰落 (0.0 - 1.0)
    var animationDuration: NSTimeInterval = 0.35           // 菜单动画的持续时间.
    var desiredMenuViewSize: CGSize?                       // 如果设置，菜单视图大小将尝试坚持这些限制
    var actualMenuViewSize: CGSize = CGSizeZero            // 菜单视图的实际大小
    var menuVisible = false                                // hamburguer菜单当前是否可见（false 不可见）
    
    // delegate
    var delegate: DLHamburguerViewControllerDelegate?
    
    // settings
    var menuDirection: DLHamburguerMenuPlacement = .Left
    var menuBackgroundStyle: DLHamburguerMenuBackgroundStyle = .Dark
    
    // structure & hierarchy
    var containerViewController: DLHamburguerContainerViewController!
    private var _contentViewController: UIViewController!
    var contentViewController: UIViewController! {
        get {
            return _contentViewController
        }
        set {
            if _contentViewController == nil {
                _contentViewController = newValue
                return
            }
            // 删除旧的链接到以前的层次结构
            _contentViewController.removeFromParentViewController()
            _contentViewController.view.removeFromSuperview()
            
            // update hierarchy
            if newValue != nil {
                self.addChildViewController(newValue)
                newValue.view.frame = self.containerViewController.view.frame
                self.view.insertSubview(newValue.view, atIndex: 0)
                newValue.didMoveToParentViewController(self)
            }
            _contentViewController = newValue
            
            // update status bar appearance
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    private var _menuViewController: UIViewController!
    var menuViewController: UIViewController! {
        get {
            return _menuViewController
        }
        set {
            // 删除旧的链接到以前的层次结构
            if _menuViewController != nil {
               _menuViewController.view.removeFromSuperview()
               _menuViewController.removeFromParentViewController()
            }
            _menuViewController = newValue
            
            // 更新 hierarchy
            let frame = _menuViewController.view.frame
            _menuViewController.willMoveToParentViewController(nil)
            _menuViewController.removeFromParentViewController()
            _menuViewController.view.removeFromSuperview()
            _menuViewController = newValue
            if _menuViewController == nil { return }
            
            // 在容器视图层次结构中添加菜单
            self.containerViewController.addChildViewController(newValue)
            newValue.view.frame = frame
            self.containerViewController?.containerView?.addSubview(newValue.view)
            newValue.didMoveToParentViewController(self)
        }
    }
    
    // MARK: - Lifecycle
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupHamburguerViewController()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupHamburguerViewController()
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setupHamburguerViewController()
    }
    
    convenience init(contentViewController: UIViewController, menuViewController: UIViewController) {
        self.init()
        self.contentViewController = contentViewController
        self.menuViewController = menuViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hamburguerDisplayController(contentViewController, inFrame: self.view.bounds)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // 处置任何资源，可以重复使用.
    }
    
    // MARK: - VC management
    
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return self.contentViewController
    }
    
    override func childViewControllerForStatusBarHidden() -> UIViewController? {
        return self.contentViewController
    }
    
    // MARK: - Setup DLHamburguerViewController
    
    internal func setupHamburguerViewController() {
        // 初始化容器视图控制器
        containerViewController = DLHamburguerContainerViewController()
        containerViewController.hamburguerViewController = self
        
        // 初始化手势识别
        gestureRecognizer = UIPanGestureRecognizer(target: containerViewController!, action: "panGestureRecognized:")
        
    }
    
    // MARK: - 展示和管理菜单.
    /** 菜单的主要功能 */
    func showMenuViewController() {
        println("进入菜单")
        self.showMenuViewControllerAnimated(true, completion: nil)
    }
    
    /** 提供菜单的详细功能 */
    func showMenuViewControllerAnimated(animated: Bool, completion: ((Void) -> Void)? = nil) {
        // 通知菜单将显示
        delegate?.hamburguerViewController?(self, willShowMenuViewController: self.menuViewController)
        
        self.containerViewController.shouldAnimatePresentation = animated
        // 计算菜单大小
        adjustMenuSize()
        
        // 当前菜单控制器（屏幕变灰）
        self.hamburguerDisplayController(self.containerViewController, inFrame: self.contentViewController.view.frame)
        self.menuVisible = true
        
        // 呼叫完成程序.
        completion?()
    }
    
    func adjustMenuSize(forRotation: Bool = false) {
        var w: CGFloat = 0.0
        var h: CGFloat = 0.0
        
        if desiredMenuViewSize != nil { // 尝试调整到期望值
            w = desiredMenuViewSize!.width > 0 ? desiredMenuViewSize!.width : contentViewController.view.frame.size.width
            h = desiredMenuViewSize!.height > 0 ? desiredMenuViewSize!.height : contentViewController.view.frame.size.height
        } else { // 基于方向的菜单大小计算.
            var span: CGFloat = kDLHamburguerMenuSpan
            if forRotation { w = self.contentViewController.view.frame.size.height - span; h = self.contentViewController.view.frame.size.width
            }
            else { w = self.contentViewController.view.frame.size.width - span; h = self.contentViewController.view.frame.size.height
            }
        }
        self.actualMenuViewSize = CGSizeMake(w, h)
        
    }
    
    /** 隐藏菜单控制器 */
    func hideMenuViewControllerWithCompletion(completion: ((Void) -> Void)?) {
        if !self.menuVisible { completion?(); return }
        self.containerViewController.hideWithCompletion(completion)
    }
    
    func resizeMenuViewControllerToSize(size: CGSize) {
        self.containerViewController.resizeToSize(size)
    }
    
    // MARK: - 手势识别
    
    func panGestureRecognized (recognizer: UIPanGestureRecognizer) {
        self.delegate?.hamburguerViewController?(self, didPerformPanGesture: recognizer)
        if self.gestureEnabled {
            if recognizer.state == .Began {
                let point = recognizer.translationInView(self.view)
                if point.x > 0{
                    self.showMenuViewControllerAnimated(true, completion: nil)
                }
                
            }
            self.containerViewController.panGestureRecognized(recognizer)
        }
    }
    
    // MARK: - Rotation legacy support (iOS 7)
    
/**    override func shouldAutorotate() -> Bool { return self.contentViewController.shouldAutorotate() }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        // call super and inform delegate
        super.willAnimateRotationToInterfaceOrientation(toInterfaceOrientation, duration: duration)
        self.delegate?.hamburguerViewController?(self, willAnimateRotationToInterfaceOrientation: toInterfaceOrientation, duration: duration)
        // adjust size of menu if visible only.
        self.containerViewController.setContainerFrame(self.menuViewController.view.frame)
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        super.didRotateFromInterfaceOrientation(fromInterfaceOrientation)
        if !self.menuVisible { self.actualMenuViewSize = CGSizeZero }
        adjustMenuSize(forRotation: true)
    }*/
    
    // MARK: - Rotation (iOS 8)
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        // call super and inform delegate
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        delegate?.hamburguerViewController?(self, willTransitionToSize: size, withTransitionCoordinator: coordinator)
        // adjust menu size if visible
        coordinator.animateAlongsideTransition({ (context) -> Void in
            self.containerViewController.setContainerFrame(self.menuViewController.view.frame)
            }, completion: {(finalContext) -> Void in
                if !self.menuVisible { self.actualMenuViewSize = CGSizeZero }
                self.adjustMenuSize(forRotation: true)
        })
    }
    
}


/** 提出从hamburguer容器隐藏视图控制器的扩展. */
extension UIViewController {
    func hamburguerDisplayController(controller: UIViewController, inFrame frame: CGRect) {
        self.addChildViewController(controller)
        controller.view.frame = frame
        self.view.addSubview(controller.view)
        controller.didMoveToParentViewController(self)
    }
    
    func hamburguerHideController(controller: UIViewController) {
        controller.willMoveToParentViewController(nil)
        controller.view.removeFromSuperview()
        controller.removeFromParentViewController()
    }
    
    func findHamburguerViewController() -> DLHamburguerViewController? {
        var vc = self.parentViewController
        while vc != nil {
            // * as? 语法转换，把某类型当成某类型（强转）
            if let dlhvc = vc as? DLHamburguerViewController { return dlhvc }
            else if vc != nil && vc?.parentViewController != vc { vc = vc!.parentViewController }
            else { vc = nil }
        }
        return nil
    }
}

@objc protocol DLHamburguerViewControllerDelegate {
    optional func hamburguerViewController(hamburguerViewController: DLHamburguerViewController, didPerformPanGesture gestureRecognizer: UIPanGestureRecognizer)
    optional func hamburguerViewController(hamburguerViewController: DLHamburguerViewController, willShowMenuViewController menuViewController: UIViewController)
    optional func hamburguerViewController(hamburguerViewController: DLHamburguerViewController, didShowMenuViewController menuViewController: UIViewController)
    optional func hamburguerViewController(hamburguerViewController: DLHamburguerViewController, willHideMenuViewController menuViewController: UIViewController)
    optional func hamburguerViewController(hamburguerViewController: DLHamburguerViewController, didHideMenuViewController menuViewController: UIViewController)
    optional func hamburguerViewController(hamburguerViewController: DLHamburguerViewController, willTransitionToSize size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator)
    // Support for legacy iOS 7 rotation.
    optional func hamburguerViewController(hamburguerViewController: DLHamburguerViewController, willAnimateRotationToInterfaceOrientation toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval)
}