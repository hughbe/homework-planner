//
//  InAppPurchases.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 11/02/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import StoreKit

public enum InAppPurchase: String {
    public class Notifications {
        public static let purchaseSuccess = NSNotification.Name(rawValue: "InAppPurchaseSuccessNotfication")
        public static let purchaseError = NSNotification.Name(rawValue: "InAppPurchaseErrorNotfication")
    }

    case unlockTimetable = "unlocktimetable"
    
    public var isPurchased: Bool {
        if let value = UserDefaults.standard.value(forKey: rawValue) as? Bool {
            return value
        }
        
        return false
    }

    public func purchase() {
        UserDefaults.standard.set(true, forKey: rawValue)
        NotificationCenter.default.post(name: Notifications.purchaseSuccess, object: self)
    }

    private class TransactionObserver : NSObject, SKPaymentTransactionObserver {
        func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
            for transaction in transactions {
                switch (transaction.transactionState) {
                case .purchased, .restored:
                    SKPaymentQueue.default().finishTransaction(transaction)

                    let productId = transaction.original?.payment.productIdentifier ?? transaction.payment.productIdentifier

                    if let purchase = InAppPurchase(rawValue: productId) {
                        purchase.purchase()
                    }

                    break
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction)
                    NotificationCenter.default.post(name: InAppPurchase.Notifications.purchaseError, object: transaction)
                    break
                default:
                    break
                }
            }
        }

        func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
            paymentQueue(queue, updatedTransactions: queue.transactions)
        }
    }

    public static var transactionObserver: SKPaymentTransactionObserver = TransactionObserver()
}
