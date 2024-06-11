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
    
    var mapAnnotations = [CustomPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.register(CustomTestResultClusterView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        mapView.register(CustomPointAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        configureSaveLocationBtn()
        checkLocationServices()
        populateTestResults() { [weak self] annotations in
            guard let receivedAnnotations = annotations else { return }
            self?.mapAnnotations.append(contentsOf: receivedAnnotations)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkLocationServices()
        rePopulateTestResultsIfNeed()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rePopulateTestResultsIfNeed()
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
                if let locationName = location.locationName {
                    let customCLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                    let currentCLLocation = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
                    // TODO: change to 100 meters
                    if customCLLocation.distance(from: currentCLLocation) <= 100000 {  // check if current location within 100 meters of each custom location
                        savedLocationsWithin100Meters.append(locationName)
                    }
                }
            }
            if !savedLocationsWithin100Meters.isEmpty {
                savedLocationsWithin100Meters.sort()
                let inRangeLocationsAlert = UIAlertController(title: "Save Location", message: "Is current location any one of these already saved custom locations?", preferredStyle: .actionSheet)
                inRangeLocationsAlert.addAction(UIAlertAction(title: "Save New Location", style: .cancel, handler: { action in
                    self.saveNewCustomLocation(location: currentLocation, completion: nil)
                }))
                for location in savedLocationsWithin100Meters {
                    inRangeLocationsAlert.addAction(UIAlertAction(title: location, style: .default, handler: { action in
//                        print("Selected \(String(describing: location))")
                    }))
                }
                present(inRangeLocationsAlert, animated: true)
            } else {
                saveNewCustomLocation(location: currentLocation, completion: nil)
            }
        }
        // alert asking if this falls under any existing custom locations - if yes do nothing (for now)
            // if not add custom location
            // TODO: group together with other existing locations if
            // TODO: in SpeedTestVC - ask if to add to any custom locations ONLY IF within existing custom locations inside 100 meters
    }
    func saveNewCustomLocation(location: CLLocationCoordinate2D, completion: ( (String) -> Void)? ) {
        let newCustomLocation = CustomLocationModel(context: context)
        newCustomLocation.latitude = location.latitude
        newCustomLocation.longitude = location.longitude
        let newLocationAlert = UIAlertController(title: "Save Custom Location", message: "Provide name for new custom location", preferredStyle: .alert)
        newLocationAlert.addTextField()
        newLocationAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] action in
            newCustomLocation.locationName = newLocationAlert.textFields?.first?.text
            do {
                try self?.context.save()
                completion?(newCustomLocation.locationName ?? "")
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
    
    func populateTestResults(completion: @escaping ([CustomPointAnnotation]?) -> Void){
        var customPointAnnotations = [CustomPointAnnotation]()
        DispatchQueue.main.async { [weak self] in
            guard let testVC = self?.tabBarController?.viewControllers?.first(where: { $0 is SpeedTestVC }) as? SpeedTestVC else { return }
            //        let testVC = SpeedTestVC()
            testVC.fetchSpeedTestResultsFromCoreData { [weak self] results in
                //TODO: add results annotations
                guard let fetchResults = results else { return }
//                var annotationViews = [CustomTestResultClusterView]()
                var pointAnnotations = [String:[CustomPointAnnotation]]()
                for result in fetchResults {
                    if let _ = result.date?.formatted(Date.FormatStyle(date: .abbreviated)),
                       let _ = result.date?.formatted(Date.FormatStyle(time: .shortened)) {
                        let annotation = CustomPointAnnotation(latitude: result.latitude, longitude: result.longitude)
//                        annotation.coordinate = CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude)
                        annotation.title = "\(result.savedLocationName ?? String("NA"))" // + "\n\(date)" + "\n\(time)"
//                        let annotationView = CustomTestResultClusterView(annotation: annotation, reuseIdentifier: annotation.title)
                        annotation.subtitle = "DL: \(result.downloadSpeedMbps.rounded(.towardZero))Mbps\nUL: \(result.uploadSpeedMbps.rounded(.up))Mbps"
                        if let name = result.savedLocationName {
                            if pointAnnotations.contains(where: { (key: String, value: [CustomPointAnnotation]) in
                                return key == name
                            }){
                                pointAnnotations[name]?.append(annotation)
                            } else {
                                pointAnnotations[name] = [annotation]
                            }
                        } else {
                            self?.mapView.addAnnotation(annotation)
                            customPointAnnotations.append(annotation)
                        }
                    }
                }
                for (_, annotations) in pointAnnotations {
//                    for annotation in annotations {
//                        let clusterView = CustomTestResultClusterView(annotation: annotation, reuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
//                        annotationViews.append(clusterView)
//                    }
                    self?.mapView.addAnnotations(annotations)
                    customPointAnnotations.append(contentsOf: annotations)
                }
                completion(customPointAnnotations)
//                self?.mapView.addAnnotations(annotationViews)
            } onFailure: { error in
                //TODO: show error alert
                let alert = UIAlertController(title: "Fetch Results Error", message: "An error occurred while fetching your results history. Please try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok.", style: .default))
                self?.present(alert, animated: true)
                completion(nil)
            }
        }
    }
    
    func rePopulateTestResultsIfNeed() {
//        currentAnnotations array in class level
//        pull
        guard mapAnnotations != nil else { return }
        guard let testVC = tabBarController?.viewControllers?.first(where: { $0 is SpeedTestVC }) as? SpeedTestVC else { return }
        testVC.fetchSpeedTestResultsFromCoreData { [weak self] results in
            guard let fetchResults = results else { return }
            if fetchResults.count != self?.mapAnnotations.count {
                guard let annotations = self?.mapView.annotations else
                { return }
                self?.mapView.removeAnnotations(annotations)
                self?.mapAnnotations.removeAll()
                self?.populateTestResults() { [weak self] annotations in
                    guard let receivedAnnotations = annotations else { return }
                    self?.mapAnnotations.append(contentsOf: receivedAnnotations)
                }
            }
        } onFailure: { error in
            //TODO: show error alert
            let alert = UIAlertController(title: "Fetch Results Error", message: "An error occurred while fetching your results history. Please try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok.", style: .default))
            self.present(alert, animated: true)
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
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        print("current annotation being dropped is: \(annotation.description)")
        guard !(annotation is MKUserLocation) else { return nil } // If MKUserLocation type then will use default user location annotation
        
        // Unwrap the double optional `title` to a single optional.
        guard let title = annotation.title ?? nil else { return nil }
        let clusteringID = title
        switch annotation {
        case is CustomPointAnnotation:
            guard let view = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier) as? CustomPointAnnotationView else {
                return CustomPointAnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
            }
            view.annotation = annotation
            view.clusteringIdentifier = clusteringID
            return view
        case is MKClusterAnnotation:
//            guard let view = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier, for: annotation) as? CustomTestResultClusterView else {
                return CustomTestResultClusterView(annotation: annotation, reuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
//            }
//            view.clusteringIdentifier = clusteringID
//            return view
        default:
            return nil
        }
    }
    
//    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [any MKAnnotation]) -> MKClusterAnnotation {
//        <#code#>
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
