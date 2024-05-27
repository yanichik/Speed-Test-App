//
//  MapVC.swift
//  SpeedTest
//
//  Created by admin on 5/18/24.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
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
                        annotation.title = date + "\n\(time)"
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
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
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
