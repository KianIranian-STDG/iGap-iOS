/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import UIKit
import SnapKit

protocol IGDownloadUploadIndicatorViewDelegate {
    func downloadUploadIndicatorDidTap(_ indicator: IGDownloadUploadIndicatorView)
}

class IGDownloadUploadIndicatorView: UIView {

    var delegate: IGDownloadUploadIndicatorViewDelegate?
    
    public var backgroundView: CAShapeLayer!
    private var state: IGFile.Status = .readyToDownload
    private var containerView: UIView?
    private var actionButton: UIButton?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    func prepareForReuse() {
        actionButton?.removeFromSuperview()
        actionButton = nil
    }
    
    func configure() {
        setupView()
        setState(.readyToDownload)
    }
    
    /**
     * prepration default state of progressBar
     */
    private func setupView(){
        self.isHidden = false
        self.alpha = 1.0
        self.backgroundColor = UIColor.clear
        self.isUserInteractionEnabled = true
    }
    
    func setFileType(_ type: IGProgressType) {
        makeActionButton()
        if type == .download {
            actionButton?.setTitle("", for: UIControl.State.normal)
        } else { // upload
            actionButton?.setTitle("", for: UIControl.State.normal)
        }
    }
    
    
    func setState(_ state:IGFile.Status) {
        switch state {
        case .readyToDownload, .downloadPause, .downloadFailed:
            makeActionButton()
            setPercentage(0.0)
            break
            
        case .downloading, .uploading:
            actionButton?.setTitle("", for: UIControl.State.normal)
            break
            
        case .processingForUpload:
            setPercentage(0.0)
            break
            
        case .uploadPause, .uploadFailed:
            break
            
        case .ready:
            self.isHidden = true
        case .unknown:
            break
        }
    }
    
    
    func setPercentage(_ percent: Double) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 1.0
        animation.delegate = self
        
        if backgroundView.strokeEnd == 0 {
            animation.fromValue = 0.0
        } else if backgroundView.strokeEnd == 1 {
            return
        } else {
            animation.fromValue = backgroundView.presentation()?.strokeEnd
        }
        
        animation.toValue = percent
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        
        backgroundView.strokeEnd = CGFloat(percent)
        backgroundView.add(animation, forKey: "animateCircle")
    }
    
    
    /**
     * make button for start action of download & upload
     */
    private func makeActionButton() {
        if self.actionButton == nil {
            
            /** make circle background for action button **/
            let downloadViewWidth: CGFloat = 55
            let pathWidth: CGFloat = 4.5
            let lineAndCircleSpace: CGFloat = 3.5
            let circlePath = UIBezierPath(arcCenter: CGPoint(x: downloadViewWidth / 2.0, y: downloadViewWidth / 2.0), radius: (downloadViewWidth - (pathWidth + lineAndCircleSpace)) / 2.0, startAngle: CGFloat(-(Double.pi / 2.0)), endAngle: CGFloat(Double.pi * 1.5), clockwise: true)
            
            backgroundView = CAShapeLayer()
            backgroundView.lineCap = convertToCAShapeLayerLineCap("round")
            backgroundView.path = circlePath.cgPath
            backgroundView.cornerRadius = 5
            backgroundView.fillColor = UIColor.clear.cgColor
            backgroundView.strokeColor = UIColor.white.cgColor
            backgroundView.lineWidth = pathWidth
            backgroundView.strokeEnd = 00.0
            backgroundView.presentation()?.strokeEnd = 00.0
            
            let backgroundProgress = UIView()
            backgroundProgress.layer.cornerRadius = downloadViewWidth/2
            backgroundProgress.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.addSubview(backgroundProgress)
            backgroundProgress.snp.makeConstraints({ (make) in
                make.centerX.equalTo(self.snp.centerX)
                make.centerY.equalTo(self.snp.centerY)
                make.height.equalTo(downloadViewWidth)
                make.width.equalTo(downloadViewWidth)
            })
            backgroundProgress.layer.addSublayer(backgroundView)
            
            /** make action button view **/
            self.actionButton = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            self.actionButton?.setTitle("", for: UIControl.State.normal)
            self.actionButton?.titleLabel?.font = UIFont.iGapFonticon(ofSize: 40)
            self.actionButton?.addTarget(self, action: #selector(didTapOnView), for: .touchUpInside)
            self.addSubview(self.actionButton!)
            
            self.actionButton?.snp.makeConstraints({ (make) in
                make.centerX.equalTo(backgroundProgress.snp.centerX)
                make.centerY.equalTo(backgroundProgress.snp.centerY)
                make.height.equalTo(downloadViewWidth)
                make.width.equalTo(downloadViewWidth)
            })
        }
    }
    
    @objc func didTapOnView() {
        self.delegate?.downloadUploadIndicatorDidTap(self)
    }
}

extension IGDownloadUploadIndicatorView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let strokeEnd = backgroundView.presentation()?.strokeEnd {
            if  strokeEnd >= CGFloat(1){
                self.isHidden = true
            }
        }
    }
}

fileprivate func convertToCAShapeLayerLineCap(_ input: String) -> CAShapeLayerLineCap {
	return CAShapeLayerLineCap(rawValue: input)
}
