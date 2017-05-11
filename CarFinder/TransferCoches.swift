//
//  TransferCoches.swift
//  CarFinder
//
//  Created by Mauri on 11/5/17.
//  Copyright © 2017 Mauri. All rights reserved.
//

import Foundation

class TransferCoches {
    private var matricula : String = ""
    private var marca : String = ""
    private var modelo : String = ""
    
    func setMatricula(matr : String) {
        self.matricula = matr
    }
    
    func getMatricula() -> String {
        return self.matricula
    }
    
    func setMarca(marca : String) {
        self.marca = marca
    }
    
    func getMarca() -> String {
        return self.marca
    }
    
    func setModelo(mod : String) {
        self.modelo = mod
    }
    
    func getModelo() -> String {
        return self.modelo
    }
}
