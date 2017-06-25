//
//  Extensiones.swift
//  CarFinder
//
//  Created by Mauri on 20/4/17.
//  Copyright © 2017 Mauri. All rights reserved.
//

import UIKit


extension UIViewController {
    //Cierra el teclado cuando se pulsa fuera de este
    func cerrarElTecladoCuandoSePulseFuera() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.ocultarTeclado))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    //Cierra el teclado
    func ocultarTeclado() {
        view.endEditing(true)
    }
    
    //Muestra un dialogo de carga, que finaliza cuando finalice esta
    func mostrarCargando(mensaje : String) -> UIAlertController {
        let alertController = UIAlertController(title: nil, message: mensaje, preferredStyle: .alert)
        
        let spinnerIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle:     UIActivityIndicatorViewStyle.whiteLarge)
        
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        
        alertController.view.addSubview(spinnerIndicator)
        return alertController
    }
    
    //Muestra un dialogo de error
    func mostrarError(mess: String) {
        let alert = UIAlertController(title: "Error", message: mess, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default) { action in
            alert.dismiss(animated: true, completion: nil)
        })
        if presentedViewController == nil {
            self.present(alert, animated: true, completion: nil)
        } else{
            self.dismiss(animated: false) { () -> Void in
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
