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
        tableView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Gestiona la interfaz cuando se pulsa una celda y carga su opcion correspondiente
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let option : [String: Int] = ["section": indexPath.section, "row": indexPath.row]
        menu(opt: option)
    }
    
    //Establece el diseño de las cabeceras de la tabla
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    
    //Carga la opción correspondiente en función de la fila pulsada.
    private func menu(opt: [String: Int]) {
        
        //Cierra la sesión y redirige al Login
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
            
            present(alertController, animated: true)
        }
        //Ofrece cambiar el email
        else if(opt["section"] == 0 && opt["row"] == 1) {
            self.cambiarEmail()
        }
        //Ofrece cambiar la contraseña
        else if(opt["section"] == 0 && opt["row"] == 2) {
            self.cambiarPassword()
        }
    }
    
    
    //Muestra la interfaz para el cambio de email y realiza las operaciones pertinentes.
    private func cambiarEmail() {
        let alertData = UIAlertController(title: "Cambiar email", message: "Inserta el nuevo email", preferredStyle: .alert)
        
        //Dialogo con los campos a rellenar
        let accionGuardar = UIAlertAction(title: "Cambiar", style: .destructive, handler: {
            alert -> Void in
            
            let firstTextField = alertData.textFields![0] as UITextField
            let defaults = UserDefaults.standard
            let user = defaults.string(forKey: "user")
            
            //Comprueba que el email tiene un formato válido
            if (self.comprobarEmailValido(email: firstTextField.text!)) {
                let con = Usuarios ()
                let alertController = self.mostrarCargando( mensaje: "Cambiando, espere...\n\n")
                DispatchQueue.main.async(execute: {
                    self.present(alertController, animated: true, completion: nil)
                });
                con.modificarEmail(email: user!, new_Email: firstTextField.text!) {
                    respuesta in
                    //Si ocurrió algún problema con el servidor
                    if (respuesta.value(forKey: "errorno") as! NSNumber == 404) {
                        alertController.dismiss(animated: true, completion: {
                            self.mostrarError(mess: respuesta.value(forKey: "errorMessage") as! String)
                        })
                    }
                    else {
                        alertController.dismiss(animated: true, completion: {
                            //El email se cambió correctamente
                            if (respuesta.value(forKey: "errorno") as! NSNumber == 0) {
                                let alert = UIAlertController(title: nil, message: "Email modificado correctamente", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Aceptar", style: .default) { action in
                                    defaults.set(firstTextField.text!, forKey: "user")
                                    self.navigationController?.popViewController(animated: true)
                                })
                                self.present(alert, animated: true)
                            }
                            //Ocurrió un problema
                            else if (respuesta.value(forKey: "errorno") as! NSNumber != 404) {
                                self.mostrarError(mess: respuesta.value(forKey: "errorMessage") as! String)
                            }
                        })
                    }
                }
            }
            else {
                self.mostrarError(mess: "El email no es válido")
            }
        })
        
        let accionCancelar = UIAlertAction(title: "Cancelar", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        alertData.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Introduce tu nuevo email"
            textField.tintColor = .red
        }
        
        alertData.addAction(accionGuardar)
        alertData.addAction(accionCancelar)
        
        self.present(alertData, animated: true, completion: nil)
    }
    
    //Muestra la interfaz para el cambio de contraseña y realiza las operaciones pertinentes.
    private func cambiarPassword() {
        let alertData = UIAlertController(title: "Cambiar contraseña", message: "", preferredStyle: .alert)
        
        //Dialogo con los campos a rellenar
        let accionGuardar = UIAlertAction(title: "Modificar", style: .destructive, handler: {
            alert -> Void in
            
            let oldPassTextField = alertData.textFields![0] as UITextField
            let firstTextField = alertData.textFields![1] as UITextField
            let secondTextField = alertData.textFields![2] as UITextField
            let defaults = UserDefaults.standard
            let user = defaults.string(forKey: "user")
            let originalPass = defaults.string(forKey: "pass")
            
            //Si las contraseñas coinciden y tienen una longitud de más de 4 caracteres
            if (self.comprobarPasswords(p1: firstTextField.text!, p2: secondTextField.text!)) {
                let con = Usuarios ()
                let alertController = self.mostrarCargando( mensaje: "Cambiando, espere...\n\n")
                DispatchQueue.main.async(execute: {
                    self.present(alertController, animated: true, completion: nil)
                });
                con.modificarPass(email: user!, old_pass: oldPassTextField.text!, new_pass: firstTextField.text!) {
                    respuesta in
                    //Si hubo un problema con el servidor
                    if (respuesta.value(forKey: "errorno") as! NSNumber == 404) {
                        alertController.dismiss(animated: true, completion: {
                            self.mostrarError(mess: respuesta.value(forKey: "errorMessage") as! String)
                        })
                    }
                    else {
                        alertController.dismiss(animated: true, completion: {
                            //Contraseña cambiada correctamente
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
                            //Ocurrió un problema al cambiar la contraseña
                            else if (respuesta.value(forKey: "errorno") as! NSNumber != 404) {
                                self.mostrarError(mess: respuesta.value(forKey: "errorMessage") as! String)
                            }
                        })
                    }
                }
            }
            else {
                self.mostrarError(mess: "La contraseña no es válida")
            }
        })
        
        let accionCancelar = UIAlertAction(title: "Cancelar", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
        })
        //Primer textField
        alertData.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Introduce tu antigua contraseña"
            textField.isSecureTextEntry = true
            textField.tintColor = .red
        }
        //Segundo textField
        alertData.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Introduce tu nueva contraseña"
            textField.isSecureTextEntry = true
            textField.tintColor = .red
        }
        //Tercer textField
        alertData.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Repite tu nueva contraseña"
            textField.isSecureTextEntry = true
            textField.tintColor = .red
        }
        
        alertData.addAction(accionGuardar)
        alertData.addAction(accionCancelar)
        
        self.present(alertData, animated: true, completion: nil)
    }
    
    private func comprobarPasswords(p1 : String, p2 : String) -> Bool {
        if (p1 == p2 && p1.characters.count > 4) {
            return true;
        }
        return false;
    }
    
    private func comprobarEmailValido(email : String) -> Bool {
        
        if (email.contains("@")) {
            return true;
        }
        
        return false;
    }
}
