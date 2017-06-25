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
    
    private var latitudActual : Double = 0
    private var longitudActual : Double = 0
    private var localizacionDesactivada : Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        WebBrowserView.delegate = self
        if (self.inicializarLocalizacion()) {
            localizacionDesactivada = false
            self.cargarMapa(lat: 0, lng: 0, descripcion: "vacio")
        }
    }
    
    //Si la RAM se agota, elimina la caché cargada en RAM del navegador
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
    }
    
    //Prepara para cargar el ContainerView con la tabla inferior de la sección
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "containerViewSegue" {
            containerViewController = segue.destination as? MapTableController
            containerViewController!.containerToMaster = self
        }
    }
    
    //Cuando se muestre la interfaz se inicializará la localización
    override func viewWillAppear(_ animated: Bool) {
        locationManager.startUpdatingLocation()
    }
    
    //Cuando se descarga la vista se desactiva la localización para ahorrar batería
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
        locationManager.stopUpdatingLocation()
    }
    
    //Activa la localización, pidiendo los permisos necesarios en caso de no disponer de ellos
    private func inicializarLocalizacion() ->Bool {
        locationManager.delegate = self
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        //Si no tiene han seleccionado permisos, lo pide al usuario
        if (authorizationStatus == CLAuthorizationStatus.notDetermined) {
            locationManager.requestWhenInUseAuthorization()
            return false
        }
        
        //Si no tiene han seleccionado permisos, muestra error
        else if (authorizationStatus == CLAuthorizationStatus.denied){
            mostrarError()
            return false
        }
        //Inicia el seguimiento
        else {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            self.startLocation = nil
        }
        return true
    }
    
    //Muestra un error por no disponer de permisos de localización
    private func mostrarError() {
        let URL = Bundle.main.url(forResource: "error", withExtension: "html")
            
        let request = URLRequest(url: URL!)
        WebBrowserView.loadRequest(request)
        WebBrowserView.scrollView.isScrollEnabled = false
        WebBrowserView.scrollView.bounces = false
    }
    
    //Guarda la localización actual para el vehículo seleccionado
    @IBAction func savePosition(_ sender: Any) {
        if (!localizacionDesactivada) {
            //Si no se ha seleccionado ninguno
            if (matriculaSeleccionada == "") {
                self.mostrarError(mess: "No ha seleccionado ningún vehículo")
            }
            else {
                let con = Mapa()
                con.insertarPosicion(matricula: matriculaSeleccionada, latitud: String(format:"%f", latitudActual), longitud: String(format:"%f", longitudActual)) {
                    respuesta in
                    //Si ocurrió un problema con el servidor
                    if (respuesta.value(forKey: "errorno") as! NSNumber == 404) {
                        self.mostrarError(mess: respuesta.value(forKey: "errorMessage") as! String)
                    }
                    //Posición guardada con éxito
                    else {
                        let alertController = UIAlertController(title: nil, message: "Posición guardada", preferredStyle: .alert)
                        self.present(alertController, animated: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            alertController.dismiss(animated: true, completion: nil)
                            self.containerViewController?.actualizarPosicionCoche(matricula: self.matriculaSeleccionada, lat: String(self.latitudActual), long: String (self.longitudActual))
                            self.cargarMapa(lat : self.latitudActual, lng: self.longitudActual, descripcion : self.matriculaSeleccionada)
                        }
                    }
                }
            }
        } else {
            self.mostrarError(mess: "No puede guardar la localización porque la aplicación no tiene permisos para conocer esta")
        }
    }
    
    //Recarga la localización actual a petición del usuario
    @IBAction func myLocationReload(_ sender: Any) {
        if (!localizacionDesactivada) {
            cargarMapa(lat : latitudActual, lng: longitudActual, descripcion: "actual")
        } else {
            mostrarError()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latestLocation: CLLocation = locations[locations.count - 1]
        let long = latestLocation.coordinate.longitude;
        let lat = latestLocation.coordinate.latitude;
        if startLocation == nil {
            startLocation = latestLocation
            localizacionDesactivada = false
        }
        
        if (lat > latitudActual + 0.0005 || lat < latitudActual - 0.0005 || long > longitudActual + 0.0005 || long < longitudActual - 0.0005) {
            latitudActual = lat
            longitudActual = long
            cargarMapa(lat : lat, lng: long, descripcion: "actual")
        }
    }
    
    //Carga el mapa en el web view con los datos indicados
    internal func cargarMapa(lat : Double, lng: Double, descripcion : String) {
        var URL = Bundle.main.url(forResource: "mapa", withExtension: "html")
        
        let URLwithparameters : String = (URL?.path)! + "?lat="+String(format:"%.4f", lat)+"&lng="+String(format:"%.4f", lng)+"&description="+descripcion
        URL = Foundation.URL(string: URLwithparameters)
        let request = URLRequest(url: URL!)
        WebBrowserView.loadRequest(request)
    }
    
    //Muestra un activity indicator cuando el Web View se está cargando
    func webViewDidStartLoad(_: UIWebView){
        activity.isHidden = false
        activity.startAnimating()
        
    }
    
    //Captura la matricula del coche con su posición y redirige a la aplicación de Apple Maps
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
    
    //Detiene el Acitivty Indicator
    func webViewDidFinishLoad(_: UIWebView){
        activity.isHidden = true
        activity.stopAnimating()
    }
    
    //Redirección desde la clase MapTableController, se usa al deseleccionar un coche para cargar la localización actual
    func matriculafromcontainer(containerData : String) {
        self.matriculaSeleccionada = containerData
        if (!localizacionDesactivada) {
            cargarMapa(lat : latitudActual, lng: longitudActual, descripcion: "actual")
        }
        else {
            mostrarError()
        }
    }
    
    //Redirección desde la clase MapTableController, se usa al seleccionar un coche para cargar la localización del coche
    func matriculafromcontainer(containerData : String, latitud : String, long : String, description : String) {
        self.matriculaSeleccionada = containerData
        cargarMapa(lat : Double(latitud)!, lng: Double(long)!, descripcion: description)
    }
    
}
