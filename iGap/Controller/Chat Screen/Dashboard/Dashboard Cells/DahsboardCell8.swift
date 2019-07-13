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
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
        let colors = [#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1), #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1), #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)]
        var result: [DataEntry] = []
        
        result = [
            DataEntry(color: UIColor.red, height: 0.2, textValue: "20", title: "میثم زمانی بنیامین مختارپور ابوالفضل"),
            DataEntry(color: UIColor.green, height: 0.7, textValue: "70", title: "Some title")
        ]
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
