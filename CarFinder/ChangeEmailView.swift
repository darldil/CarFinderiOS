//
//  ChangeEmailView.swift
//  CarFinder
//
//  Created by Mauri on 5/5/17.
//  Copyright © 2017 Mauri. All rights reserved.
//

import UIKit

class ChangeEmailView: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func changeEmail(_ sender: Any) {
        
        let defaults = UserDefaults.standard
        let user = defaults.string(forKey: "user")
        
        if (self.checkEmailValid(email: emailTextField.text!)) {
            let con = Usuarios ()
            let alertController = showConnecting( mensaje: "Cambiando, espere...\n\n")
            DispatchQueue.main.async(execute: {
                self.present(alertController, animated: true, completion: nil)
            });
            con.modificarEmail(email: user!, new_Email: emailTextField.text!) {
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
                                defaults.set(self.emailTextField.text!, forKey: "user")
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
        else {
            let alertController = UIAlertController(title:  "Error", message: "El email no es válido", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default) { action in
                self.dismiss(animated: true, completion: nil)
            })
            self.present(alertController, animated: true)

        }
    }
    
    private func checkEmailValid(email : String) -> Bool {
        
        if (email.contains("@")) {
            return true;
        }
        
        return false;
    }
    
    
}
