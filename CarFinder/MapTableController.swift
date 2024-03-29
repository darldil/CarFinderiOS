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
    
    func cargarMapa(lat : Double, lng: Double, descripcion : String)
}

class MapTableController: CarPrincipalView {
    
    private var ultimoSeleccionado : IndexPath? = nil
    private var localizaciones : [String : (Any)] = [:]
    var containerToMaster:ContainerToMaster?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Cuando selecciono una fila
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //Si hay un coche seleccionado y es distinto del coche que acaba de pulsar el usuario
        if (ultimoSeleccionado != nil && ultimoSeleccionado?.row != indexPath.row) {
            tableView.cellForRow(at: ultimoSeleccionado!)?.accessoryType = .none
            ultimoSeleccionado = indexPath
            tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark
        }
        //Si hay un coche seleccionado y este es el coche que acaba de pulsar el usuario
        else if (ultimoSeleccionado != nil && ultimoSeleccionado?.row == indexPath.row) {
            tableView.cellForRow(at: ultimoSeleccionado!)?.accessoryType = .none
            ultimoSeleccionado = nil
        }
        
        else {
            ultimoSeleccionado = indexPath
            tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark
        }
        enviarMatriculaMapa()
    }
    
    //Cuando se pulsa un coche
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
            cell.accessoryType = .none
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.cargarPosicionesCoches()
    }
    
    //Eliminar una posicion
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let con = Mapa ()
            // handle delete (by removing the data from your array and updating the tableview)
            let matr = coches[indexPath.item].getMatricula()
            if (localizaciones[matr] == nil) {
                self.mostrarError(mess: "El coche no está aparcado")
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
                        self.mostrarError(mess: respuesta.value(forKey: "errorMessage") as! String)
                        super.cargar()
                    }
                    //Si la conexión se ha realizado correctamente
                    else {
                        //Si los datos no son correctos
                        if (respuesta.value(forKey: "errorno") as! NSNumber != 0) {
                            self.mostrarError(mess: respuesta.value(forKey: "errorMessage") as! String)
                            self.recargarTabla()
                        }
                        else {
                            let alertController = UIAlertController(title: nil, message: "Posición borrada", preferredStyle: .alert)
                            DispatchQueue.main.async(execute: {
                                if self.presentedViewController == nil {
                                    self.present(alertController, animated: true, completion: nil)
                                } else{
                                    self.dismiss(animated: false) { () -> Void in
                                        self.present(alertController, animated: true, completion: nil)
                                    }
                                }
                            })
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                alertController.dismiss(animated: true, completion: nil)
                                self.localizaciones[matr] = nil
                                self.enviarMatriculaMapa()
                            }
                        }
                    }
                }
            }
        }
    }
    
    //Carga las posiciones de todos los coches
    private func cargarPosicionesCoches() {
        let con = Mapa ()
        let preferences = UserDefaults.standard
        
        let user = preferences.string(forKey: "user")!
        
        con.cargarPosiciones(usuario: user) {
            respuesta in
            
            //Si el servidor ha fallado
            if (respuesta.value(forKey: "errorno") as! NSNumber == 404) {
                self.mostrarError(mess: respuesta.value(forKey: "errorMessage") as! String)
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
    
    //Actualiza la posición de un coche
    internal func actualizarPosicionCoche (matricula: String, lat: String, long: String) {
        var temp : [String : Any] = [:]
        temp["latitud"] = lat
        temp["longitud"] = long
        localizaciones[matricula] = temp
    }
    
    //Función que envia los datos del vehículo a la clase MapView para mostrarlos en el mapa
    private func enviarMatriculaMapa() {
        
        if (ultimoSeleccionado == nil) {
            containerToMaster?.matriculafromcontainer(containerData: "")
        } else {
            let temp = coches[(ultimoSeleccionado?.row)!].getMatricula()
            if let datos : [String : Any] = localizaciones[temp] as? [String : Any] {
                containerToMaster?.matriculafromcontainer(containerData: temp, latitud: datos["latitud"] as! String, long: datos["longitud"] as! String, description: temp)
            }
            else {
                containerToMaster?.matriculafromcontainer(containerData: coches[(ultimoSeleccionado?.row)!].getMatricula());
            }
        }
    }
}
