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
        if (self.load()) {
            locationDisabled = false
            self.loadMap(lat: 0, lng: 0, descripcion: "vacio")
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
    
    private func load() ->Bool {
        locationManager.delegate = self
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        if (authorizationStatus == CLAuthorizationStatus.notDetermined) {
            locationManager.requestWhenInUseAuthorization()
            return false
        } else if (authorizationStatus == CLAuthorizationStatus.denied){
            showError()
            return false
        } else {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            self.startLocation = nil
        }
        return true
    }
    
    private func showError() {
        let URL = Bundle.main.url(forResource: "error", withExtension: "html")
            
        let request = URLRequest(url: URL!)
        WebBrowserView.loadRequest(request)
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
                        self.containerViewController?.updateCarLocation(matricula: self.matriculaSeleccionada, lat: String(self.currentLat), long: String (self.currentLong))
                    }
                }
            }
        }
    }
    
    @IBAction func myLocationReload(_ sender: Any) {
        if (!locationDisabled) {
            loadMap(lat : currentLat, lng: currentLong, descripcion: "actual")
        } else {
            showError()
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
            loadMap(lat : lat, lng: long, descripcion: "actual")
        }
    }
    
    private func loadMap(lat : Double, lng: Double, descripcion : String) {
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
            
            let latitude: CLLocationDegrees = Double(lat!)!
            let longitude: CLLocationDegrees = Double(long!)!
            
            let regionDistance:CLLocationDistance = 44
            let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
            let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
            ]
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = matr
            mapItem.openInMaps(launchOptions: options)
        }
        return true
    }
    
    func webViewDidFinishLoad(_: UIWebView){
        
        activity.isHidden = true
        activity.stopAnimating()
    }
    
    func matriculafromcontainer(containerData : String) {
        self.matriculaSeleccionada = containerData
        loadMap(lat : currentLat, lng: currentLong, descripcion: "actual")
    }
    
    func matriculafromcontainer(containerData : String, latitud : String, long : String, description : String) {
        self.matriculaSeleccionada = containerData
        reloadMapPosition(lat : Double(latitud)!, lng: Double(long)!, description: description)
    }
    
    func reloadMapPosition(lat : Double, lng: Double, description : String) {
        loadMap(lat: lat, lng: lng, descripcion: description)
    }
    
}
