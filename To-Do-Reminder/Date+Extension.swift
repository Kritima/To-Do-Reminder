//
//  Date+Extension.swift
//  To-Do-Reminder
//
//  Created by Kritima Kukreja on 2020-06-26.
//  Copyright © 2020 Kritima Kukreja. All rights reserved.
//

import Foundation

extension Date {
    
    func dateComponents() -> DateComponents {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: self)
        return components
    }
   
 
    func dateComponentsToNotify() -> DateComponents {
        let calendar = Calendar.current
        let newDate = calendar.date(byAdding: .minute, value: -30, to: self)
        guard let date = newDate else {
            return calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        }
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        return components
    }
    
    func isEqual(currentDate: Date) -> Bool {
            if self.dateComponents().day == currentDate.dateComponents().day {
                return true
            } else {
                return false
            }
        }
        
        func isPast(today currentDate: Date) -> Bool {
                if self > currentDate {
                    return true
                } else {
                    return false
                }
            }
            
            
