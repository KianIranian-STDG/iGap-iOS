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

protocol ThemeProtocol {
    //*****Labels*********//
    var LabelMainTextColor : UIColor { get }
    var LabelSecondaryTextColor : UIColor { get }
    //*****Views*********//
    var ViewMainBGColor : UIColor { get }
    var ViewSecondaryBGColor : UIColor { get }
    //*****TableViews*********//
    var TableViewMainBGColor : UIColor { get }
    var TableViewSecondaryBGColor : UIColor { get }
    //*****Buttons*********//
    var ButtonMainBGColor : UIColor { get }
    var ButtonSecondaryBGColor : UIColor { get }
    var ButtonTitleMainColor : UIColor { get }
    var ButtonTitleSecondaryColor : UIColor { get }
    //*****Navigation*********//
    var NavigationFirstBGColor : UIColor { get }
    var NavigationSecondaryBGColor : UIColor { get }
    var NavigationButtonTextColor : UIColor { get }
    //*****Tabbar*********//
    var TabbarMainBGColor : UIColor { get }
    var TabbarSecondaryBGColor : UIColor { get }
    var TabbarTitleTextColor : UIColor { get }
    //*****Cell*********//
    var TableCellMainBGColor : UIColor { get }
    var TableCellSecondaryBGColor : UIColor { get }
    //MARK: - favouriteChannel
    var CellFavouriteChannellBGColor : UIColor { get }
    var CellSelectedChannelBGColor : UIColor { get }

    //*****Border*********//
    var BorderMainColor : UIColor { get }
    var BorderSecondaryColor : UIColor { get }
    var BorderCustomColor : UIColor { get }
    //*****Old Color Sets*********//
    var ProgressMainColor : UIColor { get }
    var ProgressBackgroundMainColor : UIColor { get }
    //MARK: - Financial Service
    var TransactionsCVColor : UIColor { get }
    var TransactionsCVSelectedColor : UIColor { get }
    var LabelFinancialServiceColor : UIColor { get }
    //MARK: - Message Colors
    var CustomAlertBGColor : UIColor { get }
    var CustomAlertBorderColor : UIColor { get }
    var MessageLogCellBGColor : UIColor { get }
    var MessageTextColor : UIColor { get }
    var MessageTimeLabelColor : UIColor { get }
    var MessageUnreadCellBGColor : UIColor { get }
    var ReceiveMessageBubleBGColor : UIColor { get }
    var SendMessageBubleBGColor : UIColor { get }
    //MARK: - Navigation Colors
    var NavigationFirstColor : UIColor { get }
    var NavigationSecondColor : UIColor { get }
    //MARK: - Other Colors
    var BackGroundColor : UIColor { get }
    var BackGroundGrayColor : UIColor { get }
    var ButtonBGColor : UIColor { get }
    var ButtonTextColor : UIColor { get }
    var DashboardCellBackgroundColor : UIColor { get }
    var LabelColor : UIColor { get }
    var LabelGrayColor : UIColor { get }
    var LabelSecondColor : UIColor { get }
    var ModalViewBackgroundColor : UIColor { get }
    var ProgressBackgroundColor : UIColor { get }
    var ProgressColor : UIColor { get }
    var RecentTVCellColor : UIColor { get }
    var SearchBarBackGroundColor : UIColor { get }
    var SplashBackgroundColor : UIColor { get }
    var TabBarColor : UIColor { get }
    var TabbarColorLabel : UIColor { get }
    var TableViewBackgroundColor : UIColor { get }
    var TableViewCellColor : UIColor { get }
    var TextFieldBackGround : UIColor { get }
    var TextFieldPlaceHolderColor : UIColor { get }
    var TVCellIconColor : UIColor { get }
    var TVCellTitleColor : UIColor { get }
}