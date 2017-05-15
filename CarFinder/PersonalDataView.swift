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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return 4
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
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
            texto = "Fecha Nacimiento: "
        }
        cell.textLabel?.text = texto + datos[indexPath.row]
        
        return cell
    }
    
}
