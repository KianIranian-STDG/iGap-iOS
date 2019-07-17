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
import IGProtoBuff

class DashboardCell8: AbstractDashboardCell {
    var result: [DataEntry] = []

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var basicBarChart: BeautifulBarChart!
    private let numEntry = 20
    var dashboardAbsPollInner: [IGPPollField]!
    var pollListInner: [IGPPoll] = []
    var tmpMax: [Int64] = []

    var lblHint : UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.view.layer.cornerRadius = IGDashboardViewController.itemCorner

        if IGGlobal.hideBarChart {
            lblHint = UILabel()
            lblHint.font = UIFont.igFont(ofSize: 13)
            lblHint.textAlignment = .center
            lblHint.textColor = UIColor.black.withAlphaComponent(0.8)
            lblHint.text = "MSG_VOTE_TO_SEE_CHART".localizedNew
            self.mainView!.addSubview(lblHint)
            self.mainView.bringSubviewToFront(lblHint)
            lblHint?.snp.makeConstraints { (make) in
                make.leading.equalTo(mainView.snp.leading).offset(8)
                make.trailing.equalTo(mainView.snp.trailing).offset(8)
                make.centerY.equalTo(mainView!.snp.centerY)
                make.centerX.equalTo(mainView!.snp.centerX)
            }
        }
        else {
            barchart()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateBar(_:)), name: NSNotification.Name(rawValue: "updateChart"), object: nil)
        
        // handle notification
        
    }
    @objc func updateBar(_ notification: NSNotification) {
        
//
            if let id = notification.userInfo?["id"] as? Int32 {
                
                getPollRequest(pageId: id)
                //                // do something with your image
//
//                for (index, element) in result.enumerated() {
//                    print(index, ":", element)
//                    if element.title == id  {
//                        print(index)
//                        var tmpResult = result[index]
//
//                        let tt = DataEntry(color: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), height: (Float(((tmpResult.textValue) as NSString).longLongValue + 1) / 100), textValue: String(((tmpResult.textValue) as NSString).longLongValue + 1).inLocalizedLanguage(), title: tmpResult.title)
//                        result.remove(at: index)
//                        result.insert(tt, at: index)
//                        self.basicBarChart.updateDataEntries(dataEntries: result, animated: true)
//
//
//                    }
//                }
//
        }
        }

    private func getPollRequest(pageId : Int32){
        
        
        IGPClientGetPollRequest.Generator.generate(pageId: pageId).successPowerful({ (protoResponse, requestWrapper) in
            if let response = protoResponse as? IGPClientGetPollResponse {

               
                self.dashboardAbsPollInner.removeAll()
                
                for elemnt in response.igpPolls {
                    for elemnt in elemnt.igpPollfields {
                        if elemnt.igpClickable == true {
                            self.dashboardAbsPollInner.append(elemnt)
                        }
                    }
                }
                DispatchQueue.main.async {

                self.barchart()
                }

            
            }
        }).error ({ (errorCode, waitTime) in
            
            switch errorCode {
            case .timeout:
                self.getPollRequest(pageId: pageId)
            default:
                break
            }
        }).send()
    }
    
    func barchart() {
        if lblHint != nil {
            lblHint.isHidden = true
            self.lblHint.removeFromSuperview()

        }
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {[unowned self] (timer) in
            let dataEntries = self.generateRandomDataEntries()
            self.basicBarChart.updateDataEntries(dataEntries: dataEntries, animated: true)
        }
        timer.fire()
        
    }
    func generateEmptyDataEntries() -> [DataEntry] {
        var result: [DataEntry] = []
        Array(0..<numEntry).forEach {_ in
            result.append(DataEntry(color: UIColor.clear, height: 0, textValue: "0", title: ""))
        }
        return result
    }
    
    func generateRandomDataEntries() -> [DataEntry] {
   
        if tmpMax.count > 0 {
            tmpMax.removeAll()
            
        }
        if result.count > 0 {
            result.removeAll()

        }

        if dashboardAbsPollInner != nil {
            
            for elemnt in dashboardAbsPollInner {
                tmpMax.append(elemnt.igpSum)
            }
            for elemnt in dashboardAbsPollInner {
                
                var t = elemnt.igpLabel
                if t.count > 19 {
                    t.removeLast((t.count) - 19)
                    t  = t + "..."
                }
                let tmpDataEntry = DataEntry(color: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), height: (Float(1 * (elemnt.igpSum) / tmpMax.max()!)), textValue: String(elemnt.igpSum).inRialFormat().inLocalizedLanguage(), title: t)
                
                result.append(tmpDataEntry)
            }
        }
        
        return result
    }
    class func nib() -> UINib {
        return UINib(nibName: "DashboardCell8", bundle: Bundle(for: self))
    }
    
    class func cellReuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
    
    public override func initView(dashboard: [IGPDiscoveryField]){
        mainViewAbs = mainView
        view1Abs = view
        super.initView(dashboard: dashboard)
    }
    public override func initViewPoll(dashboard: [IGPPollField]){
        mainViewAbs = mainView
        view1Abs = view
        super.initViewPoll(dashboard: dashboard)
    }
    
}
