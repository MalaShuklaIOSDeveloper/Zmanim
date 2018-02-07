//
//  Date.swift
//  Zmanim
//
//  Created by Natanel Niazoff.
//  Copyright © 2017 Natanel Niazoff. All rights reserved.
//

import Foundation

extension Date {
    var isPastMidnightBeforeTwo: Bool {
        return hour > 0 && hour < 2
    }
    
    var yesterday: Date? {
        return Calendar.current.date(byAdding: .day, value: -1, to: self)
    }
    
    var shortDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: self)
    }
    
    var shortTimeString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: self)
    }
    
    var shortDateTimeString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: self)
    }
    
    var timeWithSecondsString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm:ss a"
        return dateFormatter.string(from: self)
    }
    
    var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }
    
    var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }
    
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    var weekday: Int {
        return Calendar.current.component(.weekday, from: self)
    }
    
    var isToday: Bool {
        return day == Date().day && month == Date().month && year == Date().year
    }
    
    func addingFullDay() -> Date {
        return self.addingTimeInterval(60 * 60 * 24)
    }
    
    func addingWeek() -> Date {
        return self.addingTimeInterval(60 * 60 * 24 * 7)
    }
    
    func setting(_ components: DateComponents, with calendar: Calendar) -> Date {
        let selfComponents = calendar.dateComponents(Calendar.Component.allComponents, from: self)
        let dateComponents = DateComponents(
            calendar: calendar,
            timeZone: components.timeZone ?? selfComponents.timeZone,
            era: components.era ?? selfComponents.era,
            year: components.year ?? selfComponents.year,
            month: components.month ?? selfComponents.month,
            day: components.day ?? selfComponents.day,
            hour: components.hour ?? selfComponents.hour,
            minute: components.minute ?? selfComponents.minute,
            second: components.second ?? selfComponents.second,
            nanosecond: components.nanosecond ?? selfComponents.nanosecond,
            weekday: components.weekday ?? selfComponents.weekday,
            weekdayOrdinal: components.weekdayOrdinal ?? selfComponents.weekdayOrdinal,
            quarter: components.quarter ?? selfComponents.quarter,
            weekOfMonth: components.weekOfMonth ?? selfComponents.weekOfMonth,
            weekOfYear: components.weekOfYear ?? selfComponents.weekOfYear,
            yearForWeekOfYear: components.yearForWeekOfYear ?? selfComponents.yearForWeekOfYear)
        return calendar.date(from: dateComponents)!
    }
    
    func closestFutureDate(_ date1: Date, date2: Date) -> Date? {
        let date1Interval = date1.timeIntervalSince(self)
        let date2Interval = date2.timeIntervalSince(self)
        if (date1Interval.sign == .minus) && (date2Interval.sign == .minus) { return nil }
        if (date1Interval.sign == .minus) && !(date2Interval.sign == .minus) {
            return addingTimeInterval(date2Interval)
        }
        if (date2Interval.sign == .minus) && !(date1Interval.sign == .minus) {
            return addingTimeInterval(date1Interval)
        }
        let shortestTimeInterval = min(date1Interval, date2Interval)
        return addingTimeInterval(shortestTimeInterval)
    }
    
    func isGreaterThanDate(_ dateToCompare: Date) -> Bool {
        var isGreater = false
        if self.compare(dateToCompare) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        return isGreater
    }
    
    func isLessThanDate(_ dateToCompare: Date) -> Bool {
        var isLess = false
        if self.compare(dateToCompare) == ComparisonResult.orderedAscending {
            isLess = true
        }
        return isLess
    }
    
    var zman: Zman? {
//        if let zmanim = ZmanimDataSource.dataSource.zmanim {
//            for zman in zmanim {
//                if zman.date as Date == self {
//                    return zman
//                }
//            }
//        }
        return nil
    }
    
    var localZman: LocalZman? {
//        if let localZmanim = ZmanimDataSource.dataSource.localZmanim {
//            for localZman in localZmanim {
//                if localZman.date as Date == self {
//                    return localZman
//                }
//            }
//        }
        return nil
    }
}

extension Calendar.Component {
    static var allComponents: Set<Calendar.Component> {
        return [.era, .year, .month, .day, .hour, .minute, .second, .weekday, .weekdayOrdinal, .quarter, .weekOfMonth, .weekOfYear, .yearForWeekOfYear, .nanosecond, .calendar, .timeZone]
    }
}
