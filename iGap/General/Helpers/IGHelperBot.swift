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
    let SPACE: CGFloat = 10
    let ROW_HEIGHT: CGFloat = 40
    let MAX_KEYBOARD_HEIGHT:CGFloat = 200
    
    var botArray : [[String:String]] = [[:]]
    var botDic1 : [String:String] = ["One":"1"]
    var botDic2 : [String:String] = ["Two1":"2", "Two2":"2"]
    var botDic3 : [String:String] = ["three1":"3", "three2":"3", "three3":"3"]
    
    func makeBotView() -> UIView {
        botArray = []
        botArray.append(botDic1)
        botArray.append(botDic3)
        botArray.append(botDic2)
        
        let rowCount = CGFloat(botArray.count)
        let rowWidth = SCREAN_WIDTH - (SPACE * 2)
        let rowHeight = (rowCount * (ROW_HEIGHT + SPACE)) + SPACE
        var keyboardHeight = rowHeight + (SPACE * 2) // do -> (SPACE * 2) because of -> offset(SPACE) for top & bottom , at mainStackView makeConstraints
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
            make.top.equalTo(parent.snp.top).offset(SPACE)
            make.left.equalTo(parent.snp.left).offset(SPACE)
            make.right.equalTo(parent.snp.right).offset(-SPACE)
            make.bottom.equalTo(parent.snp.bottom).offset(-SPACE)
            make.height.equalTo(rowHeight)
            make.width.equalTo(rowWidth)
        }
        
        for row in botArray {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.spacing = 10
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            for (key, _) in row {
                stackView.addArrangedSubview(makeBotButton(parentView: stackView, text: key))
            }
            mainStackView.addArrangedSubview(stackView)
        }
        
        return parent
    }
    
    private func makeBotButton(parentView: UIView, text: String) -> UIButton {
        let btn = UIButton()
        btn.titleLabel?.font = UIFont.igFont(ofSize: 17.0)
        btn.setTitle(text, for: UIControlState.normal)
        btn.removeUnderline()
        parentView.addSubview(btn)
        
        btn.backgroundColor = UIColor.organizationalColor()
        btn.layer.masksToBounds = false
        btn.layer.cornerRadius = 5.0
        btn.layer.shadowOffset = CGSize(width: 1, height: 3)
        btn.layer.shadowRadius = 3.0
        btn.layer.shadowOpacity = 0.5
        
        return btn
    }
}
