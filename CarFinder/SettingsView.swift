//
//  SettingsView.swift
//  CarFinder
//
//  Created by Mauri on 20/4/17.
//  Copyright © 2017 Mauri. All rights reserved.
//

import UIKit

class SettingsView: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView.delegate = self
        tableView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let option : [String: Int] = ["section": indexPath.section, "row": indexPath.row]
        
        menuPrefs(opt: option)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    
    private func menuPrefs(opt: [String: Int]) {
        
        if (opt["section"] == 1 && opt["row"] == 0) {
            let alertController = UIAlertController(title: "Cerrar Sesión", message: "¿Seguro que desea cerrar la sesión?", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Aceptar", style: .default) { action in
                
                alertController.dismiss(animated: true, completion: nil)
                
                let prefs = UserDefaults.standard
                prefs.removeObject(forKey: "email")
                prefs.removeObject(forKey: "pass")
                
                self.dismiss(animated: true, completion: nil)
            }
            
            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { action in
                alertController.dismiss(animated: true, completion: nil)
            }
            
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            //Show alert view
            present(alertController, animated: true)
        }
        else if(opt["section"] == 0 && opt["row"] == 1) {
            self.changeEmail()
        }
        else if(opt["section"] == 0 && opt["row"] == 2) {
            self.changePassword()
        }
    }
    
    private func changeEmail() {
        let alertData = UIAlertController(title: "Cambiar email", message: "Inserta el nuevo email", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Cambiar", style: .destructive, handler: {
            alert -> Void in
            
            let firstTextField = alertData.textFields![0] as UITextField
            let defaults = UserDefaults.standard
            let user = defaults.string(forKey: "user")
            
            if (self.checkEmailValid(email: firstTextField.text!)) {
                let con = Usuarios ()
                let alertController = self.showConnecting( mensaje: "Cambiando, espere...\n\n")
                DispatchQueue.main.async(execute: {
                    self.present(alertController, animated: true, completion: nil)
                });
                con.modificarEmail(email: user!, new_Email: firstTextField.text!) {
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
                        alertController.dismiss(animated: true, completion: {
                            if (respuesta.value(forKey: "errorno") as! NSNumber == 0) {
                                
                                let alert = UIAlertController(title: nil, message: "Email modificado correctamente", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Aceptar", style: .default) { action in
                                    defaults.set(firstTextField.text!, forKey: "user")
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

            
        })
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        alertData.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Introduce tu nuevo email"
            textField.tintColor = .red
        }
        
        alertData.addAction(saveAction)
        alertData.addAction(cancelAction)
        
        self.present(alertData, animated: true, completion: nil)
    }
    
    private func changePassword() {
        let alertData = UIAlertController(title: "Cambiar contraseña", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Modificar", style: .destructive, handler: {
            alert -> Void in
            
            let firstTextField = alertData.textFields![0] as UITextField
            let secundTextField = alertData.textFields![1] as UITextField
            let defaults = UserDefaults.standard
            let user = defaults.string(forKey: "user")
            let originalPass = defaults.string(forKey: "pass")
            
            if (self.checkPasswords(p1: firstTextField.text!, p2: secundTextField.text!)) {
                    let con = Usuarios ()
                    let alertController = self.showConnecting( mensaje: "Cambiando, espere...\n\n")
                    DispatchQueue.main.async(execute: {
                        self.present(alertController, animated: true, completion: nil)
                    });
                    con.modificarPass(email: user!, password: firstTextField.text!) {
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
                            alertController.dismiss(animated: true, completion: {
                                if (respuesta.value(forKey: "errorno") as! NSNumber == 0) {
                                    
                                    let alert = UIAlertController(title: nil, message: "Contraseña cambiada", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "Aceptar", style: .default) { action in
                                        if(originalPass != nil) {
                                            defaults.set(firstTextField.text!, forKey: "pass")
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
                        alertController.dismiss(animated: true, completion: nil)
                    })
                    self.present(alertController, animated: true)
                    
                }
        })
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
        })
        
        alertData.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Introduce tu nueva contraseña"
            textField.isSecureTextEntry = true
            textField.tintColor = .red
        }
        alertData.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Repite tu nueva contraseña"
            textField.isSecureTextEntry = true
            textField.tintColor = .red
        }
        
        alertData.addAction(saveAction)
        alertData.addAction(cancelAction)
        
        self.present(alertData, animated: true, completion: nil)
    }
    
    
    
    private func checkPasswords(p1 : String, p2 : String) -> Bool {
        if (p1 == p2) {
            return true;
        }
        return false;
    }
    
    private func checkEmailValid(email : String) -> Bool {
        
        if (email.contains("@")) {
            return true;
        }
        
        return false;
    }
}
