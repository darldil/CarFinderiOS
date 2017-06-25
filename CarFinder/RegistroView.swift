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
        datePickerView.addTarget(self, action: #selector(RegistroView.datePickerValorCambiado), for: UIControlEvents.valueChanged)
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
        self.cerrarElTecladoCuandoSePulseFuera()
        self.prepararDatePicker()
        self.keyboardUp = false
        
       NotificationCenter.default.addObserver(self, selector: #selector(apareceTeclado), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(desapareceTeclado), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //Modifica la fecha obtenida a través del DatePicker
    func datePickerValorCambiado(sender:UIDatePicker) {
        
        let formatoFecha = DateFormatter()
        
        formatoFecha.dateStyle = DateFormatter.Style.medium
        formatoFecha.timeStyle = DateFormatter.Style.none
        formatoFecha.dateFormat = "yyyy-MM-dd"
        dateTextField.text = formatoFecha.string(from: sender.date)
        
    }
    
    //Prepara el selector de fecha
    func prepararDatePicker() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        toolBar.barStyle = UIBarStyle.default
        
        let okBarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(RegistroView.cerrarDatePicker))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        toolBar.setItems([flexSpace,flexSpace,okBarBtn], animated: true)
        
        dateTextField.inputAccessoryView = toolBar

    }
    
    func cerrarDatePicker(_ sender: UIBarButtonItem) {
        dateTextField.resignFirstResponder()
    }
    
    func apareceTeclado(_ notification:Notification) {
        ajustarAltura(true, notification: notification)
    }
    
    func desapareceTeclado(_ notification:Notification) {
        ajustarAltura(false, notification: notification)
    }
    
    //Ajusta el ScrollView para cuando aparezca el teclado, de manera que el campo de texto no quede oculto debajo del teclado
    func ajustarAltura(_ show:Bool, notification:Notification) {
        let userInfo = notification.userInfo!
        let fragmentoDelTeclado = userInfo[UIKeyboardFrameBeginUserInfoKey] as! CGRect
        let nuevaAltura = (fragmentoDelTeclado.height + 60) * (show ? 1 : -1)
        
        if (self.keyboardUp == true && show != false) {
            scrollView.contentInset.bottom += nuevaAltura * -1
            scrollView.scrollIndicatorInsets.bottom += nuevaAltura * -1
        }
        
        if (show == true) {
            self.keyboardUp = true;
        }
        
        else {
            self.keyboardUp = false;
        }
        
        scrollView.contentInset.bottom += nuevaAltura
        scrollView.scrollIndicatorInsets.bottom += nuevaAltura
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
    
    //Realiza las operaciones necesarias para registrar un usuario en el servidor
    @IBAction func registrar(_ sender: Any) {
        let con = Usuarios ()
        let email: String = self.email.text!
        let pass1: String = self.pass1.text!
        let pass2: String = self.pass2.text!
        let nombre: String = self.nameText.text!
        let apellidos: String = self.lastnameText.text!
        let fecha: String = self.dateTextField.text!
        
        //Si los campos están vacios
        if (email == "" || pass1 == "" || pass2 == "" || nombre == "" || apellidos == "" || fecha == "") {
            self.mostrarError(mess: "Los campos están vacíos")
        }
            
        //Si las contraseñas no coinciden o contienen menos de 5 caracteres.
        else if (!self.comprobarPasswords(p1: pass1, p2: pass2)) {
            self.mostrarError(mess: "Las contraseñas no coinciden o es demasiado corta")
        }
        
        //Si el email no tiene una arroba.
        else if (!self.comprobarEmailValido(email: email)) {
            self.mostrarError(mess: "El email no es válido")
        }
            
        else {
            let alertController = mostrarCargando( mensaje: "Registrando...\n\n")
            DispatchQueue.main.async(execute: {
                self.present(alertController, animated: true, completion: nil)
            });
            
            con.registrarUsuario(email: email, pass: pass1, name: nombre, last: apellidos, date: fecha) {
                respuesta in
                //Si el servidor no responde
                if (respuesta.value(forKey: "errorno") as! NSNumber == 404) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        alertController.dismiss(animated: true, completion: {
                            self.mostrarError(mess: respuesta.value(forKey: "errorMessage") as! String)
                        })
                    }
                }
                else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.dismiss(animated: true, completion: {
                            //Registro realizado correctamente
                            if (respuesta.value(forKey: "errorno") as! NSNumber == 0) {
                                let alert = UIAlertController(title: nil, message: "Ha completado su registro correctamente", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Aceptar", style: .default) { action in
                                    self.navigationController?.popViewController(animated: true)
                                })
                                self.present(alert, animated: true)
                            }
                            //Ocurrió un error con la operación
                            else if (respuesta.value(forKey: "errorno") as! NSNumber != 404) {
                                self.mostrarError(mess: respuesta.value(forKey: "errorMessage") as! String)
                            }
                        })
                    }
                }
            }
        }
    }
}
