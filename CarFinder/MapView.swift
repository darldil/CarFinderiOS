//
//  MapController.swift
//  CarFinder
//
//  Created by Mauri on 21/4/17.
//  Copyright © 2017 Mauri. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapView: UIViewController, CLLocationManagerDelegate, UIWebViewDelegate, ContainerToMaster {
    
    @IBOutlet weak var WebBrowserView: UIWebView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    var locationManager: CLLocationManager = CLLocationManager()
    var startLocation: CLLocation!
    private var matriculaSeleccionada : String = ""
    var containerViewController: MapTableController?
    
    private var currentLat : Double = 0
    private var currentLong : Double = 0
    private var locationDisabled : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        WebBrowserView.delegate = self
        if (self.cargar()) {
            locationDisabled = false
            self.cargarMapa(lat: 0, lng: 0, descripcion: "vacio")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "containerViewSegue" {
            containerViewController = segue.destination as? MapTableController
            containerViewController!.containerToMaster = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
        locationManager.stopUpdatingLocation()
    }
    
    private func cargar() ->Bool {
        locationManager.delegate = self
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        if (authorizationStatus == CLAuthorizationStatus.notDetermined) {
            locationManager.requestWhenInUseAuthorization()
            return false
        } else if (authorizationStatus == CLAuthorizationStatus.denied){
            mostrarError()
            return false
        } else {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            self.startLocation = nil
        }
        return true
    }
    
    private func mostrarError() {
        let URL = Bundle.main.url(forResource: "error", withExtension: "html")
            
        let request = URLRequest(url: URL!)
        WebBrowserView.loadRequest(request)
        WebBrowserView.scrollView.isScrollEnabled = false
        WebBrowserView.scrollView.bounces = false
    }
    
    @IBAction func savePosition(_ sender: Any) {
        if (!locationDisabled) {
            if (matriculaSeleccionada == "") {
                let alert = UIAlertController(title: "Error", message: "No ha seleccionado ningún vehículo", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Aceptar", style: .default) { action in
                    alert.dismiss(animated: true, completion: nil)
                })
                self.present(alert, animated: true)
            }
            else {
                let con = Mapa()
                con.insertarPosicion(matricula: matriculaSeleccionada, latitud: String(format:"%f", currentLat), longitud: String(format:"%f", currentLong)) {
                    respuesta in
                
                    if (respuesta.value(forKey: "errorno") as! NSNumber == 404) {
                        let alert = UIAlertController(title: "Error", message: respuesta.value(forKey: "errorMessage") as? String, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Aceptar", style: .default) { action in
                            alert.dismiss(animated: true, completion: nil)
                        })
                        self.present(alert, animated: true)
                    }
                    else {
                        let alertController = UIAlertController(title: nil, message: "Posición guardada", preferredStyle: .alert)
                        self.present(alertController, animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            alertController.dismiss(animated: true, completion: nil)
                            self.containerViewController?.actualizarPosicionCoche(matricula: self.matriculaSeleccionada, lat: String(self.currentLat), long: String (self.currentLong))
                            self.recargarPosicionMapa(lat : self.currentLat, lng: self.currentLong, description : self.matriculaSeleccionada)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func myLocationReload(_ sender: Any) {
        if (!locationDisabled) {
            cargarMapa(lat : currentLat, lng: currentLong, descripcion: "actual")
        } else {
            mostrarError()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latestLocation: CLLocation = locations[locations.count - 1]
        let long = latestLocation.coordinate.longitude;
        let lat = latestLocation.coordinate.latitude;
        //Do What ever you want with it
        
        if startLocation == nil {
            startLocation = latestLocation
            locationDisabled = false
        }
        
        if (lat > currentLat + 0.0005 || lat < currentLat - 0.0005 || long > currentLong + 0.0005 || long < currentLong - 0.0005) {
            currentLat = lat
            currentLong = long
            cargarMapa(lat : lat, lng: long, descripcion: "actual")
        }
    }
    
    private func cargarMapa(lat : Double, lng: Double, descripcion : String) {
        var URL = Bundle.main.url(forResource: "mapa", withExtension: "html")
        
        let URLwithparameters : String = (URL?.path)! + "?lat="+String(format:"%.4f", lat)+"&lng="+String(format:"%.4f", lng)+"&description="+descripcion
        URL = Foundation.URL(string: URLwithparameters)
        let request = URLRequest(url: URL!)
        WebBrowserView.loadRequest(request)
    }
    
    func webViewDidStartLoad(_: UIWebView){
        
        activity.isHidden = false
        activity.startAnimating()
        
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if request.url?.scheme == "carfinder" {
            let lat = request.url?.getQueryItemValueForKey(key: "lat")
            let long = request.url?.getQueryItemValueForKey(key: "lon")
            let matr = request.url?.getQueryItemValueForKey(key: "description")
            
            let latitud: CLLocationDegrees = Double(lat!)!
            let longitud: CLLocationDegrees = Double(long!)!
            
            let distancia:CLLocationDistance = 44
            let coordenadas = CLLocationCoordinate2DMake(latitud, longitud)
            let region = MKCoordinateRegionMakeWithDistance(coordenadas, distancia, distancia)
            let opciones = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)
            ]
            let puntoMapa = MKPlacemark(coordinate: coordenadas, addressDictionary: nil)
            let itemMapa = MKMapItem(placemark: puntoMapa)
            itemMapa.name = matr
            itemMapa.openInMaps(launchOptions: opciones)
        }
        return true
    }
    
    func webViewDidFinishLoad(_: UIWebView){
        
        activity.isHidden = true
        activity.stopAnimating()
    }
    
    func matriculafromcontainer(containerData : String) {
        self.matriculaSeleccionada = containerData
        cargarMapa(lat : currentLat, lng: currentLong, descripcion: "actual")
    }
    
    func matriculafromcontainer(containerData : String, latitud : String, long : String, description : String) {
        self.matriculaSeleccionada = containerData
        recargarPosicionMapa(lat : Double(latitud)!, lng: Double(long)!, description: description)
    }
    
    func recargarPosicionMapa(lat : Double, lng: Double, description : String) {
        cargarMapa(lat: lat, lng: lng, descripcion: description)
    }
    
}
