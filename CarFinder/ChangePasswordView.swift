//
//  ChangePasswordView.swift
//  CarFinder
//
//  Created by Mauri on 21/4/17.
//  Copyright © 2017 Mauri. All rights reserved.
//

import UIKit

class ChangePasswordView: UIViewController {
    
    @IBOutlet weak var pass1: UITextField!
    @IBOutlet weak var pass2: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changePassword(_ sender: Any) {
        let defaults = UserDefaults.standard
        let user = defaults.string(forKey: "user")
        let originalPass = defaults.string(forKey: "pass")
        
        if (self.checkPasswords(p1: pass1.text!, p2: pass2.text!)) {
            let con = Usuarios ()
            let alertController = showConnecting( mensaje: "Cambiando, espere...\n\n")
            DispatchQueue.main.async(execute: {
                self.present(alertController, animated: true, completion: nil)
            });
            con.modificarPass(email: user!, password: pass1.text!) {
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
                                if(originalPass != nil) {
                                    defaults.set(self.pass1.text!, forKey: "pass")
                                }
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
            let alertController = UIAlertController(title:  "Error", message: "La contraseña no es válida", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default) { action in
                self.dismiss(animated: true, completion: nil)
            })
            self.present(alertController, animated: true)
            
        }
    }
    
    private func checkPasswords(p1 : String, p2 : String) -> Bool {
        if (p1 == p2) {
            return true;
        }
        return false;
    }
    
    
}
