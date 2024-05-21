//
//  MapVC.swift
//  SpeedTest
//
//  Created by admin on 5/18/24.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        checkLocationServices()
        populateTestResults()

        // Do any additional setup after loading the view.
    }
    
    func populateTestResults() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 37.224310, longitude: -121.773916)
        annotation.title = "Sample Test Result"
        annotation.subtitle = "DL: 100Mbps\nUL: 40Mbps"
        mapView.addAnnotation(annotation)
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
                return
            }
            self?.setupLocationManager()
            self?.checkLocationAuthorization()
        }
    }
    
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            // TODO: do map stuff
//            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true    // shows location but not zoomed in
//            DispatchQueue.main.async {
                if let location = self.locationManager.location {
                    self.mapView.setCenter(location.coordinate, animated: true)
                    self.centerViewOnUserLocation()
                    self.locationManager.startUpdatingLocation()
                }
//            }
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
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 10000, longitudinalMeters: 10000)
            mapView.setRegion(region, animated: true)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - CLLocationManagerDelegate
extension MapVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //TODO
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion (region, animated: true)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationServices()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
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
