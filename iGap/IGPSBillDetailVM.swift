//
//  IGPSBillDetailVM.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 6/15/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
import IGProtoBuff
import PecPayment

class IGPSBillDetailVM : NSObject, BillMerchantResultObserver ,UIDocumentInteractionControllerDelegate{
    weak var vc : IGPSBillDetailVC?
    
    init(viewController: IGPSBillDetailVC) {
        self.vc = viewController
    }
    func queryElecBill(billType: String, telNum: String? = nil, billID: String? = nil) {
        IGLoading.showLoadingPage(viewcontroller: UIApplication.topViewController()!)
        IGApiBills.shared.queryElecBill(billType: billType, telNum: telNum!, billID: billID!)  {[weak self] (response, error) in
            guard let sSelf = self else {
                return
            }
            if error != nil {
                IGLoading.hideLoadingPage()
                IGHelperToast.shared.showCustomToast(showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.NavigationFirstColor, cancelBackColor: .clear, message: error, cancelText: IGStringsManager.GlobalClose.rawValue.localized, cancel: {})
                sSelf.vc?.billIsOK = false

                return
            } else {
                IGLoading.hideLoadingPage()
                sSelf.vc?.billPayNumber = response?.paymentIdentifier
                sSelf.vc?.billPayDeadLine = response?.paymentDeadLine
                sSelf.vc?.billPayAmount = response?.totalBillDebt
                sSelf.vc?.billIsOK = true
            }
            
        }
        
    }
    func queryGasBill(billType: String, billID: String? = nil) {
        IGLoading.showLoadingPage(viewcontroller: UIApplication.topViewController()!)
        IGApiBills.shared.queryGasBill(billType: billType, billID: billID!)  {[weak self] (response, error) in
            guard let sSelf = self else {
                return
            }
            if error != nil {
                IGLoading.hideLoadingPage()
                IGHelperToast.shared.showCustomToast(showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.NavigationFirstColor, cancelBackColor: .clear, message: error, cancelText: IGStringsManager.GlobalClose.rawValue.localized, cancel: {})
                sSelf.vc?.billIsOK = false

                return
            } else {
                IGLoading.hideLoadingPage()
                sSelf.vc?.billNumber = response?.billIdentifier
                sSelf.vc?.billPayNumber = response?.paymentIdentifier
                sSelf.vc?.billPayDeadLine = response?.paymentDeadLine
                sSelf.vc?.billPayAmount = response?.totalBillDebt
                sSelf.vc?.billIsOK = true

            }
            
        }
        
    }
    
    func queryPhoneBill(billType: String, telNum: String) {
        IGLoading.showLoadingPage(viewcontroller: UIApplication.topViewController()!)
        IGApiBills.shared.queryPhoneBill(billType: billType, telNum: telNum)  {[weak self] (response, error) in
            guard let sSelf = self else {
                return
            }
            if error != nil {
                IGLoading.hideLoadingPage()
                IGHelperToast.shared.showCustomToast(showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.NavigationFirstColor, cancelBackColor: .clear, message: error, cancelText: IGStringsManager.GlobalClose.rawValue.localized, cancel: {})
                sSelf.vc?.billIsOK = false

                return
            } else {
                IGLoading.hideLoadingPage()
                sSelf.vc?.billIsOK = true

                if response?.midTerm?.billId == nil {
                    sSelf.vc?.billNumber = "\(response?.lastTerm?.billId ?? 0)".inLocalizedLanguage()
                    sSelf.vc?.billPayNumber = "\(response?.lastTerm?.payId ?? 0)".inLocalizedLanguage()
                } else {
                    sSelf.vc?.billNumber = "\(response?.midTerm?.billId ?? 0)"
                    sSelf.vc?.billPayNumber = "\(response?.midTerm?.payId ?? 0)"
                }
                if response?.midTerm?.billId == nil {
                    sSelf.vc?.billPayAmount = "0".inLocalizedLanguage()

                } else {
                    sSelf.vc?.billPayAmount = "\(response?.midTerm?.amount ?? 0)".currencyFormat().inLocalizedLanguage()

                }
                if response?.lastTerm?.billId == nil {
                    sSelf.vc?.billPayDeadLine = "0".inLocalizedLanguage()

                } else {
                    sSelf.vc?.billPayDeadLine = "\(response?.lastTerm?.amount ?? 0)".currencyFormat().inLocalizedLanguage() + " " + IGStringsManager.Currency.rawValue.localized
                }


            }
            
        }
        
    }
    
    func queryMobileBill(billType: String, telNum: String) {
        IGLoading.showLoadingPage(viewcontroller: UIApplication.topViewController()!)
        IGApiBills.shared.queryMobileBill(billType: billType, telNum: telNum)  {[weak self] (response, error) in
            guard let sSelf = self else {
                return
            }
            if error != nil {
                IGLoading.hideLoadingPage()
                IGHelperToast.shared.showCustomToast(showCancelButton: true, cancelTitleColor: ThemeManager.currentTheme.NavigationFirstColor, cancelBackColor: .clear, message: error, cancelText: IGStringsManager.GlobalClose.rawValue.localized, cancel: {})
                sSelf.vc?.billIsOK = false

                return
            } else {
                IGLoading.hideLoadingPage()
                sSelf.vc?.billIsOK = true

                if response?.midTerm?.amount != nil {
                    
                }
                if response?.midTerm?.billId == nil {
                    sSelf.vc?.billNumber = response?.lastTerm?.billId!.inLocalizedLanguage()
                    sSelf.vc?.billPayNumber = response?.lastTerm?.payId!.inLocalizedLanguage()
                } else {
                    sSelf.vc?.billNumber = response?.midTerm?.billId
                    sSelf.vc?.billPayNumber = response?.midTerm?.payId
                }
                if response?.midTerm?.billId == nil {
                    sSelf.vc?.billPayAmount = "0".inLocalizedLanguage()

                } else {
                    sSelf.vc?.billPayAmount = response?.midTerm?.amount!.currencyFormat().inLocalizedLanguage()

                }
                if response?.lastTerm?.billId == nil {
                    sSelf.vc?.billPayDeadLine = "0".inLocalizedLanguage()

                } else {
                    sSelf.vc?.billPayDeadLine = (response?.lastTerm?.amount!.currencyFormat().inLocalizedLanguage())! + " " + IGStringsManager.Currency.rawValue.localized
                }
            }
        }
    }
    
    func paySequence(billID : String,payID : String,amount: Int) {
        
        if amount < 10000 {
            IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .warning, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: IGStringsManager.LessThan10000.rawValue.localized, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
            
        } else {
            IGLoading.showLoadingPage(viewcontroller: UIApplication.topViewController()!)
            IGMplGetBillToken.Generator.generate(billId: Int64(billID.inEnglishNumbersNew())!, payId: Int64(payID.inEnglishNumbersNew())!).success({ (protoResponse) in
                IGLoading.hideLoadingPage()
                if let mplGetBillTokenResponse = protoResponse as? IGPMplGetBillTokenResponse {
                    if mplGetBillTokenResponse.igpStatus == 0 { //success
                        self.initBillPaymanet(token: mplGetBillTokenResponse.igpToken)
                    } else {
                        IGHelperAlert.shared.showCustomAlert(view: nil, alertType: .alert, title: IGStringsManager.GlobalWarning.rawValue.localized, showIconView: true, showDoneButton: false, showCancelButton: true, message: mplGetBillTokenResponse.igpMessage, cancelText: IGStringsManager.GlobalClose.rawValue.localized)
                    }
                }
                
            }).error ({ (errorCode, waitTime) in
                IGLoading.hideLoadingPage()
                switch errorCode {
                case .timeout:
                    
                    break
                default:
                    break
                }
            }).send()
            
            
        }
    }
    private func initBillPaymanet(token: String){
        let initpayment = InitPayment()
        initpayment.registerBill(merchant: self)
        initpayment.initBillPayment(Token: token, MerchantVCArg: UIApplication.topViewController()!, TSPEnabled: 0)
    }
    func BillMerchantUpdate(encData: String, message: String, status: Int) {
        UIApplication.topViewController()?.navigationController?.popViewController(animated: true)
    }
    
    func BillMerchantError(errorType: Int) {
    }
    var billnum : String!
    var payDate : String!
    func getImageOfBill(userPhoneNumber: String!,billNumber: String!,payDate: String!) {
        IGApiElectricityBill.shared.getImageOfBill(billNumber: (billNumber.inEnglishNumbersNew()), phoneNumber: userPhoneNumber, completion: {(success, response, errorMessage) in
            IGLoading.hideLoadingPage()
            if success {
                self.billnum = (billNumber.inEnglishNumbersNew())
                self.payDate = (payDate.inEnglishNumbersNew())
                self.saveBase64StringToImage((response?.data?.document)!,ext: response?.data?.ext)
            } else {
                print(errorMessage)
            }
        })

    }
    private func saveBase64StringToImage(_ base64String: String,ext: String? = ".pdf") {

        guard
            var documentsURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last,
            let convertedData = Data(base64Encoded: base64String)
            else {
            //handle error when getting documents URL
            return
        }

        //name your file however you prefer
        documentsURL.appendPathComponent(self.billnum + self.payDate + ext!)

        do {
            try convertedData.write(to: documentsURL)
        } catch {
            //handle write error here
        }

        //if you want to get a quick output of where your
        //file was saved from the simulator on your machine
        //just print the documentsURL and go there in Finder
        print(documentsURL)
        //let path =  Bundle.main.path(forResource: "Guide", ofType: ".pdf")!
         let dc = UIDocumentInteractionController(url: documentsURL)
         dc.delegate = self
         dc.presentPreview(animated: true)

    }
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return (vc?.navigationController!)!
    }
}
