//
//  customTestCell.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 7/27/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
import SnapKit

class customTestCell: UITableViewCell {
    var room:itemRoom? {
        didSet {
            guard let item = room else {return}
            if let name = item.roomName {
                avatarImage.image = item.avatar
                nameLabel.text = name
            }
            if let lastmsg = item.lastMessage {
                lastMsgLabel.text = lastmsg
            }
            if let time = item.lastMessageTime {
                timeLabel.text = time.inLocalizedLanguage()
            }
            if let unread = item.unreadCount {
                if unread == "0" {
                    unreadCountLabel.isHidden = true
                } else {
                    unreadCountLabel.isHidden = false
                    unreadCountLabel.text = unread.inLocalizedLanguage()
                }
            }
            if let initial = item.initilas {
                initialLabel.text = initial.inLocalizedLanguage()
            }
            let color = UIColor.hexStringToUIColor(hex: item.colorString!)
            initialLabel.backgroundColor = color
            
            switch item.type {
                
            case .chat:
                typeImage.image = UIImage(named: "IG_Settings_Chats")
                checkImage.isHidden = true
            case .group:
                typeImage.image = UIImage(named: "IG_Chat_List_Type_Group")
                checkImage.isHidden = true

            case .channel:
                typeImage.image = UIImage(named: "IG_Chat_List_Type_Channel")
                checkImage.isHidden = false

            case .UNRECOGNIZED(_):
                typeImage.image = UIImage(named: "IG_Settings_Chats")
                checkImage.isHidden = true

            }


            

      
        }
    }
    var width : Int = 0
    var nameLabel :UILabel = {
        let label = UILabel()
        label.font = UIFont.igFont(ofSize: 14,weight: .bold)
        label.textColor = .black
        label.textAlignment = label.localizedNewDirection
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var timeLabel :UILabel = {
        let label = UILabel()
        label.font = UIFont.igFont(ofSize: 10,weight: .light)
        label.textColor = .black
        label.textAlignment = NSTextAlignment.center
        label.text = label.text?.inLocalizedLanguage()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var lastMsgLabel  :UILabel = {
        let label = UILabel()
        label.font = UIFont.igFont(ofSize: 15,weight: .light)
        label.textColor = .black
        label.textAlignment = label.localizedNewDirection
        label.text = label.text?.inLocalizedLanguage()
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var unreadCountLabel :UILabel = {
        let label = UILabel()
        label.font = UIFont.igFont(ofSize: 10,weight: .light)
        label.textColor = .white
        label.textAlignment = NSTextAlignment.center
        label.text = label.text?.inLocalizedLanguage()
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var initialLabel :UILabel = {
        let label = UILabel()
        label.font = UIFont.igFont(ofSize: 15,weight: .bold)
        label.textColor = .black
        label.textAlignment = NSTextAlignment.center
        label.text = label.text?.inLocalizedLanguage()
        label.layer.cornerRadius = 27
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var avatarImage :UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill // image will never be strecthed vertially or horizontally
        img.translatesAutoresizingMaskIntoConstraints = false // enable autolayout
        img.layer.cornerRadius = 27
        img.clipsToBounds = true
        return img
    }()
    var typeImage = UIImageView()
    var checkImage = UIImageView()
    var stateImage = UIImageView()
    var lastMessageStateImage :UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill // image will never be strecthed vertially or horizontally
        img.translatesAutoresizingMaskIntoConstraints = false // enable autolayout
        img.layer.cornerRadius = 10
        img.clipsToBounds = true
        return img
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        unreadCountLabel.backgroundColor = UIColor.red

        timeLabel.text = "..."
        nameLabel.text = "..."
        checkImage.image = UIImage(named:"IG_Verify")
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(timeLabel)
        self.contentView.addSubview(lastMsgLabel)
        self.contentView.addSubview(unreadCountLabel)
        self.contentView.addSubview(initialLabel)
        self.contentView.addSubview(avatarImage)
        self.contentView.addSubview(typeImage)
        self.contentView.addSubview(stateImage)
        self.contentView.addSubview(lastMessageStateImage)
        self.contentView.addSubview(checkImage)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        makeInitialLabel()
        makeAvatar()
        makeTypeImage()
        makeTimeLabel()
        makeCheckImage()
        makeNameLabel()
        makeUnreadCountLabel()
        makeLastMessageLabel()
        makelastMessageStateImage()

        //        myLabel.frame = CGRect(x: 20, y: 0, width: 70, height: 30)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.avatarImage.image = nil
        self.nameLabel.text = nil
    }
    
    private func makeAvatar() {
        avatarImage.snp.makeConstraints { (make) in
            make.leading.equalTo(self.contentView.snp.leading).offset(12)
            make.width.equalTo(54)
            make.height.equalTo(54)
            make.centerY.equalTo(self.contentView.snp.centerY)
        }
        if avatarImage.image == UIImage(named : "2") {
            avatarImage.image = nil
            avatarImage.backgroundColor = .clear
        }
        
        
    }
    private func makeInitialLabel() {
        initialLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self.contentView.snp.leading).offset(12)
            make.width.equalTo(54)
            make.height.equalTo(54)
            make.centerY.equalTo(self.contentView.snp.centerY)
        }
    }
    
    private func makeTypeImage() {
        typeImage.snp.makeConstraints { (make) in
            make.leading.equalTo(self.avatarImage.snp.trailing).offset(2)
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.top.equalTo(self.avatarImage.snp.top)
        }
        
    }
    private func makestateImage() {
        stateImage.snp.makeConstraints { (make) in
            make.leading.equalTo(self.avatarImage.snp.trailing).offset(2)
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.top.equalTo(self.avatarImage.snp.top)
        }
    }
    private func makelastMessageStateImage() {
        lastMessageStateImage.snp.makeConstraints { (make) in
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-5)
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.bottom.equalTo(self.avatarImage.snp.bottom)
        }
    }
    private func makeTimeLabel() {
        timeLabel.snp.makeConstraints { (make) in
            make.trailing.equalTo(self.contentView.snp.trailing).offset(-12)
            make.width.equalTo(50)
            make.top.equalTo(self.avatarImage.snp.top)
        }
        
    }
    private func makeCheckImage() {
        checkImage.snp.makeConstraints { (make) in
            make.trailing.equalTo(self.timeLabel.snp.leading).offset(-10)
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.top.equalTo(self.avatarImage.snp.top)
        }
        
    }
    private func makeNameLabel() {
        nameLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self.typeImage.snp.trailing).offset(10)
            make.trailing.equalTo(self.checkImage.snp.leading).offset(-10)
            make.top.equalTo(self.avatarImage.snp.top)
        }
        
    }
    private func makeUnreadCountLabel() {

 
            unreadCountLabel.snp.makeConstraints { (make) in
                make.trailing.equalTo(self.timeLabel.snp.trailing).offset(-12)
                make.bottom.equalTo(self.avatarImage.snp.bottom)
                make.width.equalTo(20)
                make.height.equalTo(15)
                
            }
        unreadCountLabel.text =  unreadCountLabel.text?.inLocalizedLanguage()
       
    }

    private func makeLastMessageLabel() {
        lastMsgLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self.avatarImage.snp.trailing).offset(5)
            make.trailing.equalTo(self.unreadCountLabel.snp.leading).offset(0)
            make.bottom.equalTo(self.avatarImage.snp.bottom)
        }
        
        
    }
    private func initView(from : [itemRoom]) {
//        avatarImage.image = f
    }

}
