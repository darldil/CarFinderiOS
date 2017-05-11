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

class MapTableController: UITableViewController {
    
    private var numRows : Int = 0
    private var usuario : String = ""
    private var coches : [TransferCoches] = []
    private var lastSelection : IndexPath? = nil
    private var localizaciones : [String : (Any)] = [:]
    var containerToMaster:ContainerToMaster?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
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
        coches = []
        tableView.reloadData()
        self.loadCarsTable()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.coches.count
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //Eliminar una posicion
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let con = Mapa ()
            // handle delete (by removing the data from your array and updating the tableview)
            let matr = coches[indexPath.item].getMatricula()
            tableView.isEditing = false
            con.eliminarPosicion(matricula: matr) {
                respuesta in
                
                //Si el servidor ha fallado
                if (respuesta.value(forKey: "errorno") as! NSNumber == 404) {
                    let alert = UIAlertController(title: "Error", message: respuesta.value(forKey: "errorMessage") as? String, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Aceptar", style: .default) { action in
                        alert.dismiss(animated: true, completion: nil)
                        self.loadCarsTable()
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
                        self.localizaciones[matr] = nil
                        self.sendMatriculaToMap()
                    }
                }
            }
            
        }
    }
    
    
    private func loadCarsTable() {
        let con = Coches ()
        let preferences = UserDefaults.standard
        
        self.usuario = preferences.string(forKey: "user")!
        
        con.cargarCoches(email: usuario) {
            respuesta in
            
            //Si el servidor ha fallado
            if (respuesta.value(forKey: "errorno") as! NSNumber == 404) {
                //alertController.dismiss(animated: true, completion: {
                let alert = UIAlertController(title: "Error", message: respuesta.value(forKey: "errorMessage") as? String, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Aceptar", style: .default) { action in
                    alert.dismiss(animated: true, completion: nil)
                })
                self.present(alert, animated: true)
                //})
            }
            else {
                
                //Si los datos son correctos
                if (respuesta.value(forKey: "errorno") as! NSNumber == 0) {
                    let datos : [[String:String]] = respuesta.value(forKey: "coches") as! [[String : String]]
                    
                    for temp in datos {
                        let transfer : TransferCoches = TransferCoches ()
                        transfer.setMatricula(matr: temp["matricula"]!)
                        transfer.setModelo(mod:temp["modelo"]!)
                        transfer.setMarca(marca: temp["marca"]!)
                        self.coches.append(transfer)
                        self.numRows += 1
                    }
                    self.loadCarPositions()
                    self.reloadTable()
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
    
    private func reloadTable() {
        
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            return
        })
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    
    //Rellena las celdas y las añade a la tabla
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        
        if (coches.capacity != 0) {
            cell.textLabel?.text = coches[indexPath.row].getMarca() + " " +
            coches[indexPath.row].getModelo() + " - " + coches[indexPath.row].getMatricula()
        }
        
        return cell
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
