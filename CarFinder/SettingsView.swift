//
//  SettingsView.swift
//  CarFinder
//
//  Created by Mauri on 20/4/17.
//  Copyright © 2017 Mauri. All rights reserved.
//

import UIKit

class SettingsView: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView.delegate = self
        tableView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let option : [String: Int] = ["section": indexPath.section, "row": indexPath.row]
        
        menuPrefs(opt: option)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    
    private func menuPrefs(opt: [String: Int]) {
        
        if (opt["section"] == 1 && opt["row"] == 0) {
            let alertController = UIAlertController(title: "Cerrar Sesión", message: "¿Seguro que desea cerrar la sesión?", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Aceptar", style: .default) { action in
                
                alertController.dismiss(animated: true, completion: nil)
                
                let prefs = UserDefaults.standard
                prefs.removeObject(forKey: "email")
                prefs.removeObject(forKey: "pass")
                
                self.dismiss(animated: true, completion: nil)
            }
            
            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { action in
                alertController.dismiss(animated: true, completion: nil)
            }
            
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            //Show alert view
            present(alertController, animated: true)
        }
    }
}
