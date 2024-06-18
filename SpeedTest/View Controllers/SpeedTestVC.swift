//
//  SpeedTestVC.swift
//  SpeedTest
//
//  Created by Yan Brunshteyn on 5/14/24.
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
    var currentTestResult: SpeedTestResultsModel?
    
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
            print(error.rawValue)
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
//        let signalStrength = signalHelper?.getSignalStrengh()
//        print("signalStrength: \(String(describing: signalStrength?.wiFiStrength?.convertToDB() ?? 0))")
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
    func addSpeedTestResultsToCoreData(latitude: Double, longitude: Double, downloadSpeed: Double, uploadSpeed: Double) -> SpeedTestResultsModel{
        let newResult = SpeedTestResultsModel(context: context)
        newResult.latitude = latitude
        newResult.longitude = longitude
        newResult.downloadSpeedMbps = downloadSpeed
        newResult.uploadSpeedMbps = uploadSpeed
        newResult.date = Date()
        do {
            try context.save()
        } catch {
            print("Data saving error: \(error)")
        }
        return newResult
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
    // TODO: add
    // func deleteSpeedTestResultFromCoreData
}


// MARK: - InternetSpeedTestDelegate
extension SpeedTestVC: InternetSpeedTestDelegate {
    func internetTestError(error: SpeedTestError) {
        print("Error: \(error.rawValue)")
    }
    
    func internetTestFinish(result: SpeedTestResult) {
        DispatchQueue.main.async { [weak self] in
            guard let addedTestResult = self?.addSpeedTestResultsToCoreData(latitude: result.locationLatitude, longitude: result.locationLongitude, downloadSpeed: result.downloadSpeed.mbps, uploadSpeed: result.uploadSpeed.mbps) else { return }
            self?.currentTestResult = addedTestResult
            let myLocation = CLLocation(latitude: result.locationLatitude, longitude: result.locationLongitude)
            NetworkManager.shared.getCountyFromCoordinates(location: myLocation) { [weak self] county in
                guard let county = county else {return}
                guard let mapVC = self?.tabBarController?.viewControllers?.first(where: {$0 is MapVC}) as? MapVC else { return }
                var savedLocationsWithin30Meters = [CustomLocationModel]()
                if let customLocations = mapVC.fetchSavedCustomLocationsFromCoreData() {
                    for customLocation in customLocations {
                        let customSavedCLLocation = CLLocation(latitude: customLocation.latitude, longitude: customLocation.longitude)
                        // If current location w/in 100m of existing custom saved location then alert asking if it's the location
                        if customSavedCLLocation.distance(from: myLocation) <= 100 {
                            savedLocationsWithin30Meters.append(customLocation)
                        }
                    }
                }
                if !savedLocationsWithin30Meters.isEmpty{
                    self?.isExistingLocationAlert(myLocation, savedLocationsWithin30Meters, mapVC, county: county, addedTestResult: addedTestResult)
                } else {
                    self?.saveNewLocationAlert(myLocation, mapVC, county: county, addedTestResult: addedTestResult)
                }
            }
        }
    }
    
    func isExistingLocationAlert(_ myLocation: CLLocation, _ savedLocations: [CustomLocationModel], _ passingVC: UIViewController, county: String, addedTestResult: SpeedTestResultsModel){
        let alert = UIAlertController(title: "Existing Location", message: "Are you currently at one of the nearby saved locations?", preferredStyle: .actionSheet)
        alert.isSpringLoaded = false
        for location in savedLocations {
            if let name = location.locationName {
                alert.addAction(UIAlertAction(title: name, style: .default, handler: { action in
                    // TODO: set savedLocationName
                    self.currentTestResult?.savedLocationName = action.title
                    do {
                        try self.context.save()
                    } catch {
                        print("Data saving error: \(error)")
                    }
                    self.checkForOutages(county)
                }))
            }
        }
        alert.addAction(UIAlertAction(title: "Please add this new custom location.", style: .default, handler: { action in
            self.saveNewLocationAlert(myLocation, passingVC, county: county, addedTestResult: addedTestResult)
        }))
        alert.addAction(UIAlertAction(title: "Don't add custom location", style: .cancel, handler: { action in
            self.checkForOutages(county)
        }))
        present(alert, animated: true)
    }
    
    func fetchSavedTestResultFromCoreData(savedResult: SpeedTestResultsModel) -> SpeedTestResultsModel?{
        let fetchTestResults = SpeedTestResultsModel.fetchRequest()
        fetchTestResults.predicate = NSPredicate(format: "date == %@", savedResult.date! as NSDate)
        let foundTestResult = try? context.fetch(fetchTestResults)
        if foundTestResult?.count == 1 {
            return foundTestResult![0]
        } else {
            return nil
        }
    }
    
    func checkForOutages(_ county: String) {
        let currentTimestamp = Int(Date().timeIntervalSince1970)
        let twoHoursBackTimestamp = currentTimestamp - 700000000
        NetworkManager.shared.getOutageScoreForEntity(searchString: county, entityType: .county, from: String(twoHoursBackTimestamp), until: String(currentTimestamp)) { scores in
            if let overall = scores?.overall {
                self.showOutageAlert(overall, county)
            }
        }
    }
    
    func saveNewLocationAlert(_ myLocation: CLLocation, _ passingVC: UIViewController, county: String, addedTestResult: SpeedTestResultsModel){
        let alert = UIAlertController(title: "Save Location", message: "Are you in \(county) County?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [weak self] action in
            addedTestResult.county = county
            if let mapVC = (self?.tabBarController?.viewControllers?.first(where: {$0 is MapVC}) as? MapVC) {
                mapVC.saveNewCustomLocation(location: myLocation.coordinate) { [weak self] name in
                    if let savedTestResult = self?.fetchSavedTestResultFromCoreData(savedResult: addedTestResult) {
                        savedTestResult.setValue(name.count > 0 ? name : nil, forKey: "savedLocationName")
                        do {
                            try self?.context.save()
                        } catch {
                            print("Data saving error: \(error)")
                        }
                    }
                    self?.checkForOutages(county)
                }
            } else {
                do {
                    try self?.context.save()
                } catch {
                    print("Data saving error: \(error)")
                }
                let currentTimestamp = Int(Date().timeIntervalSince1970)
                let twoHoursBackTimestamp = currentTimestamp - 700000000
                NetworkManager.shared.getOutageScoreForEntity(searchString: county, entityType: .county, from: String(twoHoursBackTimestamp), until: String(currentTimestamp)) { scores in
                    if let overall = scores?.overall {
                        self?.showOutageAlert(overall, county)
                    }
                }}
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default))
        present(alert, animated: true)
    }
    
    func showOutageAlert(_ overall: Double, _ county: String) {
        guard let formattedOverall = formatDouble(overall) else { return }
        let outageAlert = UIAlertController(title: "2-Hour Outage Alert", message: "", preferredStyle: .alert)
        outageAlert.message = "\(county) County has an Internet Outage Score of \(formattedOverall) that could be affecting your connectivity."
        outageAlert.addAction(UIAlertAction(title: "OK", style: .cancel))
        DispatchQueue.main.async { [weak self] in
            self?.present(outageAlert, animated: true)
        }
    }
    
    func formatDouble(_ num: Double) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = ","
        numberFormatter.maximumFractionDigits = 0
        return numberFormatter.string(from: NSNumber(value: num))
    }
    
    func internetTestReceived(servers: [SpeedTestServer]) {
    }
    
    func internetTestSelected(server: SpeedTestServer, latency: Int, jitter: Int) {
    }
    
    func internetTestDownloadStart() {
    }
    
    func internetTestDownloadFinish() {
    }
    
    func internetTestDownload(progress: Double, speed: SpeedTestSpeed) {
        downloadProgress.progress = progress
        downloadProgress.speed = Int(speed.mbps)
    }
    
    func internetTestUploadStart() {
    }
    
    func internetTestUploadFinish() {
        phaseOutProgressBars()
    }
    
    func internetTestUpload(progress: Double, speed: SpeedTestSpeed) {
        uploadProgress.progress = progress
        uploadProgress.speed = Int(speed.mbps)
    }
}
// MARK: - CLLocationManagerDelegate
extension SpeedTestVC: CLLocationManagerDelegate {
}
