//
//  conexion.swift
//  CarFinder
//
//  Created by Mauri on 18/4/17.
//  Copyright © 2017 Mauri. All rights reserved.
//

import Foundation

class conexion {
    
    //private let url = "http://192.168.1.21/carfinder/"
    private let url = "http://car.abbaticaffe.com/"
    
    internal func ejecutar(peticion:String, tipo:String, finished: @escaping ((_ respuesta: NSDictionary)->Void)) {
        
        let urlComplete: URL = URL(string: self.url + tipo)!
        var request: URLRequest = URLRequest(url: urlComplete)
        request.httpMethod = "POST"
        request.httpBody = peticion.data(using: String.Encoding.utf8);
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            
            if data != nil {
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                        finished(json)
                        
                    }
                } catch let error {
                    print(error.localizedDescription)
                    return
                }
            }
            
            else {
                let dict = ["errorno": 404, "errorMessage": "Existe un problema de conexion con el servidor"] as [String : Any]
                let aux = dict as NSDictionary
                finished(aux)
            }
        })
        task.resume()
        
    }

}
