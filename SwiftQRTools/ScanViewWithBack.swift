//
//  ScanViewWithBack.swift
//  SwiftQRTools
//
//  Created by ArcherLj on 2019/5/5.
//  Copyright © 2019 ArcherLj. All rights reserved.
//

import UIKit

@objc protocol ScanViewWithBackDelegate {
    @objc func back()
}

class ScanViewWithBack: SwiftQRScanView {
    
    var delegate: ScanViewWithBackDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.backBtn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.backBtn.widthAnchor.constraint(equalToConstant: 80),
            self.backBtn.heightAnchor.constraint(equalToConstant: 40),
            self.backBtn.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -60),
            self.backBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor)
            ])
    }
    
    lazy var backBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("back", for: .normal)
        button.addTarget(delegate, action: #selector(delegate?.back), for: .touchUpInside)
        return button
    }()
}
