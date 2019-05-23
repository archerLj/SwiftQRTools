//
//  QRCodeCreater.swift
//  QRCodeReader
//
//  Created by ArcherLj on 2019/4/30.
//  Copyright © 2019 AppCoda. All rights reserved.
//

import Foundation
import UIKit
import CoreImage

public class SwiftQRUtils {
    
    /////////////////////////////////////////////////////////////////////////
    //              -  Detect QR Code info from image
    /////////////////////////////////////////////////////////////////////////
    
    public static func getQRCodeInfo(in image: UIImage) -> String? {
        
        if let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]) {
            let features = detector.features(in: CIImage(cgImage: image.cgImage!))
            if features.count > 0 {
                if let qrCodeFeature = features.first as? CIQRCodeFeature {
                    return qrCodeFeature.messageString
                }
                return nil
            }
        }
        return nil
    }
    
    
    
    /////////////////////////////////////////////////////////////////////////
    //              -  Generate QR Code Image
    /////////////////////////////////////////////////////////////////////////
    /// Generate a QR Code image.
    ///
    /// - Parameters:
    ///   - content: string data used to generate QR Code.
    ///   - tintColor: QR Code color.
    ///   - imageScale: a float value used to scale the QR Code image.
    ///   - centerImage: image that is laid on top of QR Code.
    ///   - centerImageSize: size of center image.
    
    public static func generateQRCode(with content: String,
                               tintColor: UIColor = UIColor.black,
                               imageScale: CGFloat = 10.0,
                               centerImage: UIImage? = nil,
                               centerImageSize: CGSize? = nil) -> UIImage? {
        
        if var qrimage = SwiftQRUtils.generateQRCode2(with: content, imageScale: imageScale) {
            
            qrimage = changeImageColor(with: qrimage, to: tintColor)
            
            if let _ = centerImage, let _ = centerImageSize {
                UIGraphicsBeginImageContext(qrimage.size)
                qrimage.draw(in: CGRect(x: 0, y: 0, width: qrimage.size.width, height: qrimage.size.height))
                
                let x = (qrimage.size.width - centerImageSize!.width)/2.0
                let y = (qrimage.size.height - centerImageSize!.height)/2.0
                centerImage?.draw(in: CGRect(x: x, y: y, width: centerImageSize!.width, height: centerImageSize!.height))
                
                qrimage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
            }
            
            return qrimage
        }
        return nil
    }
    
    // white background, black QR
    // QR Code is generated useing the Core Image framework with CIFilters.
    // Core Image is used for processing images -- mostly applying filters and effects to images.
    private static func generateQRCode(with content: String,
                               imageScale: CGFloat) -> UIImage? {
        // 1. Get an Data object from the content.
        let data = content.data(using: .ascii)
        // Initialize a CIFilter with the QR Code preset
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        // add your data to the filter
        qrFilter.setValue(data, forKey: "inputMessage")
        // generate a CIImage from the filter
        guard let qrImage = qrFilter.outputImage else {
            return nil
        }
        
        // the generated CIImage is very small. we need to scale up it.
        let transform = CGAffineTransform(scaleX: imageScale, y: imageScale)
        let scaledQRImage = qrImage.transformed(by: transform)
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledQRImage, from: scaledQRImage.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
    
    // clear background, white QR
    private static func generateQRCode2(with content: String,
                               imageScale: CGFloat) -> UIImage? {
        //
        let data = content.data(using: .ascii)
        //
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        //
        qrFilter.setValue(data, forKey: "inputMessage")
        //
        guard let qrImage = qrFilter.outputImage else {
            return nil
        }
        
        let transform = CGAffineTransform(scaleX: imageScale, y: imageScale)
        let scaledQRImage = qrImage.transformed(by: transform)
        
        // invert the black QR Code to white QR Code.
        // invert colors with CIColorInvert filter
        guard let colorInvertFilter = CIFilter(name: "CIColorInvert") else {
            return nil
        }
        
        //
        colorInvertFilter.setValue(scaledQRImage, forKey: "inputImage")
        //
        guard let outputInvertedImage = colorInvertFilter.outputImage else {
            return nil
        }
        
        // Make the now-black backgroung transparent with CIMaskToAlpha filter
        // change the white background to transparent backgroud.
        guard let maskToAlphaFilter = CIFilter(name: "CIMaskToAlpha") else {
            return nil
        }
        
        //
        maskToAlphaFilter.setValue(outputInvertedImage, forKey: "inputImage")
        //
        guard let outputCIImage = maskToAlphaFilter.outputImage else {
            return nil
        }

        
        let context = CIContext()
        guard let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
    
    private static func changeImageColor(with image: UIImage, to color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0)
        color.setFill()
        
        let bounds = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        UIRectFill(bounds)
        
        image.draw(in: bounds, blendMode: .overlay, alpha: 1.0)
        image.draw(in: bounds, blendMode: .destinationIn, alpha: 1.0)
        
        let result = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return result
    }
}
