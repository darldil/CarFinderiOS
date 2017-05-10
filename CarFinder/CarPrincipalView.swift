//
//  CarPrincipalView.swift
//  CarFinder
//
//  Created by Mauri on 25/4/17.
//  Copyright © 2017 Mauri. All rights reserved.
//

import UIKit

class CarPrincipalView: UITableViewController {
    
    private var datos : [String] = []
    private var numRows : Int = 0
    private var usuario : String = ""
    private var matriculas : [String] = []
    private var loaded : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func edit(_ sender: Any) {
        if !self.tableView.isEditing {
            self.tableView.setEditing(true, animated: true)
        } else {
            self.tableView.setEditing(false, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        datos = []
        matriculas = []
        tableView.reloadData()
        self.cargar()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.datos.count
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let con = Coches ()
            // handle delete (by removing the data from your array and updating the tableview)
            let matr = matriculas[indexPath.item]
            datos.remove(at: indexPath.item)
            matriculas.remove(at: indexPath.item)
            tableView.deleteRows(at: [indexPath], with: .fade)
            con.eliminarCoche(matricula: matr, email: self.usuario) {
                respuesta in
                
                //Si el servidor ha fallado
                if (respuesta.value(forKey: "errorno") as! NSNumber == 404) {
                    let alert = UIAlertController(title: "Error", message: respuesta.value(forKey: "errorMessage") as? String, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Aceptar", style: .default) { action in
                        alert.dismiss(animated: true, completion: nil)
                        self.cargar()
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
                }
            }
            /*self.datos.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)*/
            
        }
    }

    
    private func cargar() {
        let con = Coches ()
        let alertController = showConnecting(mensaje: "Cargando...\n\n")
        let preferences = UserDefaults.standard
        
        self.usuario = preferences.string(forKey: "user")!
        
        if !loaded {
            DispatchQueue.main.async(execute: {
                self.present(alertController, animated: true, completion: nil)
            });
        }
        
        con.cargarCoches(email: usuario) {
            respuesta in
            
            //Si el servidor ha fallado
            if (respuesta.value(forKey: "errorno") as! NSNumber == 404) {
                alertController.dismiss(animated: true, completion: {
                    let alert = UIAlertController(title: "Error", message: respuesta.value(forKey: "errorMessage") as? String, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Aceptar", style: .default) { action in
                        alert.dismiss(animated: true, completion: nil)
                    })
                    self.present(alert, animated: true)
                })
            }
            else {
                //Si la conexión se ha realizado correctamente
                if !self.loaded {
                    alertController.dismiss(animated: true, completion: nil)
                }
                
                //Si los datos son correctos
                if (respuesta.value(forKey: "errorno") as! NSNumber == 0) {
                    let datos : [[String:String]] = respuesta.value(forKey: "coches") as! [[String : String]]
        
                    for temp in datos {
                        let string : String = temp["marca"]! + " " + temp["modelo"]! + " - " + temp["matricula"]!
                        self.datos.append(string)
                        self.matriculas.append(temp["matricula"]!)
                        self.numRows += 1
                    }
                    self.reloadTable()
                }
            }
            self.loaded = true
        }
    }
    
    private func reloadTable() {
        
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            return
        })
    }
    
    
    /*override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }*/
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        
        if (datos.capacity != 0) {
            cell.textLabel?.text = datos[indexPath.row]
            cell.textLabel?.textColor = UIColor.white
        }
        
        return cell
    }
}