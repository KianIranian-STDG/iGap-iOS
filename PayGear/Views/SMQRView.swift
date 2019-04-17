//
//  SMQRView.swift
//  PayGear
//
//  Created by Fatemeh Shapouri on 4/18/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit
import QRCodeReader

/// The QRCodeReaderViewContainer in Pod has structured to a displayable view
/// This class is copied from a ready class in QRCodeReader.swift pod
/// to more detail about this class please visit https://github.com/yannickl/QRCodeReader.swift
/// https://github.com/yannickl/QRCodeReader.swift/blob/master/Sources/QRCodeReaderView.swift
class SMQRView: UIView, QRCodeReaderDisplayable {

    
    public lazy var overlayView: UIView? = {
        let ov = SMQROverlayView(frame: self.frame)
        
        ov.backgroundColor                           = .clear
        ov.clipsToBounds                             = true
        ov.translatesAutoresizingMaskIntoConstraints = false
        
        return ov
    }()
    
    public let cameraView: UIView = {
        let cv = UIView()
        
        cv.clipsToBounds                             = true
        cv.translatesAutoresizingMaskIntoConstraints = false
        
        return cv
    }()
    
    public lazy var cancelButton: UIButton? = {
        let cb = UIButton()
        
        cb.translatesAutoresizingMaskIntoConstraints = false
        cb.setTitleColor(.gray, for: .highlighted)
        
        return cb
    }()
    
    public lazy var switchCameraButton: UIButton? = {
        let scb = SwitchCameraButton()
        
        scb.translatesAutoresizingMaskIntoConstraints = false
        
        return scb
    }()
    
    public lazy var toggleTorchButton: UIButton? = {
        let ttb = UIButton()
        ttb.setImage(UIImage.init(named: "flashlight"), for: .normal)
        ttb.translatesAutoresizingMaskIntoConstraints = false
        
        return ttb
    }()
    
    public var manualInputButton: UIButton? = {
        let mib = UIButton()
        mib.setImage(UIImage.init(named: "manual_input"), for: .normal)

        mib.translatesAutoresizingMaskIntoConstraints = false
        return mib
    }()
    
    private weak var reader: QRCodeReader?
    
    public func setupComponents(showCancelButton: Bool, showSwitchCameraButton: Bool, showTorchButton: Bool, showOverlayView: Bool, reader: QRCodeReader?) {
        self.reader               = reader
//        reader?.lifeCycleDelegate = self
        
        addComponents()
        
        cancelButton?.isHidden       = !showCancelButton
        switchCameraButton?.isHidden = !showSwitchCameraButton
        toggleTorchButton?.isHidden  = !showTorchButton
        overlayView?.isHidden        = !showOverlayView
        
        guard let cb = cancelButton, let scb = switchCameraButton, let ttb = toggleTorchButton, let ov = overlayView else { return }
        
        let views = ["cv": cameraView, "ov": ov, "cb": cb, "scb": scb, "ttb": ttb]
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[cv]|", options: [], metrics: nil, views: views))
 
        if showCancelButton {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[cv][cb(40)]|", options: [], metrics: nil, views: views))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[cb]-|", options: [], metrics: nil, views: views))
        }
        else {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[cv]|", options: [], metrics: nil, views: views))
        }
        
        if showSwitchCameraButton {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[scb(50)]", options: [], metrics: nil, views: views))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[scb(70)]|", options: [], metrics: nil, views: views))
        }
        
        if showTorchButton {
            NSLayoutConstraint(item: ttb, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 15).isActive = true
            NSLayoutConstraint(item: ttb, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -25).isActive = true
            NSLayoutConstraint(item: ttb, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40).isActive = true
            NSLayoutConstraint(item: ttb, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40).isActive = true
        }
        
        for attribute in Array<NSLayoutConstraint.Attribute>([.left, .top, .right, .bottom]) {
            addConstraint(NSLayoutConstraint(item: ov, attribute: attribute, relatedBy: .equal, toItem: cameraView, attribute: attribute, multiplier: 1, constant: 0))
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        reader?.previewLayer.frame = bounds
        overlayView?.frame = bounds
    }
    
    // MARK: - Scan Result Indication
    
    func startTimerForBorderReset() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            if (self.overlayView as? ReaderOverlayView) != nil {
//                ovl.overlayColor = .white
            }
        }
    }
    
    func addRedBorder() {
        self.startTimerForBorderReset()
        
        if (self.overlayView as? ReaderOverlayView) != nil {
//            ovl.overlayColor = .red
        }
    }
    
    func addGreenBorder() {
        self.startTimerForBorderReset()
        
        if (self.overlayView as? ReaderOverlayView) != nil {
//            ovl.overlayColor = .green
        }
    }
    
    @objc public func setNeedsUpdateOrientation() {
        setNeedsDisplay()
        
        overlayView?.setNeedsDisplay()
        
        if let connection = reader?.previewLayer.connection, connection.isVideoOrientationSupported {
            let application                    = UIApplication.shared
            let orientation                    = UIDevice.current.orientation
            let supportedInterfaceOrientations = application.supportedInterfaceOrientations(for: application.keyWindow)
            
            connection.videoOrientation = QRCodeReader.videoOrientation(deviceOrientation: orientation, withSupportedOrientations: supportedInterfaceOrientations, fallbackOrientation: connection.videoOrientation)
        }
    }
    
    // MARK: - Convenience Methods
    
    private func addComponents() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.setNeedsUpdateOrientation), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        addSubview(cameraView)
        
        if let mib = manualInputButton {
            addSubview(mib)
            
            NSLayoutConstraint(item: mib, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -25).isActive = true
            NSLayoutConstraint(item: mib, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -15).isActive = true
            NSLayoutConstraint(item: mib, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40).isActive = true
            NSLayoutConstraint(item: mib, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40).isActive = true

        }
        
        if let ov = overlayView {
            addSubview(ov)
        }
        
        if let scb = switchCameraButton {
            addSubview(scb)
        }
        
        if let ttb = toggleTorchButton {
            addSubview(ttb)
        }
        
        if let cb = cancelButton {
            addSubview(cb)
        }
        
        if let reader = reader {
            cameraView.layer.insertSublayer(reader.previewLayer, at: 0)
            
            setNeedsUpdateOrientation()
        }
        

        
    }
    
}


//extension SMQRView: QRCodeReaderLifeCycleDelegate {
//    func readerDidStartScanning() {
//        setNeedsUpdateOrientation()
//    }
//    
//    func readerDidStopScanning() {}
//}

