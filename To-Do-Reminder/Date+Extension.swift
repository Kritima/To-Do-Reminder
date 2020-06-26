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
   
