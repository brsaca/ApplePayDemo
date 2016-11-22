//
//  ViewController.swift
//  ApplePayDemo
//
//  Created by Brenda Saavedra on 21/11/16.
//  Copyright © 2016 Brenda Saavedra. All rights reserved.
//

import UIKit
import PassKit


class ViewController: UIViewController, PKPaymentAuthorizationViewControllerDelegate {

    var paymentRequest: PKPaymentRequest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    func itemToSell(_ shipping: Double) -> [PKPaymentSummaryItem]{
        let tShirt   = PKPaymentSummaryItem(label: "T-Shirt Sheldon", amount: 45.0)
        let discount = PKPaymentSummaryItem(label: "Discount", amount: -10.0)
        let shipping = PKPaymentSummaryItem(label: "Shipping", amount: NSDecimalNumber(string: "\(shipping)"))
        let totalAmount = tShirt.amount.adding(discount.amount).adding(shipping.amount)
        
        let totalPrice = PKPaymentSummaryItem(label: "BSC Co.", amount: totalAmount)
        
        return [tShirt, discount, shipping, totalPrice]
    }
    
    //MARK: PKPaymentAuthorizationViewControllerDelegate
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelect shippingMethod: PKShippingMethod, completion: @escaping (PKPaymentAuthorizationStatus, [PKPaymentSummaryItem]) -> Void) {
        completion(PKPaymentAuthorizationStatus.success, itemToSell(Double(shippingMethod.amount)))
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        completion(PKPaymentAuthorizationStatus.success)
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: IBAction
    @IBAction func PayBtnPressed(_ sender: Any) {
        
        let paymentNetworks = [PKPaymentNetwork.amex, .visa, .masterCard, .discover]
        if PKPaymentAuthorizationController.canMakePayments(usingNetworks: paymentNetworks) {
            paymentRequest = PKPaymentRequest()
            paymentRequest.currencyCode = "USD"
            paymentRequest.countryCode = "US"
            paymentRequest.merchantIdentifier = "merchant.com.bsc.ApplePayDemo"
            paymentRequest.supportedNetworks = paymentNetworks
            paymentRequest.merchantCapabilities = .capability3DS
            paymentRequest.requiredShippingAddressFields = [.all]
            paymentRequest.paymentSummaryItems = self.itemToSell(4.99)
            
            let sameDayShipping = PKShippingMethod(label: "Same Day Delivery", amount: 12.99)
            sameDayShipping.detail = "Delivery is guarantedd the same day"
            sameDayShipping.identifier = "sameDay"
            
            let twoDayShipping = PKShippingMethod(label: "Two Day Delivery", amount: 7.99)
            twoDayShipping.detail = "Delivery to you within the next two days"
            twoDayShipping.identifier = "twoDay"
            
            let freeShipping = PKShippingMethod(label: "Free Delivery", amount: 0)
            freeShipping.detail = "Deliverd to you within 7 to 10 days"
            freeShipping.identifier = "free"
            
            paymentRequest.shippingMethods = [sameDayShipping, twoDayShipping, freeShipping]
            
            let applePayVC = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
            applePayVC.delegate = self
            self.present(applePayVC, animated: true, completion: nil)
        } else {
            print("Tell the user that he needs to set up apple Pay")
        }
        
       
    }
}

