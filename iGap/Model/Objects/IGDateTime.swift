//
//  IGDateTime.swift
//  iGap
//
//  Created by ahmad mohammadi on 5/2/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation

//struct IGDateTime {
//
//    enum DateError: Error {
//        case error
//    }
//
//    var date: IGDate?
//    var time: IGTime?
//
//    init() {
//
//    }
//
//    init(date: IGDate, time: IGTime) {
//        self.date = date
//        self.time = time
//    }
//
//    init(date: IGDate) {
//        self.date = date
//        self.time = IGTime(hour: 0, minute: 0)
//    }
//
//    struct IGDate {
//        var year: Int
//        var month: Int
//        var day: Int
//
//        init(year: Int, month: Int, day: Int) {
//            self.year = year
//            self.month = month
//            self.day = day
//        }
//
//        init(year: Int, month: Int) {
//            self.year = year
//            self.month = month
//            self.day = 1
//        }
//
//    }
//
//    struct IGTime {
//        var hour: Int
//        var minute: Int
//        var second: Int
//
//        init(hour: Int, minute: Int, second: Int) {
//            self.hour = hour
//            self.minute = minute
//            self.second = second
//        }
//
//        init(hour: Int, minute: Int) {
//            self.hour = hour
//            self.minute = minute
//            self.second = 0
//        }
//    }
//
//    // MARK: - Methods
//    func toMobileBankString() -> String {
//        if date == nil {
//            return ""
//        }
//        if time == nil {
//            return ""
//        }
//
//        return "\(date!.year)-\(date!.month)-\(date!.day) \(time!.hour):\(time!.minute):\(time!.second)"
//    }
//
//    func toGregorian() throws -> IGDateTime {
//
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        formatter.calendar = Calendar(identifier: .persian)
//        let jalaliDate = formatter.date(from: "\(date!.year)-\(date!.month)-\(date!.day)")
//        formatter.calendar = Calendar(identifier: .gregorian)
//
//        guard let jDate = jalaliDate else {
//            throw DateError.error
//        }
//
//        let cal = Calendar(identifier: .gregorian)
//
//        return IGDateTime(date: IGDate(year: cal.component(.year, from: jDate), month: cal.component(.month, from: jDate), day: cal.component(.day, from: jDate)), time: time!)
//
//    }
//
//
//    func toJalali() throws -> IGDateTime {
//
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        formatter.calendar = Calendar(identifier: .gregorian)
//        let jalaliDate = formatter.date(from: "\(date!.year)-\(date!.month)-\(date!.day)")
//        formatter.calendar = Calendar(identifier: .persian)
//
//        guard let jDate = jalaliDate else {
//            throw DateError.error
//        }
//
//        let cal = Calendar(identifier: .persian)
//
//        return IGDateTime(date: IGDate(year: cal.component(.year, from: jDate), month: cal.component(.month, from: jDate), day: cal.component(.day, from: jDate)), time: time!)
//
//    }
//
//
//    func getMonth() -> Int {
//
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//
//        guard let mDate = formatter.date(from: "\(date!.year)-\(date!.month)-\(date!.day)") else {
//            return 0
//        }
//        return Calendar.current.component(.month, from: mDate)
//
//    }
//
//
//    func monthNumToString() -> String {
//
//        let num = self.getMonth()
//
//        switch num {
//        case 1:
//            return "فروردین"
//        case 2:
//            return "اردیبهشت"
//        case 3:
//            return "خرداد"
//        case 4:
//            return "تیر"
//        case 5:
//            return "مرداد"
//        case 6:
//            return "شهریور"
//        case 7:
//            return "مهر"
//        case 8:
//            return "آبان"
//        case 9:
//            return "آذر"
//        case 10:
//            return "دی"
//        case 11:
//            return "بهمن"
//        case 12:
//            return "اسفند"
//        default:
//            return ""
//        }
//
//    }
//
//
//    // MARK: - Static Methods
//
//    static func todayJalali() -> IGDateTime{
//
//        let today = Date()
//        let cal = Calendar(identifier: .persian)
//
//        let todayDate = IGDate(year: cal.component(.year, from: today), month: cal.component(.month, from: today), day: cal.component(.day, from: today))
//
//        let todayTime = IGTime(hour: cal.component(.hour, from: today), minute: cal.component(.minute, from: today), second: cal.component(.second, from: today))
//
//        return IGDateTime(date: todayDate, time: todayTime)
//
//    }
//
//    static func todayGregorian() -> IGDateTime {
//
//        let today = Date()
//        let cal = Calendar(identifier: .gregorian)
//
//        let todayDate = IGDate(year: cal.component(.year, from: today), month: cal.component(.month, from: today), day: cal.component(.day, from: today))
//
//        let todayTime = IGTime(hour: cal.component(.hour, from: today), minute: cal.component(.minute, from: today), second: cal.component(.second, from: today))
//
//        return IGDateTime(date: todayDate, time: todayTime)
//
//    }
//
//}



@objc class IGDateTime: NSObject {
    static var sdfTime: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    static let weeks: [String] = [
        "یکشنبه", "دوشنبه", "سه شنبه",
        "چهار شنبه", "پنجشنبه", "جمعه", "شنبه"
    ]
    static let months: [String] = [
        "فروردین", "اردیبهشت", "خرداد",
        "تیر", "مرداد", "شهریور",
        "مهر", "آبان", "آذر",
        "دی", "بهمن", "اسفند"
    ]
    static let Weeks_eng: [String] = [
        "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    static let months_eng: [String] = [
        "January", "February", "March", "April", "May", "June", "July", "August",
        "September", "October", "November", "December"]
    static var monthMap: [String: Int] {
        var tmp = [String: Int]()
        var c = 0
        for m in months {
            tmp[m] = c + 1
            c += 1
        }
        return tmp
    }
    
    
    /**
     * it will convert a persian date string to NSDate
     *
     * @return NSDate of persian date string
     */
    static func persianToDate(_ year: Int, month: Int, day: Int, hour: Int? = nil, minute: Int? = nil) -> Date? {
        let calendar = Calendar(identifier: Calendar.Identifier.persian)
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        return calendar.date(from: components)
    }
    
    static func gregorianToDate(_ year: Int, month: Int, day: Int, hour: Int? = nil, minute: Int? = nil) -> Date? {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.timeZone = TimeZone(abbreviation: "GMT")!
        return calendar.date(from: components)
    }
    
    
    static func toPersianDayOfWeek(_ date: Date) -> String {
        let calendar = Calendar(identifier: Calendar.Identifier.persian)
        return weeks[((calendar as NSCalendar?)?.component(NSCalendar.Unit.weekday, from: date))! - 1]
    }
    static func toGerigorianDayOfWeek(_ date: Date) -> String {
        let calendar = Calendar(identifier: Calendar.Identifier.persian)
        return Weeks_eng[((calendar as NSCalendar?)?.component(NSCalendar.Unit.weekday, from: date))! - 1]
    }
    
    /**
     * convert a new NSDate() to a persian date String
     *
     * @return converted new Date() as a persian date String
     */
    static func toPersian() -> String {
        return toPersian(Date());
    }
    
    /**
     * convert a java.util.date to a persian date String
     *
     * @param date a java.util.date which we want to convert as a persian date string
     * @return converted date as a persian date String
     */
    static func toPersian(_ date: Date) -> String {
        let calendar = Calendar(identifier: Calendar.Identifier.persian)
        let day = (calendar as NSCalendar?)?.component(NSCalendar.Unit.day, from: date)
        let month = (calendar as NSCalendar?)?.component(.month, from: date)
        let year = (calendar as NSCalendar?)?.component(.year, from: date)
        let time = sdfTime.string(from: date)
        let m = months[month! - 1]
        return String(day!) + " " + m + " " + String(year!) + " " + time
    }
    static func toPersianWithoutDay(_ date: Date) -> String {
        let calendar = Calendar(identifier: Calendar.Identifier.persian)
        let month = (calendar as NSCalendar?)?.component(.month, from: date)
        let year = (calendar as NSCalendar?)?.component(.year, from: date)
        let m = months[month! - 1]
        return  m + " " + String(year!)
    }
    static func toPersianWithoutDayNumeric(_ date: Date) -> String {
        let calendar = Calendar(identifier: Calendar.Identifier.persian)
        let month = (calendar as NSCalendar?)?.component(.month, from: date)
        let year = (calendar as NSCalendar?)?.component(.year, from: date)
        
        var monthString = String(month!)
        if month! < 10 {
            monthString = "0" + monthString
        }
        
        return  String(year!) + " " + monthString
    }
    static func toGregorianWithoutDay(_ date: Date) -> String {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let month = (calendar as NSCalendar?)?.component(.month, from: date)
        let year = (calendar as NSCalendar?)?.component(.year, from: date)
        let m = months[month! - 1]
        return  m + " " + String(year!)
    }

    static func toPersianYear(_ date: Date) -> String {
        let calendar = Calendar(identifier: Calendar.Identifier.persian)
        let year = (calendar as NSCalendar?)?.component(.year, from: date)
        return  String(year! + 1)
    }
    static func toGregorianYear(_ date: Date) -> String {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let year = (calendar as NSCalendar?)?.component(.year, from: date)
        return  String(year!)
    }

    static func toGregorian(_ date: Date) -> String {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let day = (calendar as NSCalendar?)?.component(NSCalendar.Unit.day, from: date)
        let month = (calendar as NSCalendar?)?.component(.month, from: date)
        let year = (calendar as NSCalendar?)?.component(.year, from: date)
        let time = sdfTime.string(from: date)
        let m = months_eng[month! - 1]
        return String(day!) + " " + m + " " + String(year!) + " " + time
    }
    
    static func toPersianOnlyDateLong(_ date: Date) -> String {
        let calendar = Calendar(identifier: Calendar.Identifier.persian)
        let day = (calendar as NSCalendar?)?.component(NSCalendar.Unit.day, from: date)
        let month = (calendar as NSCalendar?)?.component(.month, from: date)
        let year = (calendar as NSCalendar?)?.component(.year, from: date)
        let m = months[month! - 1]
        return String(day!) + " " + m + " " + String(year!)
    }
    static func toGregorianOnlyDateLong(_ date: Date) -> String {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let day = (calendar as NSCalendar?)?.component(NSCalendar.Unit.day, from: date)
        let month = (calendar as NSCalendar?)?.component(.month, from: date)
        let year = (calendar as NSCalendar?)?.component(.year, from: date)
        let m = months_eng[month! - 1]
        return String(day!) + " " + m + " " + String(year!)
    }
    
    static func toPersianOnlyDate(_ date: Date, showHour: Bool = false) -> String {
        let calendar = Calendar(identifier: Calendar.Identifier.persian)
        let day = (calendar as NSCalendar?)?.component(NSCalendar.Unit.day, from: date)
        let month = (calendar as NSCalendar?)?.component(.month, from: date)
        let year = (calendar as NSCalendar?)?.component(.year, from: date)
        let m = month!
        
        if showHour {
            let hour = (calendar as NSCalendar?)?.component(.hour, from: date)
            let minute = (calendar as NSCalendar?)?.component(.minute, from: date)
            return String(year!) + "/" + String(m) + "/" + String(day!) + "  -  " + String(hour!) + ":" + String(minute!)
        }
       return self.checkIfisTodayOrYesterdayPersian(year: year, month: month, day: day)
    }
    static func checkIfisTodayOrYesterdayPersian(year: Int!,month: Int!,day:Int!) -> String {
            let date = Date()
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd"
            let formattedDate = format.string(from: date)
            let calendar = Calendar(identifier: Calendar.Identifier.persian)
            let currentDay = (calendar as NSCalendar?)?.component(NSCalendar.Unit.day, from: date)
            let currentMonth = (calendar as NSCalendar?)?.component(.month, from: date)
            let currentYear = (calendar as NSCalendar?)?.component(.year, from: date)

            if (currentYear) == year! && (currentMonth) == month && (currentDay) == day {
                return IGStringsManager.Today.rawValue.localized
            } else if (currentYear) == year! && (currentMonth) == month && (currentDay) == day + 1 {
                return IGStringsManager.Yesterday.rawValue.localized

            } else {
                return String(year!) + "/" + String(month) + "/" + String(day!);
            }
            
    }
    
    static func checkIfisTodayOrYesterdayEnglish(year: Int!,month: Int!,day:Int!) -> String {
            let date = Date()
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd"
            let formattedDate = format.string(from: date)
            let calendar = Calendar.current

            if (calendar.component(.year, from: date)) == year! && (calendar.component(.month, from: date)) == month && (calendar.component(.day, from: date)) == day {
                return IGStringsManager.Today.rawValue.localized
            } else if (calendar.component(.year, from: date)) == year! && (calendar.component(.month, from: date)) == month && (calendar.component(.day, from: date)) == day + 1 {
                return IGStringsManager.Yesterday.rawValue.localized

            } else {
                return String(year!) + "/" + String(month) + "/" + String(day!);
            }
            
    }
    static func toGregorianOnlyDate(_ date: Date, showHour: Bool = false) -> String {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let day = (calendar as NSCalendar?)?.component(NSCalendar.Unit.day, from: date)
        let month = (calendar as NSCalendar?)?.component(.month, from: date)
        let year = (calendar as NSCalendar?)?.component(.year, from: date)
        let m = month!
        
        if showHour {
            let hour = (calendar as NSCalendar?)?.component(.hour, from: date)
            let minute = (calendar as NSCalendar?)?.component(.minute, from: date)
            return String(year!) + "/" + String(m) + "/" + String(day!) + "  -  " + String(hour!) + ":" + String(minute!)
        }
        
        return self.checkIfisTodayOrYesterdayEnglish(year: year, month: month, day: day)
    }
    
    static func toPersianMonthAndDate(_ date: Date) -> String {
        let calendar = Calendar(identifier: Calendar.Identifier.persian)
        let day = (calendar as NSCalendar?)?.component(NSCalendar.Unit.day, from: date)
        let month = (calendar as NSCalendar?)?.component(.month, from: date)
        let m = months[month! - 1]
        return String(day!) + " " + m;
    }
    static func toGregorianMonthAndDate(_ date: Date) -> String {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let day = (calendar as NSCalendar?)?.component(NSCalendar.Unit.day, from: date)
        let month = (calendar as NSCalendar?)?.component(.month, from: date)
        let m = months_eng[month! - 1]
        return String(day!) + " " + m;
    }
    
    static func toPersianDay(_ date: Date) -> String {
        let calendar = Calendar(identifier: Calendar.Identifier.persian)
        let day = (calendar as NSCalendar?)?.component(NSCalendar.Unit.day, from: date)
        return String(day!);
    }
    static func toGregorianDay(_ date: Date) -> String {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let day = (calendar as NSCalendar?)?.component(NSCalendar.Unit.day, from: date)
        return String(day!);
    }
    static func toTimeOnly(_ date: Date) -> String {
        return sdfTime.string(from: date);
    }
    
    static func toPersianYearMonthDayHoureMinuteWeekDay(_ value: Double) -> (Int?, Int?, Int?, Int?, Int?, String?) {
        return toPersianYearMonthDayHoureMinuteWeekDay(Date(timeIntervalSince1970: value))
    }
    static func toPersianYearMonthDayHoureMinuteWeekDay(_ date: Date) -> (Int?, Int?, Int?, Int?, Int?, String?) {
        let calendar = Calendar(identifier: Calendar.Identifier.persian)
        let year = (calendar as NSCalendar?)?.component(.year, from: date)
        let month = (calendar as NSCalendar?)?.component(.month, from: date)
        let day = (calendar as NSCalendar?)?.component(.day, from: date)
        let houre = (calendar as NSCalendar?)?.component(.hour, from: date)
        let minute = (calendar as NSCalendar?)?.component(.minute, from: date)
        let weekDay = toPersianDayOfWeek(date)
        return (year, month, day, houre, minute, weekDay)
    }
    
    static func toGregorianYearMonthDayHoureMinuteWeekDay(_ value: Double) -> (Int?, Int?, Int?, Int?, Int?, String?) {
        return toGregorianYearMonthDayHoureMinuteWeekDay(Date(timeIntervalSince1970: value))
    }
    static func toGregorianYearMonthDayHoureMinuteWeekDay(_ date: Date) -> (Int?, Int?, Int?, Int?, Int?, String?) {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let year = (calendar as NSCalendar?)?.component(.year, from: date)
        let month = (calendar as NSCalendar?)?.component(.month, from: date)
        let day = (calendar as NSCalendar?)?.component(.day, from: date)
        let houre = (calendar as NSCalendar?)?.component(.hour, from: date)
        let minute = (calendar as NSCalendar?)?.component(.minute, from: date)
        let weekDay = toGerigorianDayOfWeek(date)
        return (year, month, day, houre, minute, weekDay)
    }
    
    static func toHourMinute(_ date: Date) -> (Int?, Int?) {
        let calendar = Calendar(identifier: Calendar.Identifier.persian)
        let hour = (calendar as NSCalendar?)?.component(.hour, from: date)
        let minute = (calendar as NSCalendar?)?.component(.minute, from: date)
        return (hour, minute)
    }
    static func militaryTimeConversion(_ time: Int) -> String {
        let hour = time / 100;
        let minute = time % 100;
        return String(hour) + ":" + (minute > 9 ? String(minute): "0" + String(minute));
    }
    
    static func militaryTimeConversion(_ time: String) -> (Int?, Int?)? {
        if time.contains(":") {
            let data = time.split(separator: ":").map(String.init)
            return (Int(data[0]), Int(data[1]))
        }
        return nil
    }
    
    static func militaryTimeFromDate(_ date: Date) -> Int {
        let calendar = Calendar(identifier: Calendar.Identifier.persian)
        let unitFlags: NSCalendar.Unit = [.hour, .minute]
        let comps = (calendar as NSCalendar).components(unitFlags, from: date)
        return comps.hour! * 100 + comps.minute!
    }
    
    static func relativeDiffFromNowInDetail(_ date: Date) -> String {
        
        
        let now = Date()
        let diffSeconds = (now.timeIntervalSince1970 - date.timeIntervalSince1970);
        let diffMinutes = Int(diffSeconds / (60));
        let diffHours = Int(diffSeconds / (60 * 60));
        let diffDays = Int(diffSeconds / (24 * 60 * 60));
        var relativeTime = "";
        if diffDays > 90 {
            relativeTime = String.RightToLeftMark + toPersianOnlyDate(date) + " " + toTimeOnly(date) + String.RightToLeftMark;
        } else if diffDays > 6 {
            relativeTime = String.RightToLeftMark + toPersianMonthAndDate(date) + " " + toTimeOnly(date) + String.RightToLeftMark;
        } else if diffDays > 1 {
            relativeTime = String.RightToLeftMark + toPersianDayOfWeek(date) + " " + toTimeOnly(date) + String.RightToLeftMark;
        } else if diffDays > 0 {
            relativeTime = String.RightToLeftMark + "دیروز " + toTimeOnly(date) + String.RightToLeftMark;
        } else if diffHours > 4 {
            let calendar = Calendar.current
            let unitFlags: NSCalendar.Unit = [.day]
            let nowComponents = (calendar as NSCalendar).components(unitFlags, from: now)
            let dateComponents = (calendar as NSCalendar).components(unitFlags, from: date)
            if dateComponents.day != nowComponents.day {
                relativeTime = String.RightToLeftMark + "دیروز " + toTimeOnly(date) + String.RightToLeftMark;
            } else {
                relativeTime = toTimeOnly(date);
            }
        } else if diffMinutes > 59 {
            relativeTime = String.RightToLeftMark + String(diffHours) + " ساعت قبل" + String.RightToLeftMark;
        } else if diffMinutes > 4 {
            relativeTime = String.RightToLeftMark + String(diffMinutes) + " دقیقه قبل" + String.RightToLeftMark;
        } else {
            relativeTime = " چند لحظه پیش";
        }
        return relativeTime.inLocalizedLanguage();
        
    }
    static func relativeDiffFromNow(_ date: Date) -> String {
        let now = Date()
        let diffSeconds = (now.timeIntervalSince1970 - date.timeIntervalSince1970);
        //        let diffMinutes = diffSeconds / (60);
        //        let diffHours = diffSeconds / (60 * 60);
        let diffDays = Int(diffSeconds / (24 * 60 * 60));
        var relativeTime = "";
        if  diffDays > 90 {
            relativeTime = toPersianOnlyDate(date)
        } else if diffDays > 6 {
            relativeTime = toPersianMonthAndDate(date)
        } else if diffDays > 1 {
            relativeTime = toPersianDayOfWeek(date)
        } else if diffDays > 0 {
            relativeTime = " دیروز ";
        } else {
            let calendar = Calendar.current
            let unitFlags: NSCalendar.Unit = [.day]
            let nowComponents = (calendar as NSCalendar).components(unitFlags, from: now)
            let dateComponents = (calendar as NSCalendar).components(unitFlags, from: date)
            if dateComponents.day != nowComponents.day {
                relativeTime = " دیروز "
            } else {
                relativeTime = toTimeOnly(date);
            }
        }
        return relativeTime.inLocalizedLanguage()
    }
    
    static func getJalaliDateRangeForEvent(_ start: Date, end: Date) -> String {
        let calendar = Calendar(identifier: Calendar.Identifier.persian)
        
        var endFormatted = toPersianOnlyDateLong(end)
        let unitFlags: NSCalendar.Unit = [.month, .year]
        let endComponents = (calendar as NSCalendar).components(unitFlags, from: end)
        let currentComponents = (calendar as NSCalendar).components(unitFlags, from: Date())
        
        if endComponents.year == currentComponents.year {
            endFormatted = toPersianMonthAndDate(end)
        }
        
        var startFormatted = toPersianOnlyDateLong(start)
        let startComponents = (calendar as NSCalendar).components(unitFlags, from: start)
        if endComponents.year == startComponents.year {
            if endComponents.month == startComponents.month {
                startFormatted = toPersianDay(start)
            } else {
                startFormatted = toPersianMonthAndDate(start)
            }
        }
        
        if (calendar as NSCalendar).compare(start, to: end, toUnitGranularity: .day) == .orderedSame {
            return endFormatted
        }
        
        return startFormatted + " " + IGStringsManager.To.rawValue.localized + " " + endFormatted
        
    }
    
    static func getGregorianDateRangeForEvent(_ start: Date, end: Date) -> String {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        var endFormatted = toGregorianOnlyDateLong(end)
        let unitFlags: NSCalendar.Unit = [.month, .year]
        let endComponents = (calendar as NSCalendar).components(unitFlags, from: end)
        let currentComponents = (calendar as NSCalendar).components(unitFlags, from: Date())
        
        if endComponents.year == currentComponents.year {
            endFormatted = toGregorianMonthAndDate(end)
        }
        
        var startFormatted = toGregorianOnlyDateLong(start)
        let startComponents = (calendar as NSCalendar).components(unitFlags, from: start)
        if endComponents.year == startComponents.year {
            if endComponents.month == startComponents.month {
                startFormatted = toGregorianDay(start)
            } else {
                startFormatted = toGregorianMonthAndDate(start)
            }
        }
        
        if (calendar as NSCalendar).compare(start, to: end, toUnitGranularity: .day) == .orderedSame {
            return endFormatted
        }
        
        return startFormatted + " " + IGStringsManager.To.rawValue.localized + " " + endFormatted
        
    }
    
    static func getJalaliTimeRangeForEvent(_ start: Int, end: Int) -> String {
        return militaryTimeConversion(start) + " " + IGStringsManager.To.rawValue.localized + " " + militaryTimeConversion(end)
    }
    
    static func convertEpochToPersianTimestamp(epoch: String) -> String {
        return toPersian(Date(timeIntervalSince1970: Double(epoch)!/1000.0)).inLocalizedLanguage()
    }
    
    static func jalaliToMobileBankGregorianDateString(date: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.calendar = Calendar(identifier: .persian)
        let datee = dateFormatter.date(from: date)!
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: datee)
        
    }
    
    static func formattedDateTime(date: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.calendar = Calendar(identifier: .persian)
        let datee = dateFormatter.date(from: date)!
        dateFormatter.calendar = Calendar(identifier: .gregorian)

        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minutes = calendar.component(.minute, from: now)
        
        if datee > Date() {
            let dateItems = date.split(separator: "-")
            //return "\(dateItems[0])-\(dateItems[1])-" + String(IGDateTime.toPersianDay(Date())) + "\(hour):\(minutes):00"
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
//            return forma
            return formatter.string(from: Date())
            
//            df.dateFormat = "yyyy-MM-dd hh:mm:ss"
//            let now = df.stringFromDate(Date())
            
        }else {
            return (date + "23:59:59")
        }
        
        
        
    }
    
}
