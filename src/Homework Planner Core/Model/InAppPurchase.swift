//
//  InAppPurchases.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 11/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import StoreKit

public enum InAppPurchase: String {
    case unlockTimetable = "unlocktimetable"
    
    public func purchase() {
        UserDefaults.standard.set(true, forKey: rawValue)
    }
    
    public var isPurchased: Bool {
        if let value = UserDefaults.standard.value(forKey: rawValue) as? Bool {
            return value
        }
        
        return false
    }
}
