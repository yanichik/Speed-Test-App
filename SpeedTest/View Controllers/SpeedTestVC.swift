//
//  SpeedTestVC.swift
//  SpeedTest
//
//  Created by admin on 5/14/24.
//

import UIKit
import SpeedcheckerSDK
import SpeedcheckerReportSDK
import CoreLocation
import CoreData

class SpeedTestVC: UIViewController {
    
    @IBOutlet weak var runSpeedTestBtn: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    var stopBtn = UIButton()
    let downloadProgress = CircularProgressView(withType: "Download")
    let uploadProgress = CircularProgressView(withType: "Upload")
    
    private var internetTest: InternetSpeedTest?
    private var locationManager = CLLocationManager()
    private var signalHelper: SCSignalHelper?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var testResultsArray = Array<SpeedTestResultsModel>()
    
    let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.lightText.cgColor,
            UIColor.lightGray.cgColor
        ]
        return layer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.addSublayer(gradientLayer)   // First: added as sublayer
        gradientLayer.frame = view.bounds       // Second: frame set frame is pos & size relative to superlayer's coord space, & bounds are rel to it's own coord space
        runSpeedTestBtn.translatesAutoresizingMaskIntoConstraints = false
        runSpeedTestBtn.layer.zPosition = 1
        
        progressBar.isHidden = true
        
        configureDownloadProgressBar()
        configureUploadProgressBar()
        
        configureStopButton()
        
        requestLocationAuthorization()
    }
    
    //    override func viewDidLayoutSubviews() {
    //        super.viewDidLayoutSubviews()
    //
    //        gradientLayer.frame = view.bounds
    //    }
    
    func configureStopButton() {
        stopBtn.setTitle("Stop Current Test", for: .normal)
        stopBtn.addTarget(self, action: #selector(stopBtnTapped), for: .touchUpInside)
        stopBtn.translatesAutoresizingMaskIntoConstraints = false
        stopBtn.titleLabel?.font = UIFont(name: "TimesNewRomanPSMT", size: 24)
        stopBtn.setTitleColor(.red, for: .normal)
        view.addSubview(stopBtn)
        NSLayoutConstraint.activate([
            stopBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stopBtn.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -(view.frame.size.height/8))
        ])
        
    }
    
    @objc func stopBtnTapped() {
        internetTest?.forceFinish({ error in
            print(error)
        })
    }
    
    func configureDownloadProgressBar() {
        downloadProgress.translatesAutoresizingMaskIntoConstraints = false
        downloadProgress.progressColor = UIColor.blue
        downloadProgress.trackColor = .systemMint
        view.addSubview(downloadProgress)
        
        // Uses Auto Layout to setup size and location
        NSLayoutConstraint.activate([
            downloadProgress.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -(view.frame.size.width/4)),
            downloadProgress.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            downloadProgress.widthAnchor.constraint(equalToConstant: 125),
            downloadProgress.heightAnchor.constraint(equalToConstant: 125)
        ])
        
        // Uses Frame to setup size and location
        //        downloadProgress.frame.size.width = 125
        //        downloadProgress.frame.size.height = 125
        //        downloadProgress.center = self.view.center
    }
    
    func configureUploadProgressBar() {
        uploadProgress.translatesAutoresizingMaskIntoConstraints = false
        uploadProgress.progressColor = UIColor.blue
        uploadProgress.trackColor = .systemMint
        view.addSubview(uploadProgress)
        
        // Uses Auto Layout to setup size and location
        NSLayoutConstraint.activate([
            uploadProgress.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: (view.frame.size.width/4)),
            uploadProgress.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            uploadProgress.widthAnchor.constraint(equalToConstant: 125),
            uploadProgress.heightAnchor.constraint(equalToConstant: 125)
        ])
        
        // Uses Frame to setup size and location
        //        uploadProgress.frame.size.width = 125
        //        uploadProgress.frame.size.height = 125
        //        uploadProgress.center = self.view.center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        downloadProgress.speedLabel.isHidden = true
    }
    
    @IBAction func runSpeedTestTouched(_ sender: UIButton) {
        // to use free version, your app should have location access
        internetTest = InternetSpeedTest(delegate: self)
        internetTest?.startFreeTest() { (error) in
            if error != .ok {
                print("Error: \(error.rawValue)")
            }
        }
        signalHelper = SCSignalHelper()
        let signalStrength = signalHelper?.getSignalStrengh()
        print("signalStrength: \(String(describing: signalStrength?.wiFiStrength?.convertToDB() ?? 0))")
    }
    
    func phaseOutProgressBars() {
        var timeLeft = CGFloat(0)
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
            DispatchQueue.main.async {
                self?.downloadProgress.progress = CGFloat(1/timeLeft)
                self?.uploadProgress.progress = CGFloat(1/timeLeft)
            }
            timeLeft += 1
            if(timeLeft==100){
                DispatchQueue.main.async {
                    self?.downloadProgress.progress = CGFloat(0)
                    self?.uploadProgress.progress = CGFloat(0)
                }
                timer.invalidate()
            }
        }
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
// MARK: - InternetSpeedTestResult Server
extension SpeedTestVC {
    struct InternetSpeedTestResult {
        let server: SpeedcheckerSDK.SpeedTestServer
    }
}

// MARK: - InternetSpeedTestResult Core Data
extension SpeedTestVC {
    func addSpeedTestResultsToCoreData(latitude: Double, longitude: Double, downloadSpeed: Double, uploadSpeed: Double){
        let newResult = SpeedTestResultsModel(context: context)
        newResult.latitude = latitude
        newResult.longitude = longitude
        newResult.downloadSpeedMbps = downloadSpeed
        newResult.uploadSpeedMbps = uploadSpeed
        do {
            try context.save()
        } catch {
            print("Data saving error: \(error)")
        }
    }
    
    func fetchSpeedTestResultsFromCoreData(onSuccess: @escaping ([SpeedTestResultsModel]?) -> Void, onFailure: @escaping (Error) -> Void){
        do {
            let allResults = try context.fetch(SpeedTestResultsModel.fetchRequest()) as? [SpeedTestResultsModel]
            onSuccess(allResults)
        } catch {
            print("Data fetching error: \(error)")
            onFailure(error)
        }
    }
    
//    func deleteSpeedTestResultFromCoreData
}


// MARK: - InternetSpeedTestDelegate
extension SpeedTestVC: InternetSpeedTestDelegate {
    func internetTestError(error: SpeedTestError) {
        print("Error: \(error.rawValue)")
    }
    
    func internetTestFinish(result: SpeedTestResult) {
    addSpeedTestResultsToCoreData(latitude: result.locationLatitude, longitude: result.locationLongitude, downloadSpeed: result.downloadSpeed.mbps, uploadSpeed: result.uploadSpeed.mbps)
//        print(result.downloadSpeed.mbps)
//        print(result.uploadSpeed.mbps)
//        print(result.latencyInMs)
        
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
        downloadProgress.progress = progress
        print("downloadProgress.progress = \(progress)")
        //        downloadProgress.speedLabel.text = "\(Int(speed.mbps)) Mbps"
        downloadProgress.speed = Int(speed.mbps)
        print("Download: \(speed.descriptionInMbps)")
    }
    
    func internetTestUploadStart() {
        //
    }
    
    func internetTestUploadFinish() {
        phaseOutProgressBars()
    }
    
    func internetTestUpload(progress: Double, speed: SpeedTestSpeed) {
        uploadProgress.progress = progress
        print("uploadProgress.progress = \(progress)")
        //        uploadProgress.speedLabel.text = "\(Int(speed.mbps)) Mbps"
        uploadProgress.speed = Int(speed.mbps)
        print("Upload: \(speed.descriptionInMbps)")
    }
}
// MARK: - CLLocationManagerDelegate
extension SpeedTestVC: CLLocationManagerDelegate {
}
