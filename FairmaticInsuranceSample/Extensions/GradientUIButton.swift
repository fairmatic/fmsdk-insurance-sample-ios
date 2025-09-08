//
//  GradientInfo.swift
//  FairmaticInsuranceSample
//
//  Created by Sagar Dagdu on 9/8/25.
//

import UIKit

class GradientUIButton: UIButton {
    private var gradientInfo: GradientInfo?
    
    func addGradient(colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0, y: 0.5), endPoint: CGPoint = CGPoint(x: 1, y: 0.5)) {
        // Store gradient properties for later use
        let gradientInfo = GradientInfo(colors: colors, startPoint: startPoint, endPoint: endPoint)
        self.gradientInfo = gradientInfo
        
        // Apply gradient if frame is already set
        if bounds != .zero {
            applyStoredGradient()
        }
    }
    
    private func applyStoredGradient() {
        guard let gradientInfo else { return }
        
        // Remove existing gradient layers
        layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientInfo.colors.map { $0.cgColor }
        gradientLayer.startPoint = gradientInfo.startPoint
        gradientLayer.endPoint = gradientInfo.endPoint
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        applyStoredGradient()
    }
}

private class GradientInfo {
    let colors: [UIColor]
    let startPoint: CGPoint
    let endPoint: CGPoint
    
    init(colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint) {
        self.colors = colors
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
}

