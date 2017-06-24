//
//  ViewController.swift
//  CarFinder
//
//  Created by Mauri on 15/4/17.
//  Copyright © 2017 Mauri. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    //MARK: Properties
    
    @IBOutlet weak var usuarioTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var iniciarButton: UIButton!
    @IBOutlet weak var registrarButton: UIButton!
    @IBOutlet weak var recordar: UISwitch!
    
    var operationPerformed : Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        let defaults = UserDefaults.standard
        
        let user = defaults.string(forKey: "user")
        let passwd = defaults.string(forKey: "pass")
        
        if(user != nil && passwd != nil) {
            autoIniciar(usuario: user as String!, pass: passwd as String!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func comprobarPasswords(p1 : String) -> Bool {
        if (p1.characters.count > 4) {
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
    
    private func autoIniciar(usuario: String, pass: String) {
        let con = Usuarios ()
        let alertController = mostrarCargando(mensaje: "Conectando...\n\n")
        let preferences = UserDefaults.standard
        
        DispatchQueue.main.async(execute: {
            self.present(alertController, animated: true, completion: nil)
        });
        
        con.iniciarSesion(username: usuario, password: pass) {
            respuesta in
            
            //Si el servidor ha fallado
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
                //Si la conexión se ha realizado correctamente
                self.dismiss(animated: true, completion: {
                    //Si los datos son correctos
                    if (respuesta.value(forKey: "errorno") as! NSNumber == 0) {
                        
                        preferences.set(respuesta.value(forKey: "nombre"), forKey: "name")
                        preferences.set(respuesta.value(forKey: "apellidos"), forKey: "lastname")
                        preferences.set(respuesta.value(forKey: "fecha"), forKey: "date")
                        
                        let storyBoard : UIStoryboard = UIStoryboard(name: "Logged", bundle:nil)
                        
                        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "Logged") as UIViewController
                        self.present(nextViewController, animated:true, completion:nil)
                    }
                    else if (respuesta.value(forKey: "errorno") as! NSNumber != 404) {
                        let alert = UIAlertController(title: "Error", message: respuesta.value(forKey: "errorMessage") as? String, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Aceptar", style: .default) { action in
                            let prefs = UserDefaults.standard
                            prefs.removeObject(forKey: "email")
                            prefs.removeObject(forKey: "pass")
                            self.dismiss(animated: true, completion: nil)
                        })
                        self.present(alert, animated: true)
                    }
                })
            }
        }
    }

    @IBAction func conectarListener(_ sender: Any) {
        let con = Usuarios ()
        let usuario: String = usuarioTextField.text!
        let pass: String = passTextField.text!
        
        if (usuario == "" || pass == "") {
            let alertController = UIAlertController(title: "Error", message: "Los campos están vacios", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default) { action in
                self.dismiss(animated: true, completion: nil)
            })
            self.present(alertController, animated: true)
        } else if (!self.comprobarEmailValido(email: usuario)) {
            let alertController = UIAlertController(title: "Error", message: "El email no es válido", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default) { action in
                self.dismiss(animated: true, completion: nil)
            })
            self.present(alertController, animated: true)
        }
            
        else if (!self.comprobarPasswords(p1: pass)) {
            let alertController = UIAlertController(title: "Error", message: "La contraseña es muy corta", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Aceptar", style: .default) { action in
                self.dismiss(animated: true, completion: nil)
            })
            self.present(alertController, animated: true)
        }
            
        else {
            let alertController = mostrarCargando(mensaje: "Conectando...\n\n")
            let preferences = UserDefaults.standard
            
            DispatchQueue.main.async(execute: {
                self.present(alertController, animated: true, completion: nil)
            });
            
            con.iniciarSesion(username: usuario, password: pass) {
                    respuesta in
                    //Si el servidor ha fallado
                    if (respuesta.value(forKey: "errorno") as! NSNumber == 404) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            alertController.dismiss(animated: true, completion: {
                                let alert = UIAlertController(title: "Error", message: respuesta.value(forKey: "errorMessage") as? String, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Aceptar", style: .default) { action in
                                self.dismiss(animated: true, completion: nil)
                                })
                                self.present(alert, animated: true)
                            })
                        }
                    }
                    //Si la conexión se ha realizado correctamente
                    else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.dismiss(animated: true, completion: {
                                //Si los datos son correctos
                                if (respuesta.value(forKey: "errorno") as! NSNumber == 0) {
                                    if (self.recordar.isOn) {
                                        preferences.set(pass, forKey: "pass")
                                    }
                                    preferences.set(respuesta.value(forKey: "email"), forKey: "user")
                                    preferences.set(respuesta.value(forKey: "nombre"), forKey: "name")
                                    preferences.set(respuesta.value(forKey: "apellidos"), forKey: "lastname")
                                    preferences.set(respuesta.value(forKey: "fecha"), forKey: "date")
                    
                                    let storyBoard : UIStoryboard = UIStoryboard(name: "Logged", bundle:nil)
                            
                                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "Logged") as  UIViewController
                                    self.present(nextViewController, animated:true, completion:nil)
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
    
    func performOperation(alertToBeClosedOnFinish: UIAlertController) {
        let hideAlertController = { () -> Void in
            alertToBeClosedOnFinish.dismiss(animated: false, completion: nil)
        }
        DispatchQueue.global().asyncAfter(deadline: .now(), execute: {
            DispatchQueue.main.async {
                hideAlertController();
                self.operationPerformed = true;
            }
        });
    }

}

