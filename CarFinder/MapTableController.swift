//
//  CarPrincipalView.swift
//  CarFinder
//
//  Created by Mauri on 25/4/17.
//  Copyright © 2017 Mauri. All rights reserved.
//

import UIKit

protocol ContainerToMaster {
    func matriculafromcontainer(containerData : String)
    
    func matriculafromcontainer(containerData : String, latitud : String, long : String, description : String)
    
    func reloadMapPosition(lat : Double, lng: Double, description : String)
}

class MapTableController: CarPrincipalView {
    
    private var lastSelection : IndexPath? = nil
    private var localizaciones : [String : (Any)] = [:]
    var containerToMaster:ContainerToMaster?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        self.loadCarPositions()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Cuando selecciono una fila
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (lastSelection != nil && lastSelection?.row != indexPath.row) {
            tableView.cellForRow(at: lastSelection!)?.accessoryType = .none
        }
        
        lastSelection = indexPath
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark
        sendMatriculaToMap()
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            cell.accessoryType = .none
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //Eliminar una posicion
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let con = Mapa ()
            // handle delete (by removing the data from your array and updating the tableview)
            let matr = coches[indexPath.item].getMatricula()
            if (localizaciones[matr] == nil) {
                let alert = UIAlertController(title: "Error", message: "El coche no está aparcado", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Aceptar", style: .default) { action in
                    alert.dismiss(animated: true, completion: nil)
                })
                self.present(alert, animated: true)
            }
            else {
                tableView.isEditing = false
                if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
                    cell.accessoryType = .none
                }
                con.eliminarPosicion(matricula: matr) {
                    respuesta in
                    //Si el servidor ha fallado
                    if (respuesta.value(forKey: "errorno") as! NSNumber == 404) {
                        let alert = UIAlertController(title: "Error", message: respuesta.value(forKey: "errorMessage") as? String, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Aceptar", style: .default) { action in
                            alert.dismiss(animated: true, completion: nil)
                            super.cargar()
                        })
                        self.present(alert, animated: true)
                    }
                    //Si la conexión se ha realizado correctamente
                    else {
                        //Si los datos no son correctos
                        if (respuesta.value(forKey: "errorno") as! NSNumber != 0) {
                            let alert = UIAlertController(title: "Error", message: respuesta.value(forKey: "errorMessage") as? String, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Aceptar", style: .default) { action in
                                alert.dismiss(animated: true, completion: nil)
                                self.reloadTable()
                            })
                            self.present(alert, animated: true)
                        }
                        else {
                            let alertController = UIAlertController(title: nil, message: "Posición borrada", preferredStyle: .alert)
                            self.present(alertController, animated: true)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                alertController.dismiss(animated: true, completion: nil)
                                self.localizaciones[matr] = nil
                                self.sendMatriculaToMap()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func loadCarPositions() {
        let con = Mapa ()
        let preferences = UserDefaults.standard
        
        let user = preferences.string(forKey: "user")!
        
        con.cargarPosiciones(usuario: user) {
            respuesta in
            
            //Si el servidor ha fallado
            if (respuesta.value(forKey: "errorno") as! NSNumber == 404) {
                let alert = UIAlertController(title: "Error", message: respuesta.value(forKey: "errorMessage") as? String, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Aceptar", style: .default) { action in
                    alert.dismiss(animated: true, completion: nil)
                })
                self.present(alert, animated: true)
            }
            else {
            
                //Si los datos son correctos
                if (respuesta.value(forKey: "errorno") as! NSNumber == 0) {
                    var i = 0
                    for datos in respuesta.value(forKey: "coches") as! [[String : Any]] {
                        let matricula : String = datos["matricula"] as! String
                        let coordenadas = datos["coordenadas"] as! [[String : Any]]
                    
                        self.localizaciones[matricula] = (coordenadas[i] as [String : Any])
                        i += 1
                    }
                    
                }
            }
        }
    }
    
    func updateCarLocation (matricula: String, lat: String, long: String) {
        var temp : [String : Any] = [:]
        temp["latitud"] = lat
        temp["longitud"] = long
        localizaciones[matricula] = temp
    }
    
    func sendMatriculaToMap() {
        
        if (lastSelection == nil) {
            containerToMaster?.matriculafromcontainer(containerData: "")
        } else {
            let temp = coches[(lastSelection?.row)!].getMatricula()
            if let datos : [String : Any] = localizaciones[temp] as? [String : Any] {
                containerToMaster?.matriculafromcontainer(containerData: temp, latitud: datos["latitud"] as! String, long: datos["longitud"] as! String, description: temp)
            }
            else {
                containerToMaster?.matriculafromcontainer(containerData: coches[(lastSelection?.row)!].getMatricula());
            }
        }
    }
}
