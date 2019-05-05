# SwiftQRTools
Scan QR、Generate QR Code image and Read QR Code from image

<img src="https://raw.githubusercontent.com/archerLj/SwiftQRTools/master/pics/scanPage.PNG" width= "200"/><img src="https://raw.githubusercontent.com/archerLj/SwiftQRTools/master/pics/qrPage.PNG" width= "200"/>

### Usage
##### 1. Scan QR
SwiftQRTools provide a `SwiftQRScanController` and a default view `SwiftQRScanView` shows in above picture. You can use yourself view just inherit `SwiftQRScanView`. And there's some usefull delegate methods in `SwiftQRScanControllerDelegate`. Here's an example:
```
class ViewController: UIViewController {
    // ...
    @IBAction func scanQR(_ sender: Any?) {
        let scanVC = SwiftQRScanController()
        scanVC.delegate = self
        self.present(scanVC, animated: true, completion: nil)
    }
    // ...
}

extension ViewController: SwiftQRScanControllerDelegate {
    
    func scan(controller: SwiftQRScanController, result: String) {
        print(result)
        controller.dismiss(animated: false, completion: nil)
    }
    
    func scanMetadataObjectTypes() -> [AVMetadataObject.ObjectType] {
        return [.qr, .code128, .ean13, .ean8]
    }
    
    // SwiftQRScanViewConfig used to configure the interest rect.
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
```

##### 2. Generate QR Code

```
let image = SwiftQRUtils.generateQRCode(with: "123", tintColor: UIColor.black, imageScale: 10, centerImage: UIImage(named: "top"), centerImageSize: CGSize(width: 40, height: 40)) 
```
or just
```
let image = SwiftQRUtils.generateQRCode(with: "123") 
```

##### 2. Read QR Code info from image

```
let image = UIImage(named: "test")
let result = SwiftQRUtils.getQRCodeInfo(in: image)
print("info is : \(result)")
```


### Installation
SimpleQR is available through CocoaPods. To install it, simply add the following line to your Podfile:
```
pod 'SwiftQRTools'
```

### License
<br/>
SwiftQRUtils is released under the MIT license. <a href="https://github.com/archerLj/SwiftQRTools/blob/master/LICENSE">See LICENSE</a> for details.


