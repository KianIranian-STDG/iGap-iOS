//
//  RowFourCell.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 4/28/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class RowFourCell: BaseTableViewCell {

//    var dateComps: (Int?, Int?, Int?, Int?, Int?, String?)!
//
//        dateComps = SMDateUtil.toPersianYearMonthDayHoureMinuteWeekDay(payTimeSecond)

    var dateArray : [String] = []
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initView()
        

    }
    
    private func initView() {
        GetCurrentYear()
    }
    private func GetCurrentYear() {



    }
    private func generateMonth(from: String, to: String) {
        let datesBetweenArray = Date.printDatesBetweenInterval(Date.dateFromString(from), Date.dateFromString(to))

        print("DATE ARRAY IS:",datesBetweenArray)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension Date {
    static func printDatesBetweenInterval(_ startDate: Date, _ endDate: Date) {
        var startDate = startDate
        let calendar = Calendar.current

        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"

        while startDate <= endDate {
            print(fmt.string(from: startDate))
            startDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        }
    }

    static func dateFromString(_ dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        return dateFormatter.date(from: dateString)!
    }
}
