//
//  UIViewExtension.swift
//  DoCo22
//
//  Created by EKbana MacMini 2018 on 2/13/20.
//  Copyright © 2020 ekbana. All rights reserved.
//

import UIKit

extension UIView {
    
    func set(cornerRadius radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    func set(border: UIColor) {
        self.layer.borderColor = border.cgColor;
    }
    
    func set(borderWidth: CGFloat) {
        self.layer.borderWidth = borderWidth
    }
    
    func set(borderWidth width: CGFloat, of color: UIColor) {
        self.set(border: color)
        self.set(borderWidth: width)
    }
    
    func rounded() {
        self.set(cornerRadius: self.frame.height/2)
    }
    
    func show(value: Bool) {
        self.isHidden = !value
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        
        animation.toValue               = toValue
        animation.duration              = duration
        animation.isRemovedOnCompletion = false
//        animation.fillMode            = .forwards

        self.layer.add(animation, forKey: nil)
    }
    
    func getStandardShadow() {
        self.layer.shadowColor   = UIColor.darkGray.cgColor
        self.layer.shadowOpacity = 0.8
        self.layer.shadowOffset  = CGSize(width: 0, height: 0)
        self.layer.shadowRadius  = 5
    }
    
    func shadow(offset: CGSize, color: UIColor = .black, radius: CGFloat, opacity: Float) {
        layer.masksToBounds   = false
        layer.shadowOffset    = offset
        layer.shadowColor     = color.cgColor
        layer.shadowRadius    = radius
        layer.shadowOpacity   = opacity
        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor       = nil
        layer.backgroundColor =  backgroundCGColor
    }
    
    func drawGappedLine(start p0: CGPoint, end p1: CGPoint, color: UIColor = UIColor.black) {
        let shapeLayer             = CAShapeLayer()
        shapeLayer.strokeColor     = color.cgColor
        shapeLayer.lineWidth       = self.bounds.height
        shapeLayer.lineCap         = .butt
        shapeLayer.lineDashPattern = [14, 9] // 7 is the length of dash, 3 is length of the gap.
        let path                   = CGMutablePath()
        path.addLines(between: [p0, p1])
        shapeLayer.path            = path
        self.layer.addSublayer(shapeLayer)
    }
    
    func drawgappedLineVertical(start p0: CGPoint, end p1: CGPoint, color: UIColor = UIColor.black) {
        let shapelayer = CAShapeLayer()
        shapelayer.strokeColor = color.cgColor
        shapelayer.lineWidth = self.bounds.width
//        shapelayer.lineCap = .butt
        shapelayer.lineDashPattern = [14, 9]
        let path = CGMutablePath()
        path.addLines(between: [p0,  p1])
        shapelayer.path = path
        self.layer.addSublayer(shapelayer)
    }
    
    func elevate(_ elevation: Double, color: UIColor = UIColor.black.withAlphaComponent(0.8)) {
        if elevation == 0 {
            self.layer.shadowOpacity = 0
        }else {
            self.layer.masksToBounds = false
            self.layer.shadowColor = color.cgColor
            self.layer.shadowOffset = CGSize(width: 0, height: elevation)
            self.layer.shadowRadius = abs(CGFloat(elevation))
            self.layer.shadowOpacity = 0.24
        }
    }
    func setGradientBackground(
        colorOne: UIColor,
        colorTwo: UIColor,
        startPointX: CGFloat = 1.0,
        startPointY: CGFloat = 1.0,
        endPointX: CGFloat = 0.0, endPointY: CGFloat = 0.0
    ) {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [colorOne.cgColor, colorTwo.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: startPointX, y: startPointY)
        gradientLayer.endPoint = CGPoint(x: endPointX, y: endPointY)
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func drawDottedLine(start p0: CGPoint, end p1: CGPoint, color: UIColor = UIColor.black) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.lineWidth = self.bounds.height
        shapeLayer.lineCap = .round
        //        shapeLayer.lineDashPattern = [0.5, 9] // 7 is the length of dash, 3 is length of the gap.
        shapeLayer.lineDashPattern = [0.5, 7] // 7 is the length of dash, 3 is length of the gap.
        let path = CGMutablePath()
        path.addLines(between: [p0, p1])
        shapeLayer.path = path
        self.layer.addSublayer(shapeLayer)
    }
    
    
    // MARK: Animation
    func viewPulsate() {
        
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.6
        pulse.fromValue = 0.95
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 2
        pulse.initialVelocity = 0.5
        pulse.damping = 1.0
        
        layer.add(pulse, forKey: "pulse")
    }
    
    
}


extension UIView {
    var parentViewController: UIViewController? {
            // Starts from next (As we know self is not a UIViewController).
        var parentResponder: UIResponder? = self.next
        while parentResponder != nil {
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }
}


extension UIView {
    func loadFromNib(nibName: String) -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    
    func popOrDismiss() {
        let presentingVC = self.parentViewController?.presentingViewController ?? UIViewController()
    
//        let nav = presentingVC as? UINavigationController
//        if  let vc = nav?.viewControllers.last {
//            NotificationCenter.default.post(name: .refresh, object: String(describing: type(of: vc)))
//        } else {
//            NotificationCenter.default.post(name: .refresh, object: String(describing: type(of: presentingVC)))
//        }
//
//        if self.parentViewController is SelectCountryViewController {
//            SharedData.shared.resetAllData()
//        }
        
        if self.parentViewController?.navigationController?.viewControllers.first == self.parentViewController {
            self.parentViewController?.dismiss(animated: true)
        } else if self.parentViewController?.navigationController == nil {
            self.parentViewController?.dismiss(animated: true)
        }else {
            self.parentViewController?.popVC()
        }
    }
    
}

// mark mahesh inherited
extension UIView {
    
    func addCornerRadiusWithShadow(color: UIColor, borderColor: UIColor, cornerRadius: CGFloat) {
        self.layer.shadowColor   = color.cgColor
        self.layer.shadowOffset  = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius  = 6.0
        self.layer.cornerRadius  = cornerRadius
        self.layer.borderColor   = borderColor.cgColor
        self.layer.borderWidth   = 1.0
        self.layer.masksToBounds = false
    }
    
    func setCornerRadiusWith(radius: Float, borderWidth: Float, borderColor: UIColor) {
        self.layer.cornerRadius = CGFloat(radius)
        self.layer.borderWidth = CGFloat(borderWidth)
        self.layer.borderColor = borderColor.cgColor
        self.layer.masksToBounds = true
    }
}
