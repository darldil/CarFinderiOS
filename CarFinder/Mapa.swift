//
//  Mapa.swift
//  CarFinder
//
//  Created by Mauri on 27/4/17.
//  Copyright © 2017 Mauri. All rights reserved.
//

import Foundation

class Mapa: conexion {
    
    private let mapa : String = "Mapa.php"
    
    func insertarPosicion(matricula:String, latitud:String, longitud: String, finished: @escaping ((_ respuesta: NSDictionary)->Void)) {
        
        let datos = "action=insertar&matricula="+matricula+"&longitud="+longitud+"&latitud="+latitud
        
        ejecutar(peticion: datos, tipo: self.mapa) {
            respuesta in
            finished(respuesta)
        }
    }
    
    func cargarPosiciones(usuario:String, finished: @escaping ((_ respuesta: NSDictionary)->Void)) {
        
        let datos = "action=leerPorUsuario&email="+usuario
        
        ejecutar(peticion: datos, tipo: self.mapa) {
            respuesta in
            finished(respuesta)
        }
    }
    
    func eliminarPosicion(matricula: String, finished: @escaping ((_ respuesta: NSDictionary)->Void)) {
        
        let datos = "action=borrar&matricula="+matricula
        
        ejecutar(peticion: datos, tipo: self.mapa) {
            respuesta in
            finished(respuesta)
        }
    }
    
}
