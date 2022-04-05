//
//  LoginController.swift
//  NMT-Authentication
//
//  Created by Nguyen Minh Tam on 02/04/2022.
//

import UIKit
import AVFoundation

class LoginController: BaseController {
    //MARK: Properties
    private let anthenticationLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorName.color_707070
        label.text = "text_QR_scan_title".localized()
        return label
    }()
    
    private lazy var nextButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("NEXT", for: .normal)
        btn.backgroundColor = .orange
        btn.addTarget(self, action: #selector(choosePhotoFromLibrary), for: .touchUpInside)
        return btn
    }()
    
    private let viewContainingCamera = UIView()
    
    private lazy var photoFromLibraryButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Open Photo Library", for: .normal)
        btn.backgroundColor = .orange
        btn.addTarget(self, action: #selector(choosePhotoFromLibrary), for: .touchUpInside)
        return btn
    }()
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    private let qrResultLbel: UILabel = {
        let label = UILabel()
        label.textColor = ColorName.color_707070
        label.numberOfLines = 0
        return label
    }()
    
    //MARK: View cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        checkAndOpenQRReader()
    }
    
    override func setupUI() {
        super.setupUI()
        
        view.bringSubviewToFront(navigationController!.view)
        
        view.addSubview(anthenticationLabel)
        anthenticationLabel.snp.makeConstraints({ (make) in
            
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.centerX.equalToSuperview()
            
        })
        view.bringSubviewToFront(anthenticationLabel)
        
        view.addSubview(viewContainingCamera)
        viewContainingCamera.snp.makeConstraints({ (make) in
            
            make.center.equalToSuperview()
            make.width.height.equalTo(300)
            
        })
        view.bringSubviewToFront(viewContainingCamera)
        
        view.addSubview(photoFromLibraryButton)
        view.bringSubviewToFront(photoFromLibraryButton)
        photoFromLibraryButton.snp.makeConstraints({ (make) in
            
            make.top.equalTo(viewContainingCamera.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(50)
            
        })
        
        view.addSubview(qrResultLbel)
        qrResultLbel.snp.makeConstraints({ (make) in
            
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            
        })
        view.bringSubviewToFront(qrResultLbel)
        
    }
    
    //MARK: Actions
    @objc func choosePhotoFromLibrary() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.view.tintColor = view.tintColor
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    @objc func handleEventFromNextButton() {
        
        let targetVC = AuthenticationMethodsViewController()
        self.navigationController?.pushViewController(targetVC, animated: true)
        
    }
    
    //MARK: Helpers
    private func checkAndOpenQRReader() {
        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)

        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }

        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)

            // Set the input device on the capture session.
            captureSession.addInput(input)

        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureMetadataOutput)

        // Set delegate and use the default dispatch queue to execute the call back
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]

        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = CGRect(origin: .zero, size: .init(width: 300, height: 300))
        viewContainingCamera.layer.addSublayer(videoPreviewLayer!)

        // Start video capture.
        captureSession.startRunning()
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()

        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            viewContainingCamera.addSubview(qrCodeFrameView)
            viewContainingCamera.bringSubviewToFront(qrCodeFrameView)
        }

    }

}

extension LoginController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            qrResultLbel.text = "No QR code is detected"
            return
        }

        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject

        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            
            qrCodeFrameView?.frame = barCodeObject!.bounds

            if metadataObj.stringValue != nil {
                qrResultLbel.text = metadataObj.stringValue
            }
        }
    }

}


extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let qrcodeImg = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as? UIImage,
              let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]),
              let ciImage = CIImage(image: qrcodeImg),
              let features = detector.features(in: ciImage) as? [CIQRCodeFeature] else {return}
        
        var qrCodeLink = ""
        features.forEach({ (feature) in
            
            if let messageString = feature.messageString {
                
                qrCodeLink += messageString
            }
            
        })
        
        if qrCodeLink.isEmpty {
            
            print("qrCodeLink is empty!")
            
        } else {
            
            print("message: \(qrCodeLink)")
            
        }
        
        self.dismiss(animated: true, completion: nil)
    
    }
    
}
