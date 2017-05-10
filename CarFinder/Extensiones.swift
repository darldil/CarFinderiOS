//
//  Extensiones.swift
//  CarFinder
//
//  Created by Mauri on 20/4/17.
//  Copyright © 2017 Mauri. All rights reserved.
//

import UIKit


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showConnecting(mensaje : String) -> UIAlertController {
        let alertController = UIAlertController(title: nil, message: mensaje, preferredStyle: .alert)
        
        let spinnerIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle:     UIActivityIndicatorViewStyle.whiteLarge)
        
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        
        alertController.view.addSubview(spinnerIndicator)
        return alertController
    }
    

    /*func keyboardWillShow(sender: NSNotification) {
        let userInfo = sender.userInfo
        let keyboardSize: CGSize = (userInfo![UIKeyboardFrameBeginUserInfoKey] as! CGRect).size
        let offset: CGSize = (userInfo![UIKeyboardFrameEndUserInfoKey] as! CGRect).size
        
        if keyboardSize.height == offset.height {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.view.frame.origin.y -= keyboardSize.height
            })
        } else {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.view.frame.origin.y += keyboardSize.height - offset.height
            })
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        let userInfo = notification.userInfo
        let keyboardSize: CGSize = (userInfo![UIKeyboardFrameBeginUserInfoKey] as! CGRect).size
        self.view.frame.origin.y += keyboardSize.height
    }*/
}
