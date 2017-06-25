//
//  PersonalDataView.swift
//  CarFinder
//
//  Created by Mauri on 23/4/17.
//  Copyright © 2017 Mauri. All rights reserved.
//

import UIKit

class PersonalDataView: UITableViewController {
    
    private var datos : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        
        datos.append(defaults.string(forKey: "name")!)
        datos.append(defaults.string(forKey: "lastname")!)
        datos.append(defaults.string(forKey: "user")!)
        datos.append(defaults.string(forKey: "date")!)
    }
    
    //Devuelve el número de secciones (en este caso siempre 1)
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //Devuelve el número de filas (en este caso siempre 4)
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    //Gestiona los efectos visuales de la tabla (al pulsar la fila se deselecciona automáticamente)
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //Determina el texto a insertar en cada celda de la tabla
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        
        var texto : String;
        
        if (indexPath.row == 0) {
            texto = "Nombre: "
        } else if (indexPath.row == 1) {
            texto = "Apellidos: "
        } else if (indexPath.row == 2) {
            texto = "Email: "
        }else {
            texto = "Fecha de Nacimiento: "
        }
        cell.textLabel?.text = texto + datos[indexPath.row]
        
        return cell
    }
    
}
