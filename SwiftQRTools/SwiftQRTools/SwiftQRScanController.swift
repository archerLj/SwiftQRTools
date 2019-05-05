//
//  QRScannerController.swift
//  QRCodeReader
//
//  Created by Simon Ng on 13/10/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import AVFoundation

protocol SwiftQRScanControllerDelegate {
    func scan(scanViewIn superView: UIView) -> SwiftQRScanView
    func scanViewConfig() -> SwiftQRScanViewConfig
    func scanMetadataObjectTypes() -> [AVMetadataObject.ObjectType]
    func scan(controller: SwiftQRScanController, result: String)
}

extension SwiftQRScanControllerDelegate {
    func scan(scanViewIn superView: UIView) -> SwiftQRScanView {
        let scanView = SwiftQRScanView(frame: superView.bounds)
        return scanView
    }
    
    func scanViewConfig() -> SwiftQRScanViewConfig {
        return SwiftQRScanController.sDefaultQRScanViewConfig
    }
    
    func scanMetadataObjectTypes()  -> [AVMetadataObject.ObjectType] {
        return [.qr]
    }
}

class SwiftQRScanController: UIViewController {
    
    /// - static
    static let sDefaultInterestWidth: CGFloat = 200
    static let sDefaultInterestHeight: CGFloat = 200
    static let sDefaultQRScanViewConfig = SwiftQRScanViewConfig(colorExceptInterestRect: UIColor.init(white: 0, alpha: 0.5),
                                                           interstRectWidth: SwiftQRScanController.sDefaultInterestWidth,
                                                           interstRectHeight: SwiftQRScanController.sDefaultInterestHeight,
                                                           interestRectCornerColor: UIColor.green,
                                                           InterestRectCornerLineLength: 20.0,
                                                           InterestRectCornerLineWidth: 3.0)

    /// - Properties
    public var delegate: SwiftQRScanControllerDelegate?
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var captureMetadataOutput: AVCaptureMetadataOutput!
//    var qrCodeFrameView: UIView?
    
    
    /// - Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        sessionSetup()
        interestRectConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let _ = self.delegate {
            let scanView = self.delegate!.scan(scanViewIn: self.view)
            scanView.viewConfig = self.delegate!.scanViewConfig()
            scanView.tag = 999
            
            self.view.viewWithTag(999)?.removeFromSuperview()
            self.view.addSubview(scanView)
            
            // setNeessLayout to restart the animation in scanView
            scanView.setNeedsLayout()
        } else {
            fatalError("Unexcept nil while using property of `delegate` ")
        }
        
        // restart captureSession
        if let _ = captureSession {
            if !captureSession!.isRunning {
                captureSession!.startRunning()
            }
        }
    }
    
    // Set the interest rect of CaptureMetadataOutput.
    func interestRectConfig() {
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange, object: nil, queue: nil) { [weak self] _ in
            if let `self` = self {
                if let _ = self.videoPreviewLayer {
                    
                    var interestW = SwiftQRScanController.sDefaultInterestWidth
                    var interestH = SwiftQRScanController.sDefaultInterestHeight
                    
                    if let _ = self.delegate {
                        interestW = self.delegate!.scanViewConfig().interstRectWidth
                        interestH = self.delegate!.scanViewConfig().interstRectHeight
                    }
                    
                    self.captureMetadataOutput.rectOfInterest = self.videoPreviewLayer!.metadataOutputRectConverted(fromLayerRect:
                        CGRect(
                            x: (self.view.bounds.size.width - interestW)/2.0,
                            y: (self.view.bounds.height - interestH)/2.0,
                            width: interestW,
                            height: interestH))
                }
            }
        }
    }
    
    func sessionSetup() {
        captureSession = AVCaptureSession()
        // AVCaptureDevice.DiscoverySession used to find all avalible capture devices matching a specific device type
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // AVCaptureSession used to coordinate the flow of data from the video input device to our output
            captureSession?.addInput(input)
            
            // The output of the session is set to an AVCaptureMetadataOutput object. combinnation with the AVCaptureMetadataOutputObjectsDelegate protocol, is used to intercept any metadata found int the input device(the QR code captured by the device's camera) and translate it to a human-readable format.
            captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            // set output delegate and the queue to execute the call back(delegate method)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            // metadataObjectTypes used to tell the app what kind of matadata we are intreated in. Here we want to do QR scan, so .qr is the right choice.
            if let _ = delegate {
                captureMetadataOutput.metadataObjectTypes = delegate!.scanMetadataObjectTypes()
            } else {
                captureMetadataOutput.metadataObjectTypes = [.qr]
            }
            
            
            // configer the preview layer
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = .resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // start video capture
            captureSession?.startRunning()
            
            // Initialize QR Code Frame to highlight the QR code
//            qrCodeFrameView = UIView()
//            if let qrCodeFrameView = qrCodeFrameView {
//                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
//                qrCodeFrameView.layer.borderWidth = 2
//                view.addSubview(qrCodeFrameView)
//                view.bringSubview(toFront: qrCodeFrameView)
//            }
            
        } catch  {
            print(error)
            return
        }
    }
}

extension SwiftQRScanController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        // metadataObjects contains all the metadata objects that have been read.
        // Check if the metadataObjects is not nil and it contains at last one object.
        if metadataObjects.count == 0{
//            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        
        // Get the metadata object
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        // check if the metadata object is a QR Code
        
        if let _ = delegate {
            if !delegate!.scanMetadataObjectTypes().contains(metadataObj.type) {
                return
            }
        } else if metadataObj.type != AVMetadataObject.ObjectType.qr {
            return
        }
        
        // transformedMetadataObject method used to convert the metadata object's visual propertiest to layer coordinates.
        // then we can find the bounds of the QR Code
//        let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
//        qrCodeFrameView?.frame = barCodeObject!.bounds
        
        if let result = metadataObj.stringValue {
            self.captureSession?.stopRunning()
            // output qr code
            self.delegate?.scan(controller: self, result: result)
        }
    }
}
