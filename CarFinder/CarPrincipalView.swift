//
//  CarPrincipalView.swift
//  CarFinder
//
//  Created by Mauri on 25/4/17.
//  Copyright © 2017 Mauri. All rights reserved.
//

import UIKit

class CarPrincipalView: UITableViewController {
    
    //private var datos : [String] = []
    internal var numRows : Int = 0
    internal var usuario : String = ""
    internal var coches : [TransferCoches] = []
    @IBOutlet weak var loadingActivity: UIActivityIndicatorView!
    
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
        coches = []
        tableView.reloadData()
        self.cargar()
    }
    
    //Devuelve el número de secciones
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //Devuelve el numero de filas de una sección
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.coches.count
    }
    
    //Permite editar una tabla
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //Eliminar un coche
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let con = Coches ()
            let matr = coches[indexPath.item].getMatricula()
            coches.remove(at: indexPath.item)
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
                            self.recargarTabla()
                        })
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    }

    //Carga los coches del usuario
    internal func cargar() {
        let con = Coches ()
        let preferences = UserDefaults.standard
        
        self.usuario = preferences.string(forKey: "user")!
        
        con.cargarCoches(email: usuario) {
            respuesta in
            
            if(self.loadingActivity != nil) {
                DispatchQueue.main.async(execute: {
                    self.loadingActivity.stopAnimating()
                })
            }
            
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
                    let datos : [[String:String]] = respuesta.value(forKey: "coches") as! [[String : String]]
        
                    for temp in datos {
                        let transfer : TransferCoches = TransferCoches ()
                        transfer.setMatricula(matr: temp["matricula"]!)
                        transfer.setModelo(mod:temp["modelo"]!)
                        transfer.setMarca(marca: temp["marca"]!)
                        self.coches.append(transfer)
                        self.numRows += 1
                    }
                    self.recargarTabla()
                }
            }
        }
    }
    
    internal func recargarTabla() {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            return
        })
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        
        if (coches.capacity != 0) {
            cell.textLabel?.text = coches[indexPath.row].getMarca() + " " +
                coches[indexPath.row].getModelo() + " - " + coches[indexPath.row].getMatricula()
        }
        
        return cell
    }
}
