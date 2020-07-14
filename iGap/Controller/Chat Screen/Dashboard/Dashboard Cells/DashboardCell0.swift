//
//  DashboardCell0.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 7/14/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
import UIKit
import IGProtoBuff

class DashboardCell0: AbstractDashboardCell {
    
    let lblStar: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.iGapFonticon(ofSize: 48)
        lbl.textColor = ThemeManager.currentTheme.iVandColor
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = ""
        lbl.textAlignment = .center
        lbl.isUserInteractionEnabled = false
        return lbl
    }()
    
    let lblYourScoreTitle: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor.lightGray.withAlphaComponent(0.8)
        lbl.font = UIFont.igFont(ofSize: 15)
        lbl.text = IGStringsManager.YourScore.rawValue.localized
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.adjustsFontSizeToFitWidth = true
        lbl.isUserInteractionEnabled = false
        return lbl
    }()
    
    let lblYourScore: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.igFont(ofSize: 15, weight: .bold)
        lbl.textColor = ThemeManager.currentTheme.iVandColor
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.isUserInteractionEnabled = false
        return lbl
    }()
    
    let viewSeparatorLine: UIView = {
        let vi = UIView()
        vi.backgroundColor = UIColor.lightGray.withAlphaComponent(0.8)
        vi.layer.cornerRadius = 10
        vi.clipsToBounds = true
        vi.translatesAutoresizingMaskIntoConstraints = false
        vi.isUserInteractionEnabled = false
        return vi
    }()
    
    let lblTitle: UILabel = {
        let lbl = UILabel()
        lbl.text = IGStringsManager.IncreaseScore.rawValue.localized
        lbl.textColor = ThemeManager.currentTheme.iVandColor
        lbl.numberOfLines = 2
        lbl.font = UIFont.igFont(ofSize: 15, weight: .bold)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textAlignment = .center
        lbl.isUserInteractionEnabled = false
        return lbl
    }()
    private let mainView : UIView = {
           let vi = UIView()
            vi.backgroundColor = .clear
           vi.translatesAutoresizingMaskIntoConstraints = false
           return vi
       }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        makeView()
    }


    override func initView(dashboard: [IGPDiscoveryField]) {
        mainViewAbs = mainView
        img1Abs = nil
        view1Abs = nil
        Animations.circularShake(on: lblTitle)
        super.initView(dashboard: dashboard)

    }
    
    private func makeView() {
        makeCreditCellView()
    }
      private func removeCreditCellView() {
           lblStar.removeFromSuperview()
           lblYourScoreTitle.removeFromSuperview()
           lblYourScore.removeFromSuperview()
           viewSeparatorLine.removeFromSuperview()
           lblTitle.removeFromSuperview()
       }
       private func makeCreditCellView() {
        addSubview(mainView)
        mainView.addSubview(lblStar)
        mainView.addSubview(lblYourScoreTitle)
        mainView.addSubview(lblYourScore)
        mainView.addSubview(viewSeparatorLine)
        mainView.addSubview(lblTitle)
           
        NSLayoutConstraint.activate([mainView.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 8),
                                     mainView.trailingAnchor.constraint(equalTo: trailingAnchor,constant: -8),
                                     mainView.topAnchor.constraint(equalTo: topAnchor,constant: 4),
                                     mainView.bottomAnchor.constraint(equalTo: bottomAnchor,constant: -4)
        ])

        
           NSLayoutConstraint.activate([viewSeparatorLine.centerXAnchor.constraint(equalTo: centerXAnchor),
                                        viewSeparatorLine.centerYAnchor.constraint(equalTo: centerYAnchor),
                                        viewSeparatorLine.widthAnchor.constraint(equalToConstant: 2),
                                        viewSeparatorLine.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.65)
           ])
           
           NSLayoutConstraint.activate([lblStar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
                                        lblStar.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.7),
                                        lblStar.widthAnchor.constraint(equalTo: lblStar.heightAnchor),
                                        lblStar.centerYAnchor.constraint(equalTo: centerYAnchor)
           ])
           
           NSLayoutConstraint.activate([lblYourScoreTitle.bottomAnchor.constraint(equalTo: centerYAnchor),
                                        lblYourScoreTitle.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, multiplier: 0.5),
                                        lblYourScoreTitle.trailingAnchor.constraint(equalTo: viewSeparatorLine.leadingAnchor, constant: -8),
                                        lblYourScoreTitle.leadingAnchor.constraint(equalTo: lblStar.trailingAnchor, constant: 8)
           ])
           
           NSLayoutConstraint.activate([lblYourScore.leadingAnchor.constraint(equalTo: lblYourScoreTitle.leadingAnchor),
                                        lblYourScore.trailingAnchor.constraint(equalTo: lblYourScoreTitle.trailingAnchor),
                                        lblYourScore.topAnchor.constraint(equalTo: centerYAnchor, constant: 4),
                                        lblYourScore.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, multiplier: 0.5, constant: -4)
           ])
           
           NSLayoutConstraint.activate([lblTitle.leadingAnchor.constraint(equalTo: viewSeparatorLine.trailingAnchor, constant: 8),
                                        lblTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
                                        lblTitle.centerYAnchor.constraint(equalTo: centerYAnchor),
                                        lblTitle.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.9)
           ])
           
           getScore()
           
           layoutSubviews()
           lblTitle.layoutIfNeeded()
           Animations.circularShake(on: lblTitle)
           
           if LocaleManager.isRTL {
               self.semanticContentAttribute = .forceRightToLeft
               viewSeparatorLine.semanticContentAttribute = .forceRightToLeft
               lblStar.semanticContentAttribute = .forceRightToLeft
               lblYourScoreTitle.semanticContentAttribute = .forceRightToLeft
               lblYourScore.semanticContentAttribute = .forceRightToLeft
               lblTitle.semanticContentAttribute = .forceRightToLeft
           }else {
               self.semanticContentAttribute = .forceLeftToRight
               viewSeparatorLine.semanticContentAttribute = .forceLeftToRight
               lblStar.semanticContentAttribute = .forceLeftToRight
               lblYourScoreTitle.semanticContentAttribute = .forceLeftToRight
               lblYourScore.semanticContentAttribute = .forceLeftToRight
               lblTitle.semanticContentAttribute = .forceLeftToRight
           }
           lblStar.textColor = ThemeManager.currentTheme.iVandColor
           lblYourScore.textColor = ThemeManager.currentTheme.iVandColor
           lblTitle.textColor = ThemeManager.currentTheme.iVandColor

       }
       
    
       private func getScore(){
           lblYourScore.text = "..."
           IGUserIVandGetScoreRequest.Generator.generate().success({ [weak self] (protoResponse) in
               if let response = protoResponse as? IGPUserIVandGetScoreResponse {
                   DispatchQueue.main.async {
                       self?.lblYourScore.text = String(describing: response.igpScore).inRialFormat()
                   }
               }
           }).error({ [weak self] (errorCode, waitTime) in
               
               switch errorCode {
               case .timeout :
                   self?.getScore()
               default:
                   break
               }
           }).send()
       }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
