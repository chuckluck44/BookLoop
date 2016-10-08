//
//  NSCalendar+Formatting.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 9/8/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import Foundation

class DateFormatHelper {
    func timeAgoSinceDate(date:NSDate, numericDates:Bool=false) -> String {
        let calendar = NSCalendar.currentCalendar()
        let unitFlags: NSCalendarUnit = [.Hour, .Day, .WeekOfYear, .Month, .Year, .Second]
        let now = NSDate()
        let earliest = now.earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:NSDateComponents = calendar.components(unitFlags, fromDate: earliest, toDate: latest, options: NSCalendarOptions(rawValue: 0))
        
        if (components.year >= 1){
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MMMM d, yyyy"
            return formatter.stringFromDate(date)
        }
        else if (components.weekOfYear >= 1){
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MMMM d"
            return formatter.stringFromDate(date)
        } else if (components.day >= 2) {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.stringFromDate(date)
        } else if (components.day >= 1){
            if (numericDates){
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else if (components.hour >= 2) {
            return "\(components.hour) hours ago"
        } else if (components.hour >= 1){
            if (numericDates){
                return "1 hour ago"
            } else {
                return "An hour ago"
            }
        } else if (components.minute >= 2) {
            return "\(components.minute) minutes ago"
        } else if (components.minute >= 1){
            if (numericDates){
                return "1 minute ago"
            } else {
                return "A minute ago"
            }
        } else if (components.second >= 3) {
            return "\(components.second) seconds ago"
        } else {
            return "Just now"
        }
        
    }
}
