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

class NightTheme: ThemeProtocol {
    var iVandColor: UIColor = NightColorSetManager.currentColorSet.iVandColor

    var replyMSGColor : UIColor = NightColorSetManager.currentColorSet.replyMSGColor

    var timeColor : UIColor = NightColorSetManager.currentColorSet.timeColor

    var TopViewHolderBGColor: UIColor = NightColorSetManager.currentColorSet.TopViewHolderBGColor
    
    
    
    var TVCellTitleColor: UIColor  = NightColorSetManager.currentColorSet.TVCellTitleColor
    
    var CellFavouriteChannellBGColor: UIColor = NightColorSetManager.currentColorSet.CellFavouriteChannellBGColor
    var CellSelectedChannelBGColor: UIColor = NightColorSetManager.currentColorSet.CellSelectedChannelBGColor
        
    var ProgressMainColor: UIColor = NightColorSetManager.currentColorSet.ProgressMainColor
    
    var ProgressBackgroundMainColor: UIColor = NightColorSetManager.currentColorSet.ProgressBackgroundMainColor
    
    var TransactionsCVColor: UIColor = NightColorSetManager.currentColorSet.TransactionsCVColor
    
    var TransactionsCVSelectedColor: UIColor = NightColorSetManager.currentColorSet.TransactionsCVSelectedColor
    
    var LabelFinancialServiceColor: UIColor = NightColorSetManager.currentColorSet.LabelFinancialServiceColor
    
    var CustomAlertBGColor: UIColor = NightColorSetManager.currentColorSet.CustomAlertBGColor
    
    var CustomAlertBorderColor: UIColor = NightColorSetManager.currentColorSet.CustomAlertBorderColor
    
    var MessageLogCellBGColor: UIColor = NightColorSetManager.currentColorSet.MessageLogCellBGColor
    
    var MessageTextColor: UIColor = NightColorSetManager.currentColorSet.MessageTextColor
    
    var MessageTextReceiverColor: UIColor = NightColorSetManager.currentColorSet.MessageTextReceiverColor

    var MessageTimeLabelColor: UIColor = NightColorSetManager.currentColorSet.MessageTimeLabelColor
            
    var SendMessageBubleBGColor: UIColor = NightColorSetManager.currentColorSet.SendMessageBubleBGColor
        
    var BackGroundColor: UIColor = NightColorSetManager.currentColorSet.BackGroundColor
    
    var BackGroundGrayColor: UIColor = NightColorSetManager.currentColorSet.BackGroundGrayColor
        
    var DashboardCellBackgroundColor: UIColor = NightColorSetManager.currentColorSet.DashboardCellBackgroundColor
    
    var LabelColor: UIColor = NightColorSetManager.currentColorSet.LabelColor
    
    var LabelGrayColor: UIColor = NightColorSetManager.currentColorSet.LabelGrayColor
    
    var LabelSecondColor: UIColor = NightColorSetManager.currentColorSet.LabelSecondColor
    
    var ModalViewBackgroundColor: UIColor = NightColorSetManager.currentColorSet.ModalViewBackgroundColor
    var ShadowColor: UIColor = NightColorSetManager.currentColorSet.ShadowColor

    var ProgressBackgroundColor: UIColor = NightColorSetManager.currentColorSet.ProgressBackgroundColor
    
    var ProgressColor: UIColor = NightColorSetManager.currentColorSet.ProgressColor
    
    var RecentTVCellColor: UIColor = NightColorSetManager.currentColorSet.RecentTVCellColor
    
    var SearchBarBackGroundColor: UIColor = NightColorSetManager.currentColorSet.SearchBarBackGroundColor
    
    var SplashBackgroundColor: UIColor = NightColorSetManager.currentColorSet.SplashBackgroundColor
        
    var TabbarColorLabel: UIColor = NightColorSetManager.currentColorSet.TabbarColorLabel
    
    var TableViewBackgroundColor: UIColor = NightColorSetManager.currentColorSet.TableViewBackgroundColor
    
    var TableViewCellColor: UIColor = NightColorSetManager.currentColorSet.TableViewCellColor
    
    var TextFieldBackGround: UIColor = NightColorSetManager.currentColorSet.TextFieldBackGround
    
    var TextFieldPlaceHolderColor: UIColor = NightColorSetManager.currentColorSet.TextFieldPlaceHolderColor
    
    var TVCellIconColor: UIColor = NightColorSetManager.currentColorSet.TVCellIconColor
    
    var IGTVCellTitleColor: UIColor = NightColorSetManager.currentColorSet.TVCellTitleColor


    
    
    //change by Color Set
    
    var SettingDayReceiveBubble: UIColor = NightColorSetManager.currentColorSet.SettingDayReceiveBubble

    var SliderTintColor: UIColor = NightColorSetManager.currentColorSet.SliderTintColor
        
    var CheckStatusColor: UIColor = NightColorSetManager.currentColorSet.CheckStatusColor
    
    var MessageCountColor: UIColor = NightColorSetManager.currentColorSet.MessageCountColor
    
    var TabBarColor: UIColor = NightColorSetManager.currentColorSet.TabBarColor

    var TabBarTextColor: UIColor = NightColorSetManager.currentColorSet.TabBarTextColor

    var NavigationFirstColor: UIColor = NightColorSetManager.currentColorSet.NavigationFirstColor
    
    var NavigationSecondColor: UIColor = NightColorSetManager.currentColorSet.NavigationSecondColor
    
    var NavigationButtonTextColor: UIColor = NightColorSetManager.currentColorSet.NavigationButtonTextColor

    var ReceiveMessageBubleBGColor: UIColor = NightColorSetManager.currentColorSet.ReceiveMessageBubleBGColor

    var MessageUnreadCellBGColor: UIColor = NightColorSetManager.currentColorSet.MessageUnreadCellBGColor

    var ButtonBGColor: UIColor = NightColorSetManager.currentColorSet.ButtonBGColor
    
    var ButtonTextColor: UIColor = NightColorSetManager.currentColorSet.ButtonTextColor

    var BorderCustomColor: UIColor = NightColorSetManager.currentColorSet.BorderCustomColor

    var BorderColor: UIColor = NightColorSetManager.currentColorSet.BorderColor

    var BadgeColor: UIColor = NightColorSetManager.currentColorSet.BadgeColor

    
    //tabbarIcons

    var TabIconContacts: UIImage = NightColorSetManager.currentColorSet.TabIconContacts
    
    var TabIconCallList: UIImage = NightColorSetManager.currentColorSet.TabIconCallList
    
    var TabIconRoomList: UIImage = NightColorSetManager.currentColorSet.TabIconRoomList
    
    var TabIconRoomIland: UIImage = NightColorSetManager.currentColorSet.TabIconRoomIland
    
    var TabIconRoomSettings: UIImage = NightColorSetManager.currentColorSet.TabIconRoomSettings

    //ChatBG
    var ChatBG: UIImage = NightColorSetManager.currentColorSet.ChatBG

    
    
    
    
    
    
    
    
    
    
    
    
    
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
