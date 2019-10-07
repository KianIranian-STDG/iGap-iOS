/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import Foundation


@objc class SMDateUtil: NSObject {
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
                return "TODAY".localizedNew
            } else if (currentYear) == year! && (currentMonth) == month && (currentDay) == day + 1 {
                return "YESTERDAY".localizedNew

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
                return "TODAY".localizedNew
            } else if (calendar.component(.year, from: date)) == year! && (calendar.component(.month, from: date)) == month && (calendar.component(.day, from: date)) == day + 1 {
                return "YESTERDAY".localizedNew

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
        
        return startFormatted + " " + "to".localized + " " + endFormatted
        
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
        
        return startFormatted + " " + "to".localized + " " + endFormatted
        
    }
    
    static func getJalaliTimeRangeForEvent(_ start: Int, end: Int) -> String {
        return militaryTimeConversion(start) + " " + "to".localized + " " + militaryTimeConversion(end)
    }
    
    static func convertEpochToPersianTimestamp(epoch: String) -> String {
        return toPersian(Date(timeIntervalSince1970: Double(epoch)!/1000.0)).inLocalizedLanguage()
    }
    
    
}
