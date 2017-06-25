//
//  AddCarView.swift
//  CarFinder
//
//  Created by Mauri on 25/4/17.
//  Copyright © 2017 Mauri. All rights reserved.
//

import UIKit

class AddCarView: UIViewController {
    
    @IBOutlet weak var matricula: UITextField!
    @IBOutlet weak var marca: UITextField!
    @IBOutlet weak var modelo: UITextField!
    
    private var usuario : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cerrarElTecladoCuandoSePulseFuera()
        let preferences = UserDefaults.standard
        self.usuario = preferences.string(forKey: "user")!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func aceptar(_ sender: Any) {
        let con = Coches ()
        let matr = self.matricula.text!
        let mar = self.marca.text!
        let mod = self.modelo.text!
        
        if (matr == "" || mar == "" || mod == "") {
            self.mostrarError(mess: "Los campos están vacíos")
        }
        
        else {
            let alertController = mostrarCargando( mensaje: "Guardando...\n\n")
            DispatchQueue.main.async(execute: {
                self.present(alertController, animated: true, completion: nil)
            });
            
            con.insertarCoche(matricula: matr, marca: mar, modelo: mod, email: self.usuario) {
                respuesta in
                
                if (respuesta.value(forKey: "errorno") as! NSNumber == 404) {
                    alertController.dismiss(animated: true, completion: {
                        self.mostrarError(mess: respuesta.value(forKey: "errorMessage") as! String)
                    })
                }
                else {
                    alertController.dismiss(animated: true, completion: {
                        if (respuesta.value(forKey: "errorno") as! NSNumber == 0) {
                            self.navigationController?.popViewController(animated: true)
                        } else {
                            self.mostrarError(mess: respuesta.value(forKey: "errorMessage") as! String)
                        }
                    })
                }
            }

        }
    }

}
