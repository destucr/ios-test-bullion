//
//  UIViewController+Loading.swift
//  BullionTest
//
//  Created by Destu Cikal Ramdani on 22/12/25.
//

import UIKit

extension UIViewController {
    private static var loadingViewKey: UInt8 = 0
    
    private var loadingOverlay: UIView? {
        get { return objc_getAssociatedObject(self, &UIViewController.loadingViewKey) as? UIView }
        set { objc_setAssociatedObject(self, &UIViewController.loadingViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    func showLoading(_ show: Bool) {
        if show {
            if loadingOverlay != nil { return }
            
            let overlay = UIView(frame: view.bounds)
            overlay.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.color = .white
            spinner.center = overlay.center
            spinner.startAnimating()
            
            overlay.addSubview(spinner)
            view.addSubview(overlay)
            
            loadingOverlay = overlay
        } else {
            loadingOverlay?.removeFromSuperview()
            loadingOverlay = nil
        }
    }
}
