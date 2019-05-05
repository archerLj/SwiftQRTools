//
//  ViewController.swift
//  SwiftQRTools
//
//  Created by ArcherLj on 2019/5/5.
//  Copyright © 2019 ArcherLj. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func scanQR(_ sender: Any?) {
        let scanVC = SwiftQRScanController()
        scanVC.delegate = self
        self.present(scanVC, animated: true, completion: nil)
    }
    
    @IBAction func generateQRCode(_ sender: Any?) {
        let imageView = UIImageView(frame: CGRect(x: 100, y: 100, width: 200, height: 200))
        if let image = SwiftQRUtils.generateQRCode(with: "123", tintColor: UIColor.black, imageScale: 10, centerImage: UIImage(named: "top"), centerImageSize: CGSize(width: 40, height: 40)) {
            imageView.image = image
        }
        self.view.addSubview(imageView)
    }
    
    @IBAction func readQRCodeInfoFromAlbum(_ sender: Any?) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerVC = UIImagePickerController()
            imagePickerVC.delegate = self
            imagePickerVC.sourceType = .photoLibrary
            imagePickerVC.allowsEditing = true
            self.present(imagePickerVC, animated: true, completion: nil)
        }
    }
}

extension ViewController: SwiftQRScanControllerDelegate {
    
    func scan(controller: SwiftQRScanController, result: String) {
        print(result)
        controller.dismiss(animated: false, completion: nil)
    }
    
    func scanMetadataObjectTypes() -> [AVMetadataObject.ObjectType] {
        return [.qr, .code128, .ean13, .ean8]
    }
    
    
    func scanViewConfig() -> SwiftQRScanViewConfig {
        return SwiftQRScanViewConfig(colorExceptInterestRect: UIColor.init(white: 0, alpha: 0.8),
                                    interstRectWidth: 300.0,
                                    interstRectHeight: 100.0,
                                    interestRectCornerColor: UIColor.red,
                                    InterestRectCornerLineLength: 40,
                                    InterestRectCornerLineWidth: 10)
    }
    
    func scan(scanViewIn superView: UIView) -> SwiftQRScanView {
        let scanView = ScanViewWithBack(frame: superView.bounds)
        scanView.delegate = self
        return scanView
    }
}

extension ViewController: ScanViewWithBackDelegate {
    func back() {
        self.dismiss(animated: true, completion: nil)
    }
}


extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let result = SwiftQRUtils.getQRCodeInfo(in: image)
        print(result ?? "")
        picker.dismiss(animated: true, completion: nil)
    }
}


