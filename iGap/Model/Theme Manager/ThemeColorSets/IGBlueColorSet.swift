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

class BlueColorSet: DayNightColorSetProtocol {

    
    
    var TVCellTitleColor: UIColor  = UIColor(named: "IGTVCellTitleColor")!
    
    var CellFavouriteChannellBGColor: UIColor = UIColor(named: "CellFavouriteChannellBGColor")!
    
    var CellSelectedChannelBGColor: UIColor = UIColor(named: "CellSelectedChannelBGColor")!
        
    var ProgressMainColor: UIColor = UIColor(named: "ProgressMainColor")!
    
    var ProgressBackgroundMainColor: UIColor = UIColor(named: "ProgressBackgroundMainColor")!
    
    var TransactionsCVColor: UIColor = UIColor(named: "IGTransactionsCVColor")!
    
    var TransactionsCVSelectedColor: UIColor = UIColor(named: "IGTransactionsCVSelectedColor")!
    
    var LabelFinancialServiceColor: UIColor = UIColor(named: "LabelFinancialServiceColor")!
    
    var CustomAlertBGColor: UIColor = UIColor(named: "IGCustomAlertBGColor")!
    
    var CustomAlertBorderColor: UIColor = UIColor(named: "IGCustomAlertBorderColor")!
    
    var MessageLogCellBGColor: UIColor = UIColor(named: "IGMessageLogCellBGColor")!
    
    var MessageTextColor: UIColor = UIColor(named: "IGMessageTextColor")!
    var MessageTextReceiverColor: UIColor = .white
    var MessageTimeLabelColor: UIColor = UIColor(named: "IGMessageTimeLabelColor")!
            
    var SendMessageBubleBGColor: UIColor = UIColor(named: "IGSendMessageBubleBGColor")!
        
    var BackGroundColor: UIColor = UIColor(named: "IGBackGroundColor")!
    
    var BackGroundGrayColor: UIColor = UIColor(named: "IGBackGroundGrayColor")!
            
    var DashboardCellBackgroundColor: UIColor = UIColor(named: "IGDashboardCellBackgroundColor")!
    
    var LabelColor: UIColor = UIColor(named: "IGLabelColor")!
    
    var LabelGrayColor: UIColor = UIColor(named: "IGLabelGrayColor")!
    
    var LabelSecondColor: UIColor = UIColor(named: "IGLabelSecondColor")!
    
    var ModalViewBackgroundColor: UIColor = UIColor(named: "IGModalViewBackgroundColor")!
    
    var ProgressBackgroundColor: UIColor = UIColor(named: "IGProgressBackgroundColor")!
    
    var ProgressColor: UIColor = UIColor(named: "IGProgressColor")!
    
    var RecentTVCellColor: UIColor = UIColor(named: "IGRecentTVCellColor")!
    
    var SearchBarBackGroundColor: UIColor = UIColor(named: "IGSearchBarBackGroundColor")!
    
    var SplashBackgroundColor: UIColor = UIColor(named: "IGSplashBackgroundColor")!
        
    var TabbarColorLabel: UIColor = UIColor(named: "IGTabbarColorLabel")!
    
    var TableViewBackgroundColor: UIColor = UIColor(named: "IGTableViewBackgroundColor")!
    
    var TableViewCellColor: UIColor = UIColor(named: "IGTableViewCellColor")!
    
    var TextFieldBackGround: UIColor = UIColor(named: "IGTextFieldBackGround")!
    
    var TextFieldPlaceHolderColor: UIColor = UIColor(named: "IGTextFieldPlaceHolderColor")!
    
    var TVCellIconColor: UIColor = UIColor(named: "IGTVCellIconColor")!
    
    var IGTVCellTitleColor: UIColor = UIColor(named: "IGTVCellTitleColor")!
    
    //change by Color Set
    
    var SettingDayReceiveBubble: UIColor = UIColor(named: "SettingDayReceiveBubbleBlue")!
    
    var SliderTintColor: UIColor = UIColor.hexStringToUIColor(hex: "4579FA")
        
    var CheckStatusColor: UIColor = UIColor.hexStringToUIColor(hex: "4579FA")
    
    var MessageCountColor: UIColor = UIColor.hexStringToUIColor(hex: "4579FA")
    
    var TabBarColor: UIColor = UIColor.hexStringToUIColor(hex: "EAEAEC")

    var TabBarTextColor: UIColor = UIColor.hexStringToUIColor(hex: "000000")

    var NavigationFirstColor: UIColor = UIColor.hexStringToUIColor(hex: "4579FA")
    
    var NavigationSecondColor: UIColor = UIColor.hexStringToUIColor(hex: "4579FA")

    var NavigationButtonTextColor: UIColor = UIColor.hexStringToUIColor(hex: "4579FA")

    var ReceiveMessageBubleBGColor: UIColor = UIColor.hexStringToUIColor(hex: "4579FA")

    var MessageUnreadCellBGColor: UIColor = UIColor.hexStringToUIColor(hex: "4579FA")

    var ButtonTextColor: UIColor = UIColor.hexStringToUIColor(hex: "4579FA")

    var ButtonBGColor: UIColor = UIColor.hexStringToUIColor(hex: "4579FA")

    var BorderCustomColor: UIColor = UIColor.hexStringToUIColor(hex: "4579FA")

    var BorderColor: UIColor = UIColor.hexStringToUIColor(hex: "4579FA")
    
    var BadgeColor: UIColor = UIColor.hexStringToUIColor(hex: "4579FA")

    //tabbarIcons

    var TabIconContacts: UIImage = UIImage(named: "igContactListBlueLight")!
    
    var TabIconCallList: UIImage = UIImage(named: "igCallListBlueLight")!
    
    var TabIconRoomList: UIImage = UIImage(named: "igRoomListBlueLight")!
    
    var TabIconRoomIland: UIImage = UIImage(named: "igIlandBlueLight")!
    
    var TabIconRoomSettings: UIImage = UIImage(named: "igSettingBlueLight")!

    
    
    
    
    
    
    
    
    
    var TableCellMainBGColor: UIColor = .black
    
    var TableCellSecondaryBGColor: UIColor  = .black
    
    var BorderMainColor: UIColor  = .black
    
    var BorderSecondaryColor: UIColor  = .black
    
    var LabelMainTextColor: UIColor = UIColor.black
    
    var LabelSecondaryTextColor: UIColor = .black
    
    var ViewMainBGColor: UIColor = .black

    var ViewSecondaryBGColor: UIColor = .black
    
    var TableViewMainBGColor: UIColor = .black
    
    var TableViewSecondaryBGColor: UIColor = .black
    
    var ButtonMainBGColor: UIColor = .black
    
    var ButtonSecondaryBGColor: UIColor = .black
    
    var ButtonTitleMainColor: UIColor = .black
    
    var ButtonTitleSecondaryColor: UIColor = .black
    
    var NavigationFirstBGColor: UIColor = .black
    
    var NavigationSecondaryBGColor: UIColor = .black
        
    var TabbarMainBGColor: UIColor = .black
    
    var TabbarSecondaryBGColor: UIColor = .black
    
    var TabbarTitleTextColor: UIColor = .black
    
    
}

