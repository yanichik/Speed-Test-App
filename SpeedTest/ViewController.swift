//
//  ViewController.swift
//  SpeedTest
//
//  Created by admin on 5/14/24.
//

import UIKit
import SpeedcheckerSDK
import SpeedcheckerReportSDK
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var runSpeedTestBtn: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    let circularProgressBar = CircularProgressView()
    
    private var internetTest: InternetSpeedTest?
    private var locationManager = CLLocationManager()
    private var signalHelper: SCSignalHelper?
    
    let gradientLayer: CAGradientLayer = {
            let layer = CAGradientLayer()
            layer.colors = [
                UIColor.red.cgColor,
                UIColor.green.cgColor
            ]
            return layer
        }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        view.layer.addSublayer(gradientLayer)
//        gradientLayer.frame = view.bounds
        runSpeedTestBtn.translatesAutoresizingMaskIntoConstraints = false
        runSpeedTestBtn.layer.zPosition = 1
        
        progressBar.isHidden = true
        
//        circularProgressBar.translatesAutoresizingMaskIntoConstraints = false
        circularProgressBar.progressColor = UIColor.blue
        circularProgressBar.trackColor = .systemMint
        view.addSubview(circularProgressBar)
//        NSLayoutConstraint.activate([
//            circularProgressBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            circularProgressBar.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            circularProgressBar.widthAnchor.constraint(equalToConstant: 125),
//            circularProgressBar.heightAnchor.constraint(equalToConstant: 125)
//        ])
        circularProgressBar.frame.size.width = 125
        circularProgressBar.frame.size.height = 125
        circularProgressBar.center = self.view.center
        

        requestLocationAuthorization()
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        
//        gradientLayer.frame = view.bounds
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        circularProgressBar.speedLabel.isHidden = true
    }

    @IBAction func runSpeedTestTouched(_ sender: UIButton) {
        // to use free version, your app should have location access
        internetTest = InternetSpeedTest(delegate: self)
        internetTest?.startFreeTest() { (error) in
            if error != .ok {
                print("Error: \(error.rawValue)")
            }
        }
        
        // to use paid version, your app does not need location access
//        internetTest = InternetSpeedTest(licenseKey: "Your license key", delegate: self)
//        internetTest?.start() { (error) in
//          if error != .ok {
//              print("Error: \(error.rawValue)")
//          }
//        }
        signalHelper = SCSignalHelper()
        let signalStrength = signalHelper?.getSignalStrengh()
        print("signalStrength: \(String(describing: signalStrength?.wiFiStrength?.convertToDB() ?? 0))")
    }
    
    func requestLocationAuthorization() {
        DispatchQueue.global().async {
            guard CLLocationManager.locationServicesEnabled() else {
                return
            }
            DispatchQueue.main.async { [weak self] in
                self?.locationManager.delegate = self
                self?.locationManager.requestWhenInUseAuthorization()
                self?.locationManager.requestAlwaysAuthorization()
            }
        }
    }
    
}

extension ViewController: InternetSpeedTestDelegate {
    func internetTestError(error: SpeedTestError) {
        print("Error: \(error.rawValue)")
    }
    
    func internetTestFinish(result: SpeedTestResult) {
        print(result.downloadSpeed.mbps)
        print(result.uploadSpeed.mbps)
        print(result.latencyInMs)
        
    }
    
    func internetTestReceived(servers: [SpeedTestServer]) {
        print(servers)
    }
    
    func internetTestSelected(server: SpeedTestServer, latency: Int, jitter: Int) {
        print("Latency: \(latency)")
        print("Jitter: \(jitter)")
    }
    
    func internetTestDownloadStart() {
        //
    }
    
    func internetTestDownloadFinish() {
        //
    }
    
    func internetTestDownload(progress: Double, speed: SpeedTestSpeed) {
//        progressBar.progress = Float(progress)
        circularProgressBar.progressLayer.strokeEnd = progress
        print("circularProgressBar.progressLayer.strokeEnd = \(progress)")
//        circularProgressBar.speedLabel.text = "\(Int(speed.mbps)) Mbps"
        circularProgressBar.speed = Int(speed.mbps)
        print("Download: \(speed.descriptionInMbps)")
    }
    
    func internetTestUploadStart() {
        //
    }
    
    func internetTestUploadFinish() {
        //
    }
    
    func internetTestUpload(progress: Double, speed: SpeedTestSpeed) {
        print("Upload: \(speed.descriptionInMbps)")
    }
}

extension ViewController: CLLocationManagerDelegate {
}
