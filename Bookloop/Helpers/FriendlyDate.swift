//
//  FriendlyDate.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 12/14/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import Foundation

extension Date {
    
    func friendlyIntervalToNow() -> String {
        
        let firstTimeInterval: TimeInterval = self.timeIntervalSince1970
        
        let secondTimeInterval: TimeInterval = Date().timeIntervalSince1970
        
        var hasDays = false
        var hasHours = false
        var hasMins = false
        
        if secondTimeInterval > firstTimeInterval {
            
            var difference: Int = Int(secondTimeInterval - firstTimeInterval)
            
            let days = Int(abs(difference / 86400))
            
            if (days > 0) {
                hasDays = true
                let daySeconds = days * 86400;
                difference = difference - daySeconds;
            }
            
            let hours = abs(difference / 3600);
            
            if (hours > 0) {
                hasHours = true
                let hourSeconds = hours * 3600;
                difference = difference - hourSeconds;
            }
            
            let mins = (abs)(difference / 60);
            
            if (mins > 0) {
                hasMins = true
                let minSeconds = mins * 60;
                difference = difference - minSeconds;
            }
            
            var results: String = ""
            
            if (days == 1) {
                results += "1 day "
            }
            
            if (days > 1) {
                results += "\(days) days "
            }
            
            if (hours == 1) {
                results += "1 hour "
            }
            
            if (hours > 1) {
                results += "\(hours) hours "
            }
            
            if hasHours == false {
                
                if (mins == 1) {
                    results += "1 min "
                }
                
                if (mins > 1) {
                    results += "\(mins) mins "
                }
                
            }
            
            if hasMins == false {
                
                if (difference == 1) {
                    results += "1 sec"
                }
                
                if (difference > 1) {
                    results += "\(difference) secs"
                }
                
            }
            
            
            return results
            
        }
        
        return "Future date"
        
    }
    
}
