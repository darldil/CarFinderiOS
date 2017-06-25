//
//  ViewController.swift
//  CarFinder
//
//  Created by Mauri on 15/4/17.
//  Copyright © 2017 Mauri. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usuarioTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var iniciarButton: UIButton!
    @IBOutlet weak var registrarButton: UIButton!
    @IBOutlet weak var recordar: UISwitch!
    
    var operationPerformed : Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cerrarElTecladoCuandoSePulseFuera()
        
        let defaults = UserDefaults.standard
        
        let user = defaults.string(forKey: "user")
        let passwd = defaults.string(forKey: "pass")
        
        //Si hay almacenados un usuario y contraseña, conectará automáticamente
        if(user != nil && passwd != nil) {
            conectar(usuario: user as String!, pass: passwd as String!, autoInicio: true)
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
    
    //Realiza las operaciones de conexión pertinentes, si autoinicio esta a true significa que cargará los datos del almacenamiento interno del dispositivo, en caso contrario los cargará de los campos de texto
    private func conectar(usuario: String, pass: String, autoInicio: Bool) {
        var error : Bool = false
        if (!autoInicio) {
            //Si los campos están vacíos
            if (usuario == "" || pass == "") {
                self.mostrarError(mess: "Los campos están vacíos")
                error = true
            }
            //Si el formato del email no es válido
            else if (!self.comprobarEmailValido(email: usuario)) {
                self.mostrarError(mess: "El email no es válido")
                error = true
            }
            //Si las contraseñas no coinciden o tienen menos de 5 caracteres
            else if (!self.comprobarPasswords(p1: pass)) {
                self.mostrarError(mess: "La contraseña es muy corta")
                error = true
            }
        }
        //Si no ha habido un error con las condiciones anteriores
        if (!error) {
            let con = Usuarios ()
            let alertController = mostrarCargando(mensaje: "Conectando...\n\n")
            let preferences = UserDefaults.standard
        
            //Muestra la alerta de "Conectando"
            DispatchQueue.main.async(execute: {
                self.present(alertController, animated: true, completion: nil)
            });
        
            con.iniciarSesion(username: usuario, password: pass) {
            respuesta in
                //Si el servidor no responde
                if (respuesta.value(forKey: "errorno") as! NSNumber == 404) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        alertController.dismiss(animated: true, completion: {
                            self.mostrarError(mess: respuesta.value(forKey: "errorMessage") as! String)
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
                            //En caso contrario
                            else if (respuesta.value(forKey: "errorno") as! NSNumber != 404) {
                                self.mostrarError(mess: respuesta.value(forKey: "errorMessage") as! String)
                            }
                        })
                    }
                }
            }
        }
    }

    //ActionListener del botón conectar
    @IBAction func conectarListener(_ sender: Any) {
        let usuario: String = usuarioTextField.text!
        let pass: String = passTextField.text!
        conectar(usuario: usuario, pass: pass, autoInicio: false)
    }
}

