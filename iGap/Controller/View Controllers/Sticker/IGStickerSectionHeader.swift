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

class IGStickerSectionHeader: UICollectionReusableView {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var btnSticker: UIButton!
    
    var txtStickerTitle: UILabel!
    var txtStickerCount: UILabel!
    
    func configure(usingTitle title:String) {
        btnSticker.isHidden = true
        makeStickerTitle(isAddStickerPage: false)
        txtStickerTitle.text = "GREAT MINDS"
    }
    
    func configureAddSticker(usingTitle title:String, stickerCount: Int) {
        makeStickerTitle(isAddStickerPage: true)
        makeStickerCount()
        makeStickerAddButton()
        
        txtStickerTitle.text = "GREAT MINDS"
        txtStickerCount.text = "60 Sticker"
    }
    
    @IBAction func btnAddOrRemove(_ sender: UIButton) {
        
    }
    
    /******************************************/
    /*************** View Maker ***************/
    
    private func makeStickerTitle(isAddStickerPage: Bool){
        if txtStickerTitle == nil {
            txtStickerTitle = UILabel()
            mainView.addSubview(txtStickerTitle)
            
            if isAddStickerPage {
                txtStickerTitle.font = UIFont.igFont(ofSize: 15, weight: .bold)
                txtStickerTitle.textColor = UIColor.darkGray
                
                txtStickerTitle.snp.makeConstraints { (make) in
                    make.left.equalTo(mainView.snp.left).offset(10)
                    make.centerY.equalTo(mainView.snp.centerY).offset(-12)
                    make.width.greaterThanOrEqualTo(50)
                    make.height.equalTo(30)
                }
            } else {
                txtStickerTitle.font = UIFont.igFont(ofSize: 11, weight: .medium)
                txtStickerTitle.textColor = UIColor.replyBoxIncomming()
                
                txtStickerTitle.snp.makeConstraints { (make) in
                    make.left.equalTo(mainView.snp.left).offset(10)
                    make.centerY.equalTo(mainView.snp.centerY).offset(10)
                    make.width.greaterThanOrEqualTo(50)
                    make.height.equalTo(30)
                }
            }
        }
    }
    
    private func makeStickerCount(){
        if txtStickerCount == nil {
            txtStickerCount = UILabel()
            txtStickerCount.font = UIFont.igFont(ofSize: 11, weight: .medium)
            txtStickerCount.textColor = UIColor.replyBoxIncomming()

            mainView.addSubview(txtStickerCount)
            
            txtStickerCount.snp.makeConstraints { (make) in
                make.left.equalTo(mainView.snp.left).offset(10)
                make.centerY.equalTo(mainView.snp.centerY).offset(12)
                make.width.greaterThanOrEqualTo(50)
                make.height.equalTo(20)
            }
        }
    }
    
    private func makeStickerAddButton(){
        btnSticker.removeUnderline()
        btnSticker.layer.borderWidth = 1
        btnSticker.layer.borderColor = UIColor.blue.cgColor
        btnSticker.layer.cornerRadius = 8
        btnSticker.layer.masksToBounds = true
    }
}
