//
//  MapVC.swift
//  SpeedTest
//
//  Created by admin on 5/18/24.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var saveLocationBtn: UIButton!
    
    let locationManager = CLLocationManager()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        configureSaveLocationBtn()
        checkLocationServices()
        populateTestResults()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkLocationServices()
        populateTestResults()
    }
    
    func configureSaveLocationBtn() {
        saveLocationBtn.backgroundColor = .white
        saveLocationBtn.layer.borderColor = saveLocationBtn.tintColor.cgColor
        saveLocationBtn.layer.borderWidth = 2
        saveLocationBtn.layer.cornerRadius = saveLocationBtn.bounds.height/2
        saveLocationBtn.addTarget(self, action: #selector(saveCustomLocationTapped), for: .touchUpInside)
    }
    
    @objc func saveCustomLocationTapped() {
        // get current location long and lat
        guard let currentLocation = locationManager.location?.coordinate else { return }
        var savedLocationsWithin100Meters = [String]()
        if let customLocations = fetchSavedCustomLocationsFromCoreData() {
            for location in customLocations {
                let customCLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                let currentCLLocation = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
                // TODO: change to 100 meters
                if customCLLocation.distance(from: currentCLLocation) <= 100000 {  // check if current location within 100 meters of each custom location
                    savedLocationsWithin100Meters.append(location.locationName!)
                }
            }
            if !savedLocationsWithin100Meters.isEmpty {
                savedLocationsWithin100Meters.sort()
                let inRangeLocationsAlert = UIAlertController(title: "Save Location", message: "Is current location any one of these already saved custom locations?", preferredStyle: .actionSheet)
                inRangeLocationsAlert.addAction(UIAlertAction(title: "Save New Location", style: .cancel, handler: { action in
                    self.saveNewCustomLocation(location: currentLocation)
                }))
                for location in savedLocationsWithin100Meters {
                    inRangeLocationsAlert.addAction(UIAlertAction(title: location, style: .default, handler: { action in
                        print("Selected \(String(describing: location))")
                    }))
                }
                present(inRangeLocationsAlert, animated: true)
            } else {
                saveNewCustomLocation(location: currentLocation)
            }
        }
        // alert asking if this falls under any existing custom locations - if yes do nothing (for now)
            // if not add custom location
            // TODO: group together with other existing locations if
            // TODO: in SpeedTestVC - ask if to add to any custom locations ONLY IF within existing custom locations inside 100 meters
    }
    func saveNewCustomLocation(location: CLLocationCoordinate2D) {
        let newCustomLocation = CustomLocationModel(context: context)
        newCustomLocation.latitude = location.latitude
        newCustomLocation.longitude = location.longitude
        let newLocationAlert = UIAlertController(title: "Save Custom Location", message: "Provide name for new custom location", preferredStyle: .alert)
        newLocationAlert.addTextField()
        newLocationAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] action in
            newCustomLocation.locationName = newLocationAlert.textFields?.first?.text
            do {
                try self?.context.save()
            } catch {
                print("Error while saving: \(error)")
            }
        }))
        newLocationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(newLocationAlert, animated: true)
    }
    
    func fetchSavedCustomLocationsFromCoreData() -> [CustomLocationModel]?{
        do {
            let allSavedLocations = try context.fetch(CustomLocationModel.fetchRequest()) as? [CustomLocationModel]
            return allSavedLocations
        } catch {
            print("Error while fetching saved custom locations from Core Data: \(error)")
            return nil
        }
    }
    
    @objc func applicationWillEnterForeground(){
//        checkLocationServices()
    }
    
    func populateTestResults() {
        DispatchQueue.main.async { [weak self] in
            guard let testVC = self?.tabBarController?.viewControllers?.first(where: { $0 is SpeedTestVC }) as? SpeedTestVC else { return }
            //        let testVC = SpeedTestVC()
            testVC.fetchSpeedTestResultsFromCoreData { [weak self] results in
                //TODO: add results annotations
                guard let results = results else { return }
                for result in results {
                    if let date = result.date?.formatted(Date.FormatStyle(date: .abbreviated)),
                       let time = result.date?.formatted(Date.FormatStyle(time: .shortened)) {
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude)
                        annotation.title = "\(result.county ?? String("No County"))" + "\n\(date)" + "\n\(time)"
                        annotation.subtitle = "DL: \(result.downloadSpeedMbps.rounded(.towardZero))Mbps\nUL: \(result.uploadSpeedMbps.rounded(.up))Mbps"
                        self?.mapView.addAnnotation(annotation)
                    }
                }
            } onFailure: { error in
                //TODO: show error alert
                let alert = UIAlertController(title: "Fetch Results Error", message: "An error occurred while fetching your results history. Please try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok.", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = kCLDistanceFilterNone
        
    }
    
    func checkLocationServices() {
        DispatchQueue.global().async { [weak self] in
            guard CLLocationManager.locationServicesEnabled()  else {
                // alert that need to enable location services on device
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services in settings to see updated test results.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok.", style: .default))
                    self?.present(alert, animated: true)
                }
                return
            }
            self?.setupLocationManager()
            self?.checkLocationAuthorization()
        }
    }
    
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true    // shows location but not zoomed in
            DispatchQueue.main.async {
                if let location = self.locationManager.location {
                    self.mapView.setCenter(location.coordinate, animated: true)
                    self.centerViewOnUserLocation()
                    self.locationManager.startUpdatingLocation()
                    self.mapView.showsUserTrackingButton = true
                }
            }
            break
        case .denied:
            // TODO: alert that will need to turn on location auth to use app and how to turn on
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            // TODO: show alert that restriction in place
            break
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            break
        default:
            break
        }
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 2000, longitudinalMeters: 2000)
            mapView.setRegion(region, animated: true)
        }
    }
}

// MARK: - MKMapViewDelegate
extension MapVC: MKMapViewDelegate {
    
//    func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
//        if let location = locationManager.location?.coordinate {
//            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 50, longitudinalMeters: 50)
//            mapView.setRegion(region, animated: true)
//        }
//    }
//    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
//        let identifier = "test-result"
//            var view: MKMarkerAnnotationView
//            // 4
//            if let dequeuedView = mapView.dequeueReusableAnnotationView(
//              withIdentifier: identifier) as? MKMarkerAnnotationView {
//              dequeuedView.annotation = annotation
//              view = dequeuedView
//            } else {
//              // 5
//              view = MKMarkerAnnotationView(
//                annotation: annotation,
//                reuseIdentifier: identifier)
//              view.canShowCallout = true
//              view.calloutOffset = CGPoint(x: -5, y: 5)
//              view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//            }
//            return view
//    }
}

// MARK: - CLLocationManagerDelegate
extension MapVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //TODO
//        guard let location = locations.last else { return }
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: 1000, longitudinalMeters: 1000)
//        mapView.setRegion (region, animated: true)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationServices()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        guard let clError = error as? CLError else {
            print("Core Location error")
            return
        }
        switch clError.code{
        case .locationUnknown:
            print("Unknown location.")
        case .denied:
            print("Location access denied.")
        case .network:
            print("Network error.")
        case .headingFailure:
            print("Heading failure.")
        case .regionMonitoringDenied:
            print("Region monitoring denied.")
        case .regionMonitoringFailure:
            print("Region monitoring failure.")
        case .regionMonitoringSetupDelayed:
            print("Region monitoring setup delayed.")
        case .regionMonitoringResponseDelayed:
            print("Region monitoring response delayed.")
        case .geocodeFoundNoResult:
            print("Geocode found no result.")
        case .geocodeFoundPartialResult:
            print("Geocode found partial result.")
        case .geocodeCanceled:
            print("Geocode cancelled.")
        case .deferredFailed:
            print("Deferred location updates failed.")
        default:
            print("Location error: \(clError.localizedDescription)")
        }
    }
}
