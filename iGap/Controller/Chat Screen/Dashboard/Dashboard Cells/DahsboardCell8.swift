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
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var basicBarChart: BasicBarChart!
    private let numEntry = 20
    var dashboardAbsPollInner: [IGPPollField]!
    var pollListInner: [IGPPoll] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        self.view.layer.cornerRadius = IGDashboardViewController.itemCorner

        barchart()
        
    }
    
    func barchart() {
        
        let timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) {[unowned self] (timer) in
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
        var result: [DataEntry] = []
   
        if dashboardAbsPollInner != nil {
            for elemnt in dashboardAbsPollInner {

                print("HEIGHT IS :")
                print(Float((elemnt.igpSum)) / 100)
                
                let tmpDataEntry = DataEntry(color: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), height: (Float((elemnt.igpSum)) / 100), textValue: String(elemnt.igpSum).inLocalizedLanguage(), title: elemnt.igpLabel)
                
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
