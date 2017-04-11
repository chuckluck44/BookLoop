//
//  NSCalendar+Formatting.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 9/8/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import Foundation

class DateFormatHelper {
    class func timeAgoSinceDate(_ date:Date, numericDates:Bool=false) -> String {
        let calendar = Calendar.current
        let unitFlags: NSCalendar.Unit = [.hour, .day, .weekOfYear, .month, .year, .second]
        let now = Date()
        let earliest = (now as NSDate).earlierDate(date)
        let latest = (earliest == now) ? date : now
        let components:DateComponents = (calendar as NSCalendar).components(unitFlags, from: earliest, to: latest, options: NSCalendar.Options(rawValue: 0))
        
        if (components.year! >= 1){
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d, yyyy"
            return formatter.string(from: date)
        }
        else if (components.weekOfYear! >= 1){
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d"
            return formatter.string(from: date)
        } else if (components.day! >= 2) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 day ago"
            } else {
                return "Yesterday"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour) hours ago"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 hour ago"
            } else {
                return "An hour ago"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute) minutes ago"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 minute ago"
            } else {
                return "A minute ago"
            }
        } else if (components.second! >= 3) {
            return "\(components.second) seconds ago"
        } else {
            return "Just now"
        }
        
    }
}
