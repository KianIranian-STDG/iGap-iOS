//
//  barcodeScannerViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 3/7/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
import AVFoundation
import AMPopTip
import SwiftyRSA
import QRCodeReader

//enum SMBarcodeMode:String{
//    case Bills_Code128 = "org.iso.Code128";
//    case Payment_QR = "org.iso.QRCode";
//}


/// Type of product QR code
///
/// - khati: The taxi with source and destination and defined price
/// - gardeshi: the taxi without information about places and price
/// - Ajans: private taxi
enum SMTransportType: Int {
    case khati = 0;
    case gardeshi = 1;
    case Ajans    = 2;
}

/// Type of Payment pop up
///
/// - PopupNoProductTaxi: The taxi pop up shows the information of taxi and driver name, no price is provided at this type, so user must enter it
/// - PopupProductedTaxi: Taxi popup with product shows the information of taxi and driver name with price, the price could be increased by unit
/// - PopupUser: User popup is normal type to show receiver name and price
enum SMAmountPopupType: Int {
    case PopupNoProductTaxi = 0
    case PopupProductedTaxi = 1
    case PopupUser          = 2
}


/// At this class user scan a QR or enter the QR code, and pay to a normal user or a merchant
class SMBarCodeScannerViewController: UIViewController {
    
}

