//
//  AppDelegate.swift
//  RevenueCat
//
//  Created by Stuart on 5/25/18.
//  Copyright © 2018 Domains by Stu. All rights reserved.
//

import UIKit
import Purchases


enum RevenueCatKeys: String
{
    case MCExpirationDateDefaultsKey = "com.revenuecat.defaults.expiration"
    case MCMonthlyCatsProductIdentifier = "com.revenuecat.subscriptions.monthly"
}

extension Notification.Name
{
    static let expiration_updated = Notification.Name("com.revenuecat.notifications.expiration_updated")
    static let transaction_failed = Notification.Name("com.revenuecat.notifications.transaction_failed")
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?

    var purchases: RCPurchases?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        // Now we instantiate RCPurchases with our RevenueCat API key that we get from https://app.revenuecat.com/
        // and the user ID we just created.
        self.purchases = RCPurchases(apiKey: "KjjVmDTFNHmnCadafWcrfeCsyrvQrMTP")
        
        // RCPurchases won't process any transactions until it's delegate is set, usually
        // you will want to do this outside of the AppDelegate but for this sample
        // we'll make the AppDelegate also the RCPurchasesDelegate
        self.purchases?.delegate = self;
        
        self.purchases?.updateOriginalApplicationVersion()

        // Override point for customization after application launch.
        return true
    }
}


// Delegate for `RCPurchases` responsible for handling updating your app's state in response to completed purchases
extension AppDelegate: RCPurchasesDelegate
{
    func purchases(_ purchases: RCPurchases, completedTransaction transaction: SKPaymentTransaction, withUpdatedInfo purchaserInfo: RCPurchaserInfo)
    {
        /*
         Called when a transaction has been succesfully posted to the backend.
         This will be called in response to `makePurchase:` call but can also occur at other times,
         especially when dealing with subscriptions.
         
         The main thing you want to do here is to save the RCPurchaserInfo in some way.
         The RCPurchaserInfo represents the latest subscription status for your user
         */
        handlePurchaserInfo(purchaserInfo: purchaserInfo)
    }
    
    func purchases(_ purchases: RCPurchases, failedTransaction transaction: SKPaymentTransaction, withReason failureReason: Error)
    {
        /*
         Called when a `transaction` fails to complete purchase with `StoreKit` or fails to be posted to the backend.
         The `localizedDescription` of `failureReason` will contain a message that may be useful for displaying to the user.
         Be sure to dismiss any purchasing UI if this method is called. This method can also be called at any time but
         outside of a purchasing context there often isn't much to do.
         */
        handleFailure(reason: failureReason)
    }
    
    func purchases(_ purchases: RCPurchases, receivedUpdatedPurchaserInfo purchaserInfo: RCPurchaserInfo)
    {
        /*
         Called whenever `RCPurchases` receives an updated purchaser info outside of a purchase. This will happen periodically
         throughout the life of the app (e.g. UIApplicationDidBecomeActive).
         
         The main thing you want to do here is to save the RCPurchaserInfo in some way.
         The RCPurchaserInfo represents the latest subscription status for your user
         */
        handlePurchaserInfo(purchaserInfo: purchaserInfo)
    }
    
    func purchases(_ purchases: RCPurchases, restoredTransactionsWith purchaserInfo: RCPurchaserInfo)
    {
        /*
         Called when restoring transactions has been completed successfully.
         
         The main thing you want to do here is to save the RCPurchaserInfo in some way.
         The RCPurchaserInfo represents the latest subscription status for your user
         */
        handlePurchaserInfo(purchaserInfo: purchaserInfo)
    }
    
    func purchases(_ purchases: RCPurchases, failedToRestoreTransactionsWithError error: Error)
    {
        /*
         Called when restoring transactions has failed
         */
        handleFailure(reason: error)
    }
    
    func purchases(_ purchases: RCPurchases, failedToUpdatePurchaserInfoWithError error: Error)
    {
        /*
         Called whenever RCPurchases fails to fetch a purchaserInfo.
         */
        handleFailure(reason: error)
    }
}


extension AppDelegate
{
    func handlePurchaserInfo( purchaserInfo: RCPurchaserInfo)
    {
        guard let latestExpirationDate = purchaserInfo.latestExpirationDate else {return}
        
        // Get the latest expiration date of all the user's subscriptions
        print("Expiration date = \(latestExpirationDate)")

        // Save it so we know the expiration immediately on launch
        UserDefaults.standard.set(latestExpirationDate, forKey: RevenueCatKeys.MCExpirationDateDefaultsKey.rawValue)
        
        // Post a notification
        DispatchQueue.main.async
        {
            NotificationCenter.default.post(name: .expiration_updated, object: nil)
        }
    }
    
    func handleFailure( reason: Error )
    {
        // Post a notification for failures
        DispatchQueue.main.async
        {
            NotificationCenter.default.post(name: .transaction_failed, object: nil)
        }
    }
    
    func hasSubscription() -> Bool
    {
        let expiration = getExpiration()
        
        // Simple bool to compute if user has a valid subscription
        if let expiration = expiration
        {
            // Expiration date is still in the future
            if expiration > Date()
            {
                return true
            }
        }

        // reset user default for the expiration
        UserDefaults.standard.set(nil, forKey: RevenueCatKeys.MCExpirationDateDefaultsKey.rawValue)
        
        return false
    }
    
    func getExpiration() -> Date?
    {
        return UserDefaults.standard.object(forKey: RevenueCatKeys.MCExpirationDateDefaultsKey.rawValue) as? Date
    }
    
    
    
    func restorePurchases()
    {
        self.purchases?.restoreTransactionsForAppStoreAccount()
    }
}




