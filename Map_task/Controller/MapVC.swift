//
//  ViewController.swift
//  Map_task
//
//  Created by moh on 4/11/21.
//  Copyright © 2021 moh. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import SideMenu

class MapVC: UIViewController {

    @IBOutlet weak var mapkit: MKMapView!
    @IBOutlet weak var maninview: UIView!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var locationtext: UITextField!
    @IBOutlet weak var destinationtext: UITextField!
    @IBOutlet weak var nearbyBtn: UIButton!
    @IBOutlet weak var popview: UIView!
    @IBOutlet weak var popvtable: UITableView!
    @IBOutlet weak var popvbackBtn: UIButton!
    @IBOutlet weak var popvloctxt: UITextField!
    @IBOutlet weak var popvdestxt: UITextField!
    
    var locatiomanager = CLLocationManager()
    var authstatus = CLLocationManager.authorizationStatus()
    
    let searchcompleter = MKLocalSearchCompleter()
    var searchResults = [String]()
    var menu: SideMenuNavigationController!
    
    var SourcesArr = [Source]()
    var SourcesArr2 = [String]()
    var filteredarr = [Source]()
    var selectedlocation: SourceLocation!
    var selectedDestination: DestinationLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapkit.delegate = self
        authstatus = .notDetermined
        locatiomanager.delegate = self
        requestuserlocation()
        popview.isHidden = true
        popvtable.delegate = self
        popvtable.dataSource = self
        popvtable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        destinationtext.delegate = self
        locationtext.delegate = self
        popvloctxt.delegate = self
        popvdestxt.delegate = self
        searchcompleter.delegate = self
        setupviews()
        popvloctxt.addTarget(self, action: #selector(filternames), for: .editingChanged)
        popvdestxt.addTarget(self, action: #selector(filterDestin), for: .editingChanged)
        menu = SideMenuNavigationController(rootViewController: MenuTableview())
        menu.leftSide = true
        //makeDoneBtn()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        Dataservice.instance.getSources { (sourcesArr) in
            self.SourcesArr2 = sourcesArr.map { (res) -> String in
                res.name
            }
            self.SourcesArr = sourcesArr
        }
    }
    
    @IBAction func menuBtn(sender: Any) {
        //popview.isHidden = true
        present(menu, animated: true, completion: nil)
        popview.isHidden = true
    }
    
    @IBAction func backBtn(sender: Any) {
        //animmateviewdown()
        popview.isHidden = true
    }
    func setupviews() {
        nearbyBtn.layer.cornerRadius = 16
        maninview.layer.cornerRadius = 13
        popview.layer.cornerRadius = 16
        popview.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    @objc func filternames() {
        
        searchResults = self.SourcesArr2.filter({ (sou) -> Bool in
            sou.contains(popvloctxt.text!)
        })
        self.popvtable.reloadData()
    }
    @objc func filterDestin() {
        searchResults = []
        self.popvtable.reloadData()
        searchcompleter.region = mapkit.region
//        searchcompleter.pointOfInterestFilter = MKPointOfInterestFilter(excluding: [.hospital])
        searchcompleter.queryFragment = popvdestxt.text!
        self.popvtable.reloadData()
    }
    @IBAction func showdrivers() {
        
        if selectedlocation != nil && destinationtext != nil {
            Dataservice.instance.getdrivers { (drivers) in
                for driver in drivers {
                    print(driver.name)
                    print(driver.latitude)
                    print(driver.longitude)
                    print("....................")
                }
                self.addDriverpin(Drivers: drivers)
            }
        }
        else {
            print("please insert source location")
        }
        
    }
    func makeDoneBtn() {
        let bar = UIToolbar()
        let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissKeyboard))
        let SpaceBtn = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        bar.items = [SpaceBtn, SpaceBtn, doneBtn]
        bar.sizeToFit()
        popvloctxt.inputAccessoryView = bar
        popvdestxt.inputAccessoryView = bar
    }
    @objc func dismissKeyboard() {
        popview.endEditing(true)
    }
    


}

extension MapVC: MKMapViewDelegate {
    
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
       // centerMaponUserLocation()
        if selectedlocation == nil {
            centerMaponUserLocation()
        }
        else {
            let regioncoordinate = CLLocationCoordinate2D(latitude: selectedlocation.latitude, longitude: selectedlocation.longitude)
            let region = MKCoordinateRegion(center: regioncoordinate, latitudinalMeters: 3000, longitudinalMeters: 3000)
            mapkit.setRegion(region, animated: true)
        }
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
       
// called ince to save data in firebase
        
//        searchinmap { (sourcesarr) in
//            Dataservice.instance.saveSource(sourceArr: sourcesarr) { (comp) in
//                if comp {
//                    print("saved items successfully")
//                }
//            }
//        }
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let annotview = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "driverpin")
        annotview.pinTintColor = UIColor.green
        annotview.animatesDrop = true
        return annotview
    }
    
    func centerMaponUserLocation() {
        guard let coordinate = locatiomanager.location?.coordinate else {return}
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 3000, longitudinalMeters: 3000)
        mapkit.setRegion(region, animated: true)
    }
    func searchinmap(handler: @escaping(_ sources: [Source]) -> ()) {
        var sourcesarr = [Source]()
        let request = MKLocalSearch.Request()
        request.region = mapkit.region
        request.naturalLanguageQuery = "hospital"

        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let respon = response else {return}
            for item in respon.mapItems {
                
                let long = item.placemark.coordinate.longitude
                let lat = item.placemark.coordinate.latitude
                let source = Source(name: item.name!, latitude: lat, longitude: long)
                sourcesarr.append(source)
                if sourcesarr.count == respon.mapItems.count {
                    handler(sourcesarr)
                }
            }
        }
    }
    func getcoordinate(placename: String, handler: @escaping(_ placemark: MKPlacemark) ->()) {
        let request = MKLocalSearch.Request()
        request.region = mapkit.region
        request.naturalLanguageQuery = placename
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let respon = response else {return}
            let locationmark = respon.mapItems[0].placemark
            handler(locationmark)
            
        }
    }
    func getdrivers(sourcelocation: SourceLocation, handler: @escaping(_ drivers: [Driver]) ->()) {
        
        var drivers = [Driver]()
        let request = MKLocalSearch.Request()
        let locationcorr = CLLocationCoordinate2D(latitude: sourcelocation.latitude, longitude: sourcelocation.longitude)
        let region = MKCoordinateRegion(center: locationcorr, latitudinalMeters: 200, longitudinalMeters: 200)
        request.region = region
        request.naturalLanguageQuery = "coffee"
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let respon = response else {return}
            print(respon.mapItems.count)
            for (index, item) in respon.mapItems.enumerated() {
                let driver = Driver(name: "driver\(index + 1)", latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude)
                drivers.append(driver)
                if drivers.count == respon.mapItems.count {
                    handler(drivers)
                }
            }
            
        }
    }
    func addDriverpin(Drivers: [Driver]) {
        for driver in Drivers {
            let coordinate = CLLocationCoordinate2D(latitude: driver.latitude, longitude: driver.longitude)
            let driverannotation = Driverannot(coordinate: coordinate, identifier: "driverpin")
            mapkit.addAnnotation(driverannotation)
        }
        let regioncoordinate = CLLocationCoordinate2D(latitude: selectedlocation.latitude, longitude: selectedlocation.longitude)
        let region = MKCoordinateRegion(center: regioncoordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        mapkit.setRegion(region, animated: true)
        print("number of nearby Drivers is :\(mapkit.annotations.count - 1)")
    }
    func removedriverpin() {
        for annot in mapkit.annotations {
            mapkit.removeAnnotation(annot)
        }
    }
    
}

extension MapVC: CLLocationManagerDelegate {
    
    func requestuserlocation() {
        
        if authstatus == .notDetermined {
            locatiomanager.requestAlwaysAuthorization()
        }
        else {
            print("can not locate user")
            return
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMaponUserLocation()
    }

    
}
extension MapVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count

    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {return UITableViewCell()}
        
        cell.textLabel?.text = searchResults[indexPath.row]
        return cell

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Dataservice.instance.deletedrivers()
        let location = searchResults[indexPath.row]
        if SourcesArr2.contains(location) {
            Dataservice.instance.deletedrivers()
            removedriverpin()
            for item in SourcesArr{
                if item.name == location{
                    selectedlocation = SourceLocation(name: item.name, latitude: item.latitude, longitude: item.longitude)
                }
            }
            popvloctxt.text = selectedlocation.name
            locationtext.text = selectedlocation.name
            getdrivers(sourcelocation: selectedlocation) { (drivers) in
                Dataservice.instance.saveDrivers(drivers: drivers) { (saved) in
                    if saved {
                        print("saved all drivers successfully")
                    }
                }
            }
        }
        else {
            getcoordinate(placename: location) { (placemark) in
                self.selectedDestination = DestinationLocation(name: placemark.name!, latitude: placemark.coordinate.latitude, longitude: placemark.coordinate.longitude)
                self.popvdestxt.text = self.selectedDestination.name
                self.destinationtext.text = self.selectedDestination.name
            }

        }
        
    }
}

extension MapVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //locationtext.text = ""
        destinationtext.text = ""
        searchResults = []
        self.popvtable.reloadData()
        popview.isHidden = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}

extension MapVC: MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        
        searchResults =  searchcompleter.results.map({ (res) -> String in
            res.title
        })
        self.popvtable.reloadData()
    }
}




