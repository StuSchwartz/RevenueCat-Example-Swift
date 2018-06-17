//
//  ViewController.swift
//  RevenueCat
//
//  Created by Stuart on 5/25/18.
//  Copyright © 2018 Domains by Stu. All rights reserved.
//

import UIKit
import Purchases

class ViewController: UIViewController
{
    var appDelegate: AppDelegate?
    var purchases: RCPurchases?
    var product: SKProduct?
    
    @IBOutlet weak var catLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var purchaseButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Grab the app delegate purchases object
        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.purchases = self.appDelegate?.purchases
        
        // Subscribe to notifications
        subscribeNotifications()
    
        // Load the product information so we can display the prices
        loadProducts()
    }
}


extension ViewController
{
    // Subscribe to notifications
    func subscribeNotifications()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(expirationUpdated(notfication:)), name: .expiration_updated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(transactionFailed(notfication:)), name: .transaction_failed, object: nil)
    }
    
    // Load the product information so we can display the prices
    func loadProducts()
    {
        purchases?.products(withIdentifiers: [RevenueCatKeys.MCMonthlyCatsProductIdentifier.rawValue], completion:
        { [weak self] (products) in
            guard let strongSelf = self else {return}
            
            if products.count > 0
            {
                strongSelf.displayProductInfo(product: products[0])
            }
            else
            {
                strongSelf.priceLabel.text = "Product Missing :(";
            }
        })
    }
}


extension ViewController
{
    @IBAction func purchaseSubscription(_ sender: Any)
    {
        guard let product = self.product else {return}
        purchases?.makePurchase(product)
    }
    
    @IBAction func restorePurchases(_ sender: Any)
    {
        appDelegate?.restorePurchases()
    }
}


extension ViewController
{
    @objc func expirationUpdated(notfication: NSNotification)
    {
        updatePurchaseUI()
    }

    @objc func transactionFailed(notfication: NSNotification)
    {
        updatePurchaseUI()
    }
}


extension ViewController
{
    func displayProductInfo(product: SKProduct)
    {
        self.product = product
        updatePurchaseUI()
    }
    
    // Configure the UI based on the purchase state.
    func updatePurchaseUI()
    {
        let hasSubscription = self.appDelegate?.hasSubscription() ?? false
        
        self.purchaseButton.isHidden = hasSubscription
        self.purchaseButton.isEnabled = self.product != nil
        
        if hasSubscription
        {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .none
            self.catLabel.text = formatter.string(from: (self.appDelegate?.getExpiration())!)
        }
        else
        {
            self.catLabel.text = "No cats :(";
        }
        
        if let product = self.product
        {
            let formatter = NumberFormatter()
            formatter.locale = product.priceLocale
            formatter.numberStyle = .currency
            self.priceLabel.text = formatter.string(from: product.price)
        }
        else
        {
            self.priceLabel.text = "Loading...";
        }
    }
}

