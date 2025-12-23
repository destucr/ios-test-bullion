//
//  UIView+Gradient.swift
//  BullionTest
//
//  Created by Destu Cikal Ramdani on 22/12/25.
//

import UIKit

extension UIView {
    func applyBullionGradient() {
        // Remove existing gradient layers if any
        self.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        
        // Colors from hex
        let color1 = UIColor(hex: "#FC683A").cgColor
        let color2 = UIColor(hex: "#F05A2A").cgColor
        let color3 = UIColor(hex: "#F1BAA8").cgColor
        
        gradientLayer.colors = [color1, color2, color3]
        
        // Locations from percentages
        gradientLayer.locations = [0.0374, 0.39, 0.8632]
        
        // Direction: Top-Left to Bottom-Right (~135 degrees)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        // Insert at index 0 to stay behind UI components
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // To handle rotation or layout changes
    func updateGradientFrame() {
        if let gradientLayer = self.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer {
            gradientLayer.frame = self.bounds
        }
    }
}
