//
//  RegistroView.swift
//  CarFinder
//
//  Created by Mauri on 19/4/17.
//  Copyright © 2017 Mauri. All rights reserved.
//

import UIKit

class RegistroView: UIViewController {
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBAction func dateTextFieldAction(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(RegistroView.datePickerValueChanged), for: UIControlEvents.valueChanged)
    }
    
    
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var lastnameText: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var pass1: UITextField!
    @IBOutlet weak var pass2: UITextField!
    
   
    var keyboardUp : Bool!
    
    convenience init() {
        self.init()
        keyboardUp = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.hideKeyboardWhenTappedAround()
        self.prepareDatePicker()
        self.keyboardUp = false
        
       NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateTextField.text = dateFormatter.string(from: sender.date)
        
    }
    
    func prepareDatePicker() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        toolBar.barStyle = UIBarStyle.default
        
        let okBarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(RegistroView.donePressed))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        toolBar.setItems([flexSpace,flexSpace,okBarBtn], animated: true)
        
        dateTextField.inputAccessoryView = toolBar

    }
    
    func donePressed(_ sender: UIBarButtonItem) {
        dateTextField.resignFirstResponder()
    }
    
    func keyboardWillShow(_ notification:Notification) {
        adjustingHeight(true, notification: notification)
    }
    
    func keyboardWillHide(_ notification:Notification) {
        adjustingHeight(false, notification: notification)
    }
    
    func adjustingHeight(_ show:Bool, notification:Notification) {
        let userInfo = notification.userInfo!
        let keyboardFrame = userInfo[UIKeyboardFrameBeginUserInfoKey] as! CGRect
        let changeInHeight = (keyboardFrame.height + 60) * (show ? 1 : -1)
        
        if (self.keyboardUp == true && show != false) {
            scrollView.contentInset.bottom += changeInHeight * -1
            scrollView.scrollIndicatorInsets.bottom += changeInHeight * -1
        }
        
        if (show == true) {
            self.keyboardUp = true;
        }
        
        else {
            self.keyboardUp = false;
        }
        
        scrollView.contentInset.bottom += changeInHeight
        scrollView.scrollIndicatorInsets.bottom += changeInHeight
    }
    
    @IBAction func registrar(_ sender: Any) {
        let con = Usuarios ()
        let email: String = self.email.text!
        let pass1: String = self.pass1.text!
        let pass2: String = self.pass2.text!
        let name: String = self.nameText.text!
        let lastname: String = self.lastnameText.text!
        let date: String = self.dateTextField.text!
        
        if (email == "" || pass1 == "" || pass2 == "" || name == "" || lastname == "" || date == "") {
            let alertController = UIAlertController(title:  "Error", message: "Los campos están vacíos", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default) { action in
                self.dismiss(animated: true, completion: nil)
            })
            self.present(alertController, animated: true)
        }
            
        else if (pass1 != pass2) {
            let alertController = UIAlertController(title:  "Error", message: "Las contraseñas no coinciden", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default) { action in
                self.dismiss(animated: true, completion: nil)
            })
            self.present(alertController, animated: true)
        }
            
        else {
            let alertController = showConnecting( mensaje: "Registrando...\n\n")
            DispatchQueue.main.async(execute: {
                self.present(alertController, animated: true, completion: nil)
            });
            
            con.registrarUsuario(email: email, pass: pass1, name: name, last: lastname, date: date) {
                respuesta in
                
                if (respuesta.value(forKey: "errorno") as! NSNumber == 404) {
                    alertController.dismiss(animated: true, completion: {
                        let alert = UIAlertController(title: "Error", message: respuesta.value(forKey: "errorMessage") as? String, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Aceptar", style: .default) { action in
                            self.dismiss(animated: true, completion: nil)
                        })
                        self.present(alert, animated: true)
                    })
                }
                else {
                    self.dismiss(animated: true, completion: {
                        if (respuesta.value(forKey: "errorno") as! NSNumber == 0) {
                            
                            let alert = UIAlertController(title: nil, message: "Ha completado su registro correctamente", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Aceptar", style: .default) { action in
                                self.navigationController?.popViewController(animated: true)
                            })
                            self.present(alert, animated: true)
                        }
                        else if (respuesta.value(forKey: "errorno") as! NSNumber != 404) {
                            let alert = UIAlertController(title: "Error", message: respuesta.value(forKey: "errorMessage") as? String, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Aceptar", style: .default) { action in
                                self.dismiss(animated: true, completion: nil)
                            })
                            self.present(alert, animated: true)
                        }
                    })
                }
            }
        }
    }
}
