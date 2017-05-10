//
//  Usuarios.swift
//  CarFinder
//
//  Created by Mauri on 19/4/17.
//  Copyright © 2017 Mauri. All rights reserved.
//

import Foundation

class Usuarios: conexion {
    
    private let usuarios : String = "Usuarios.php"
    
    func iniciarSesion(username:String, password:String, finished: @escaping ((_ respuesta: NSDictionary)->Void)) {
        
        let datos = "action=leer&email="+username+"&password="+password;
        
        ejecutar(peticion: datos, tipo: self.usuarios) {
            respuesta in
            finished(respuesta)
        }
    }
    
    func registrarUsuario(email:String, pass:String, name:String, last:String, date:String, finished: @escaping ((_ respuesta: NSDictionary)->Void)) {
        
        let datos = "action=insertar&email="+email+"&password="+pass+"&nombre="+name+"&apellidos="+last+"&fecha_nac="+date;
        
        ejecutar(peticion: datos, tipo: self.usuarios) {
            respuesta in
            finished(respuesta)
        }
    }
    
    func modificarEmail(email: String, new_Email: String, finished: @escaping ((_ respuesta: NSDictionary)->Void)) {
        
        let datos = "action=modificarEmail&email="+email+"&new_email="+new_Email;
        
        ejecutar(peticion: datos, tipo: self.usuarios) {
            respuesta in
            finished(respuesta)
        }
    }
    
    func modificarPass(email: String, password: String, finished: @escaping ((_ respuesta: NSDictionary)->Void)) {
        
        let datos = "action=modificarPassword&email="+email+"&password="+password;
        
        ejecutar(peticion: datos, tipo: self.usuarios) {
            respuesta in
            finished(respuesta)
        }
    }


}
