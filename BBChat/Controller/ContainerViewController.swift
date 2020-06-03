//
//  ContainerViewController.swift
//  BBChat
//
//  Created by Ben on 2020/6/3.
//  Copyright © 2020 Benben. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {

    let contentContainer = UIView()
    let menuContainer = UIView()
    let menuVc = MenuViewController()
    let messageListVc = UINavigationController(rootViewController: MessageListViewController())
    
    var contentOverlay: UIView?
    var panGestureRecognizer: UIPanGestureRecognizer?
    var menuLeadingConstraint: NSLayoutConstraint?
    
    var isMenuShowing: Bool = false
    
    var menuName: String? {
        didSet {
            menuVc.name = menuName
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configSubviews()
        configureGesturesRecognizer()
    }
    
    private func configSubviews() {
        view.addSubview(contentContainer)
        view.addSubview(menuContainer)
        
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contentContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        contentContainer.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        menuContainer.translatesAutoresizingMaskIntoConstraints = false
        menuContainer.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        menuContainer.trailingAnchor.constraint(equalTo: contentContainer.leadingAnchor).isActive = true
        menuContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        menuContainer.widthAnchor.constraint(equalToConstant: 260).isActive = true
        menuLeadingConstraint = menuContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: -260)
        menuLeadingConstraint?.isActive = true
        
        load(messageListVc, on: contentContainer)
        load(menuVc, on: menuContainer)
    }
    
    private func configureGesturesRecognizer() {
        // The gesture will be added anyway, its delegate will tell whether it should be recognized
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ContainerViewController.handlePanGesture(_:)))
        panGesture.delegate = self
        panGestureRecognizer = panGesture
        view.addGestureRecognizer(panGesture)
    }
    
    @objc func hideMenu() {
        menuLeadingConstraint?.constant = -260
        hideOverlayView()
        UIView.animate(withDuration: 0.35) {
            self.view.layoutIfNeeded()
            self.isMenuShowing = false
        }
    }
    
    func showMenu() {
        menuLeadingConstraint?.constant = 0
        showOVerlayOnContentView()
        UIView.animate(withDuration: 0.35) {
            self.view.layoutIfNeeded()
            self.isMenuShowing = true
        }
    }
    
    func showOVerlayOnContentView() {
        addContentOverlayIfNeeded()
        UIView.animate(withDuration: 0.35, animations: {
            self.contentOverlay!.alpha = 1.0
        }, completion: nil)
    }
    
    private func addContentOverlayIfNeeded() {
        guard contentOverlay == nil else { return }
        contentOverlay = UIView()
        contentOverlay!.frame = contentContainer.bounds
        contentOverlay!.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        contentOverlay!.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        contentOverlay!.alpha = 0
        contentContainer.addSubview(contentOverlay!)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideMenu))
        contentOverlay!.addGestureRecognizer(tap)
    }
    
    @objc private func hideOverlayView() {
        UIView.animate(withDuration: 0.35, animations: {
            self.contentOverlay?.alpha = 0
        }) { (_) in
            self.contentOverlay?.removeFromSuperview()
            self.contentOverlay = nil
        }
        
    }
    
    @objc private func handlePanGesture(_ pan: UIPanGestureRecognizer) {
        let translation = pan.translation(in: view).x
        if (translation < 0 && !isMenuShowing) || (translation > 0 && isMenuShowing) { return }
        let percent = min(abs(translation) / 260,1)
//        print(translation,percent)
        switch pan.state {
        case .began:
            addContentOverlayIfNeeded()
        case .changed:
            if translation > 0 {
                menuLeadingConstraint?.constant = min(translation - 260,0)
                contentOverlay?.alpha = percent
            } else {
                menuLeadingConstraint?.constant = max(translation,-260)
                contentOverlay?.alpha = 1 - percent
            }
        case .ended,.cancelled,.failed:
            let v = pan.velocity(in: view).x
            let needPerform = v > 1500 || v < -1500 || percent > 0.5
            isMenuShowing ? (needPerform ? hideMenu() : showMenu()) : (needPerform ? showMenu() : hideMenu())
            
        default:
            break
        }
    }
}

extension ContainerViewController: UIGestureRecognizerDelegate {
    
}


extension UIViewController {

    func load(_ viewController: UIViewController?, on view: UIView) {
        guard let viewController = viewController else {
            return
        }

        // `willMoveToParentViewController:` is called automatically when adding

        addChild(viewController)

        viewController.view.frame = view.bounds
        viewController.view.translatesAutoresizingMaskIntoConstraints = true
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(viewController.view)

        viewController.didMove(toParent: self)
    }

    func unload(_ viewController: UIViewController?) {
        guard let viewController = viewController else {
            return
        }

        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
        // `didMoveToParentViewController:` is called automatically when removing
    }
}
