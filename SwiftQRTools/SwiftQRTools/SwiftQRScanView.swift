//
//  QRScanView.swift
//  QRCodeReader
//
//  Created by ArcherLj on 2019/4/29.
//  Copyright © 2019 AppCoda. All rights reserved.
//

import UIKit

struct SwiftQRScanViewConfig {
    // color of other areas except interest rect
    let colorExceptInterestRect: UIColor
    // the rect width to detect QR Code
    let interstRectWidth: CGFloat
    // the rect hight to detect QR Code
    let interstRectHeight: CGFloat
    // the corner color of interest rect
    let interestRectCornerColor: UIColor
    // the corner line length of interest rect
    let InterestRectCornerLineLength: CGFloat
    // the corner line width of interest rect
    let InterestRectCornerLineWidth: CGFloat
}

class SwiftQRScanView: UIView {
    
    /// - Properties
    public var viewConfig: SwiftQRScanViewConfig!
    
    private lazy var scanBarView: UIView = {
        let view = UIView()
        view.layer.addSublayer(self.grandientLayer)
        return view
    }()
    
    private lazy var grandientLayer: CAGradientLayer =  {
        let grandient = CAGradientLayer()
        grandient.frame = .zero
        grandient.startPoint = CGPoint(x: 0, y: 0.5)
        grandient.endPoint = CGPoint(x: 1, y: 0.5)
        return grandient
    }()
    
    
    /// - Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        self.addSubview(self.scanBarView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let x = (self.bounds.width - self.viewConfig.interstRectWidth)/2.0 + 2.0
        let y = (self.bounds.height - self.viewConfig.interstRectHeight)/2.0
        let width = self.viewConfig.interstRectWidth - 2.0 * 2
        self.scanBarView.frame = CGRect(x: x, y: y, width: width, height: 2.0)
        
        self.grandientLayer.frame = scanBarView.bounds
        self.grandientLayer.colors = [UIColor.clear.cgColor, self.viewConfig.interestRectCornerColor.cgColor, UIColor.clear.cgColor]
        
        startScanAnimate()
    }
    
    /// - scan bar animation
    private func startScanAnimate() {
        self.scanBarView.layer.removeAnimation(forKey: "scanAnim")
        let scanBarAnim = CABasicAnimation(keyPath: "position.y")
        scanBarAnim.fromValue = self.scanBarView.frame.origin.y
        scanBarAnim.toValue = self.scanBarView.frame.origin.y + self.viewConfig.interstRectHeight
        scanBarAnim.duration = 2.0
        scanBarAnim.repeatCount = HUGE
        scanBarAnim.beginTime = CACurrentMediaTime()
        self.scanBarView.layer.add(scanBarAnim, forKey: "scanAnim")
    }
    
    
    /// - draw
    override func draw(_ rect: CGRect) {
        
        /// - Properties
        let lineLen = self.viewConfig.InterestRectCornerLineLength
        let lineWidth = self.viewConfig.InterestRectCornerLineWidth
        let interestH = self.viewConfig.interstRectHeight
        let interestW = self.viewConfig.interstRectWidth
        let selfH = self.bounds.height
        let selfW = self.bounds.width
        
        
        let ctx = UIGraphicsGetCurrentContext()
        //  -------------------------------------------
        //  |                                         |
        //  |             topView                     |
        //  |                                         |
        //  |          ------------------             |
        //  |          |                |             |
        //  |leftView  |  interest rect |  rightView  |
        //  |          |                |             |
        //  |          ------------------             |
        //  |                                         |
        //  |            bottomView                   |
        //  |                                         |
        //  -------------------------------------------
        
        self.viewConfig.colorExceptInterestRect.setFill()
        
        /// - top view
        let topRect = CGRect(x: 0,
                             y: 0,
                             width: selfW,
                             height: (selfH - interestH)/2.0)
        ctx?.addRect(topRect)
        
        /// - bottom view
        let bottomRect = CGRect(x: 0,
                                y: (selfH - interestH)/2.0 + interestH,
                                width: selfW,
                                height: (selfH - interestH)/2.0)
        ctx?.addRect(bottomRect)
        
        /// - left view
        let leftRect = CGRect(x: 0,
                              y: (selfH - interestH)/2.0,
                              width: (selfW - interestW)/2.0,
                              height: interestH)
        ctx?.addRect(leftRect)
        
        /// - right view
        let rightRect = CGRect(x: interestW + (selfW - interestW)/2.0,
                               y: (selfH - interestH)/2.0,
                               width: (selfW - interestW)/2.0,
                               height: interestH)
        ctx?.addRect(rightRect)
        
        ctx?.fill([topRect, bottomRect, rightRect, leftRect])
        
        /////////////////////////////////////////////////////////////////////////
        //         the corner lines of interest rect
        /////////////////////////////////////////////////////////////////////////
        self.viewConfig.interestRectCornerColor.setStroke()
        
        /// - topLeft corner path
        let topLeftCornerPath = UIBezierPath()
        topLeftCornerPath.lineWidth = lineWidth
        
        let tlStartPoint = CGPoint(x: (selfW - interestW)/2.0, y: (selfH - interestH)/2.0 + lineLen)
        let tlMiddlePoint = CGPoint(x: (selfW - interestW)/2.0, y: (selfH - interestH)/2.0)
        let tlEndPoint = CGPoint(x: (selfW - interestW)/2.0 + lineLen, y: (selfH - interestH)/2.0)
        
        topLeftCornerPath.move(to: tlStartPoint)
        topLeftCornerPath.addLine(to: tlMiddlePoint)
        topLeftCornerPath.addLine(to: tlEndPoint)
        topLeftCornerPath.stroke()
        
        /// - topRight corner path
        let topRightCornerPath = UIBezierPath()
        topRightCornerPath.lineWidth = lineWidth
        
        let trStartPoint = CGPoint(x: selfW - (selfW - interestW)/2.0 - lineLen, y: (selfH - interestH)/2.0)
        let trMiddlePoint = CGPoint(x: selfW - (selfW - interestW)/2.0, y: (selfH - interestH)/2.0)
        let trEndPoint = CGPoint(x: selfW - (selfW - interestW)/2.0, y: (selfH - interestH)/2.0 + lineLen)
        
        topRightCornerPath.move(to: trStartPoint)
        topRightCornerPath.addLine(to: trMiddlePoint)
        topRightCornerPath.addLine(to: trEndPoint)
        topRightCornerPath.stroke()
        
        /// - bottomLeft corner path
        let bottomLeftCornerPath = UIBezierPath()
        bottomLeftCornerPath.lineWidth = lineWidth
        
        let blStartPoint = CGPoint(x: (selfW - interestW)/2.0, y: selfH - (selfH - interestH)/2.0 - lineLen)
        let blMiddlePoint = CGPoint(x: (selfW - interestW)/2.0, y: selfH - (selfH - interestH)/2.0)
        let blEndPoint = CGPoint(x: (selfW - interestW)/2.0 + lineLen, y: selfH - (selfH - interestH)/2.0)
        
        bottomLeftCornerPath.move(to: blStartPoint)
        bottomLeftCornerPath.addLine(to: blMiddlePoint)
        bottomLeftCornerPath.addLine(to: blEndPoint)
        bottomLeftCornerPath.stroke()
        
        /// - bottomRight corner path
        let bottomRightCornerPath = UIBezierPath()
        bottomRightCornerPath.lineWidth = lineWidth
        
        let brStartPoint = CGPoint(x: selfW - (selfW - interestW)/2.0 - lineLen, y: selfH - (selfH - interestH)/2.0)
        let brMiddlePoint = CGPoint(x: selfW - (selfW - interestW)/2.0, y: selfH - (selfH - interestH)/2.0)
        let brEndPoint = CGPoint(x: selfW - (selfW - interestW)/2.0, y: selfH - (selfH - interestH)/2.0 - lineLen)
        
        bottomRightCornerPath.move(to: brStartPoint)
        bottomRightCornerPath.addLine(to: brMiddlePoint)
        bottomRightCornerPath.addLine(to: brEndPoint)
        bottomRightCornerPath.stroke()
    }

}
