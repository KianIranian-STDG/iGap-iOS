/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import SnapKit

class IGHelperBot {
    
    static let shared = IGHelperBot()
    
    let SCREAN_WIDTH = UIScreen.main.bounds.width
    let OUT_LAYOUT_SPACE: CGFloat = 10
    let IN_LAYOUT_SPACE: CGFloat = 5
    let ROW_HEIGHT: CGFloat = 40
    let MAX_KEYBOARD_HEIGHT:CGFloat = 200
    let MIN_LAYOUT_WIDTH :CGFloat = 50
    
    func makeBotView(additionalArrayMain: [[IGStructAdditionalButton]]) -> UIView {
        
        let rowCount = CGFloat(additionalArrayMain.count)
        let rowWidth = SCREAN_WIDTH - (OUT_LAYOUT_SPACE * 2)
        let rowHeight = (rowCount * (ROW_HEIGHT + OUT_LAYOUT_SPACE)) + OUT_LAYOUT_SPACE
        var keyboardHeight = rowHeight + (OUT_LAYOUT_SPACE * 2) // do -> (SPACE * 2) because of -> offset(SPACE) for top & bottom , at mainStackView makeConstraints
        if keyboardHeight > MAX_KEYBOARD_HEIGHT {
            keyboardHeight = MAX_KEYBOARD_HEIGHT
        }
        
        let parent = UIScrollView()
        parent.backgroundColor = UIColor.white
        parent.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: Int(keyboardHeight))
        
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.distribution = .fillEqually
        mainStackView.spacing = 10
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        parent.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { (make) in
            make.top.equalTo(parent.snp.top).offset(OUT_LAYOUT_SPACE)
            make.left.equalTo(parent.snp.left).offset(OUT_LAYOUT_SPACE)
            make.right.equalTo(parent.snp.right).offset(-OUT_LAYOUT_SPACE)
            make.bottom.equalTo(parent.snp.bottom).offset(-OUT_LAYOUT_SPACE)
            make.height.equalTo(rowHeight)
            make.width.equalTo(rowWidth)
        }
        
        for row in additionalArrayMain {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.spacing = 10
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            for additionalButton in row {
                stackView.addArrangedSubview(makeBotButton(parentView: stackView, additionalButton: additionalButton))
            }
            mainStackView.addArrangedSubview(stackView)
        }
        
        return parent
    }
    
    private func makeBotButton(parentView: UIView, additionalButton: IGStructAdditionalButton) -> UIView {
        let view = UIView()
        let img = UIImageView()
        let btn = UIButton()
        
        btn.titleLabel?.textAlignment = NSTextAlignment.center
        view.addSubview(btn)
        
        let internalViewSize = ROW_HEIGHT - (IN_LAYOUT_SPACE * 2)
        
        if additionalButton.imageUrl != nil {
            img.image = UIImage(named: "IG_Map")
            view.addSubview(img)
            
            img.snp.makeConstraints { (make) in
                make.leading.equalTo(view.snp.leading).offset(IN_LAYOUT_SPACE)
                make.centerY.equalTo(view.snp.centerY)
                make.height.equalTo(internalViewSize)
                make.width.equalTo(internalViewSize)
            }
        }
        
        btn.snp.makeConstraints { (make) in
            if additionalButton.imageUrl != nil {
                make.leading.equalTo(img.snp.trailing).offset(IN_LAYOUT_SPACE)
            } else {
                make.leading.equalTo(view.snp.leading).offset(IN_LAYOUT_SPACE)
            }
            make.trailing.equalTo(view.snp.trailing).offset(-IN_LAYOUT_SPACE)
            make.centerY.equalTo(view.snp.centerY)
            make.height.equalTo(internalViewSize)
        }
        
        btn.titleLabel?.font = UIFont.igFont(ofSize: 17.0)
        btn.setTitle(additionalButton.lable, for: UIControlState.normal)
        btn.removeUnderline()
        
        view.backgroundColor = UIColor.organizationalColor()
        view.layer.masksToBounds = false
        view.layer.cornerRadius = 5.0
        view.layer.shadowOffset = CGSize(width: 1, height: 3)
        view.layer.shadowRadius = 3.0
        view.layer.shadowOpacity = 0.5

        parentView.addSubview(view)
        
        return view
    }
}
