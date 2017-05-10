//
//  Coches.swift
//  CarFinder
//
//  Created by Mauri on 25/4/17.
//  Copyright © 2017 Mauri. All rights reserved.
//

import Foundation

class Coches: conexion {
    
    private let coches : String = "Coches.php"
    
    func insertarCoche(matricula:String, marca:String, modelo: String, email: String, finished: @escaping ((_ respuesta: NSDictionary)->Void)) {
        
        let datos = "action=insertar&matricula="+matricula+"&marca="+marca+"&modelo="+modelo+"&email="+email
        
        ejecutar(peticion: datos, tipo: self.coches) {
            respuesta in
            finished(respuesta)
        }
    }
    
    func cargarCoches(email:String, finished: @escaping ((_ respuesta: NSDictionary)->Void)) {
        
        let datos = "action=leerCoches&email="+email
    
        ejecutar(peticion: datos, tipo: self.coches) {
            respuesta in
            finished(respuesta)
        }
    }
    
    func eliminarCoche(matricula: String, email:String, finished: @escaping ((_ respuesta: NSDictionary)->Void)) {
        
        let datos = "action=borrar&matricula="+matricula+"&email="+email
        
        ejecutar(peticion: datos, tipo: self.coches) {
            respuesta in
            finished(respuesta)
        }
    }
    
}
