//
//  UIViewExtension.swift
//  ASL Recognition
//
//  Created by Michał on 15/12/2022.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach{ self.addSubview($0)}
    }
    
    var safeTopAnchor: NSLayoutYAxisAnchor {
        return safeAreaLayoutGuide.topAnchor
    }
    
    var safeLeftAnchor: NSLayoutXAxisAnchor {
        return safeAreaLayoutGuide.leftAnchor
    }
    
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        return safeAreaLayoutGuide.bottomAnchor
    }
    
    var safeRightAnchor: NSLayoutXAxisAnchor {
        return safeAreaLayoutGuide.rightAnchor
    }

    public func anchor(top: NSLayoutYAxisAnchor? = nil,
                       left: NSLayoutXAxisAnchor? = nil,
                       bottom: NSLayoutYAxisAnchor? = nil,
                       right: NSLayoutXAxisAnchor? = nil,
                       paddingTop: CGFloat = 0,
                       paddingLeft: CGFloat = 0,
                       paddingBottom: CGFloat  = 0,
                       paddingRight: CGFloat = 0,
                       width: CGFloat = 0,
                       height: CGFloat = 0,
                       widthAnchor: NSLayoutDimension? = nil,
                       heightAnchor: NSLayoutDimension? = nil,
                       widthAnchorMultiplier: CGFloat = 1.0,
                       heightAnchorMultiplier: CGFloat = 1.0,
                       enableInsets: Bool = false) {
        var topInset = CGFloat(0)
        var bottomInset = CGFloat(0)
        
        if #available(iOS 11, *), enableInsets {
            let insets = self.safeAreaInsets
            topInset = insets.top
            bottomInset = insets.bottom
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop+topInset).isActive = true
        }
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom-bottomInset).isActive = true
        }
        if height != 0 {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        if width != 0 {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        if let widthAnchor = widthAnchor {
            self.widthAnchor.constraint(equalTo: widthAnchor, multiplier: widthAnchorMultiplier).isActive = true
        }
        if let heightAnchor = heightAnchor {
            self.heightAnchor.constraint(equalTo: heightAnchor, multiplier: heightAnchorMultiplier).isActive = true
        }
    }
    
    func topGreaterThanOrEqualTo(top: NSLayoutYAxisAnchor, padding: CGFloat = 0) {
        self.topAnchor.constraint(greaterThanOrEqualTo: top, constant: padding).isActive = true
    }
    
    func topLessThanOrEqualTo(top: NSLayoutYAxisAnchor, padding: CGFloat = 0) {
        self.topAnchor.constraint(lessThanOrEqualTo: top, constant: padding).isActive = true
    }
    
    func leftGreaterThanOrEqualTo(left: NSLayoutXAxisAnchor, padding: CGFloat = 0) {
        self.leftAnchor.constraint(greaterThanOrEqualTo: left, constant: padding).isActive = true
    }
    
    func leftLessThanOrEqualTo(left: NSLayoutXAxisAnchor, padding: CGFloat = 0) {
        self.leftAnchor.constraint(lessThanOrEqualTo: left, constant: padding).isActive = true
    }
    
    func bottomGreaterThanOrEqualTo(bottom: NSLayoutYAxisAnchor, padding: CGFloat = 0) {
        self.bottomAnchor.constraint(greaterThanOrEqualTo: bottom, constant: -padding).isActive = true
    }
    
    func bottomLessThanOrEqualTo(bottom: NSLayoutYAxisAnchor, padding: CGFloat = 0) {
        self.bottomAnchor.constraint(lessThanOrEqualTo: bottom, constant: -padding).isActive = true
    }
    
    func rightGreaterThanOrEqualTo(right: NSLayoutXAxisAnchor, padding: CGFloat = 0) {
        self.rightAnchor.constraint(greaterThanOrEqualTo: right, constant: -padding).isActive = true
    }
    
    func rightLessThanOrEqualTo(right: NSLayoutXAxisAnchor, padding: CGFloat = 0) {
        self.rightAnchor.constraint(lessThanOrEqualTo: right, constant: -padding).isActive = true
    }
    
    func center(inView view: UIView, yConcstant: CGFloat? = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: yConcstant!).isActive = true
    }
    
    func centerX(inView view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func centerY(inView view: UIView, constant: CGFloat = 0, leftAnchor: NSLayoutXAxisAnchor? = nil, paddingLeft: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
        if let left = leftAnchor {
            anchor(left: left, paddingLeft: paddingLeft)
        }
    }
    
    func setDimensions(height: CGFloat, width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func setHeight(_ height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func heightGreaterOrEqualTo(_ height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(greaterThanOrEqualToConstant: height).isActive = true
    }
    
    func setWidth(_ width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func fillSuperView() {
        translatesAutoresizingMaskIntoConstraints = false
        guard let view = superview else { return }
        anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    }
    
    func fillSafeAreaSuperView() {
        translatesAutoresizingMaskIntoConstraints = false
        guard let view = superview else { return }
        anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor)
    }
    
    func edgeTo(_ view: UIView, top: NSLayoutYAxisAnchor?, constant: CGFloat) {
        view.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: constant).isActive = true
        }
    }
    
    func pinMapTo(_ view: UIView, with constant: CGFloat) {
        view.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -constant).isActive = true
    }
    
    func addGradientBackground(_ colors: [UIColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // MARK: Shadow
    enum ShadowType {
        case cell
        case components
        case customMaskedCorners(_ corners: CACornerMask)
    }
    
    func addShadow(type: ShadowType) {
        let shadowLayer = CAShapeLayer()
        shadowLayer.path = UIBezierPath(roundedRect: self.bounds,
                                        cornerRadius: self.layer.cornerRadius).cgPath
        shadowLayer.fillColor = UIColor.white.cgColor
        shadowLayer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        shadowLayer.shadowOpacity = 1.0
        
        switch type {
        case .cell:
            shadowLayer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
            shadowLayer.shadowRadius = 5
        case .components:
            shadowLayer.shadowColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.08).cgColor
            shadowLayer.shadowRadius = 26.0
        case .customMaskedCorners(let corners):
            shadowLayer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
            shadowLayer.shadowRadius = 5
            shadowLayer.maskedCorners = corners
        }
        
        self.layer.insertSublayer(shadowLayer, at: .zero)
    }
    
    func addShadow(corners: CACornerMask = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner]) {
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        self.layer.shadowOpacity = 0.8
        self.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        self.layer.shadowRadius = 5
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        self.layer.maskedCorners = corners
    }
    
    func addQuestCellShadow() {
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        self.layer.shadowRadius = 20
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
         let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
         let mask = CAShapeLayer()
         mask.path = path.cgPath
         self.layer.mask = mask
    }
}
