//
//  CircularProgressView.swift
//  SpeedTest
//
//  Created by Yan Brunshteyn on 5/15/24.
//

import UIKit

class CircularProgressView: UIView {
    
    var progressLayer = CAShapeLayer()
    var trackLayer = CAShapeLayer()
    var speedLabel = UILabel()
    var progressLabel = UILabel()
    var uploadDownloadLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSpeedLabel()
        configureProgressLabel()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    convenience init(withType type: String) {
        self.init()
        configureUploadDownloadLabel(withType: type)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        createCircularPath()
    }
    
    func configureUploadDownloadLabel(withType type: String) {
        uploadDownloadLabel = UILabel()
        uploadDownloadLabel.translatesAutoresizingMaskIntoConstraints = false
        uploadDownloadLabel.text = type
        let fontDescriptor = UIFontDescriptor(name: "SFUI", size: 0)
        uploadDownloadLabel.font = UIFont(descriptor: fontDescriptor, size: 26)
        uploadDownloadLabel.textColor = UIColor.black
        uploadDownloadLabel.isOpaque = true
        self.addSubview(uploadDownloadLabel)
        NSLayoutConstraint.activate([
            uploadDownloadLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            uploadDownloadLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: -35)
        ])
    }
    
    var progressColor = UIColor.white {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    var trackColor = UIColor.white {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    var speed = 0 {
        didSet {
            speedLabel.text = String(speed) + " Mbps"
        }
    }
    
    var progress = 0.0 {
        didSet {
            progressLayer.strokeEnd = progress
            progressLabel.text = String(format: "%.0f", (progress*100).rounded()) + "%"
        }
    }
    
    fileprivate func configureSpeedLabel() {
        speedLabel.translatesAutoresizingMaskIntoConstraints = false
        speedLabel.text = String(speed) + " Mbps"
        let fontDescriptor = UIFontDescriptor(name: "SFUI", size: 0)
        speedLabel.font = UIFont(descriptor: fontDescriptor, size: 24)
        speedLabel.textColor = UIColor.black
        speedLabel.isOpaque = true
        self.addSubview(speedLabel)
        NSLayoutConstraint.activate([
            speedLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            speedLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    fileprivate func configureProgressLabel() {
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.text = String(format: "%.0f", (progress*100).rounded()) + "%"
        let fontDescriptor = UIFontDescriptor(name: "SFUI", size: 0)
        progressLabel.font = UIFont(descriptor: fontDescriptor, size: 24)
        progressLabel.textColor = UIColor.black
        progressLabel.isOpaque = true
        self.addSubview(progressLabel)
        NSLayoutConstraint.activate([
            progressLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            progressLabel.topAnchor.constraint(equalTo: self.bottomAnchor, constant: 10)
        ])
    }
    fileprivate func createCircularPath() {
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = self.frame.width/2
        let path = UIBezierPath(arcCenter: CGPoint(x: frame.width/2, y: frame.height/2), radius: (frame.width - 1.5)/2, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)
        trackLayer.path = path.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.opacity = 0.5
        trackLayer.lineWidth = 10.0
        trackLayer.strokeEnd = 1.0
        self.layer.addSublayer(trackLayer)

        progressLayer.path = path.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = 10.0
        progressLayer.strokeEnd = 0.0
        self.layer.addSublayer(progressLayer)
    }

}
