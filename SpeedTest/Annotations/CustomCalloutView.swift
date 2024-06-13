//
//  CustomCalloutView.swift
//  SpeedTest
//
//  Created by Yan Brunshteyn on 6/12/24.
//

import UIKit

class CustomCalloutView: UIView {
    var annotation: CustomPointAnnotation

    init(annotation: CustomPointAnnotation) {
        self.annotation = annotation
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1

        // Title label
        let titleLabel = UILabel()
        titleLabel.text = annotation.title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        // Subtitle label
        let subtitleLabel = UILabel()
        subtitleLabel.text = annotation.subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 12) // Adjust the font size here
        subtitleLabel.numberOfLines = 0
        subtitleLabel.lineBreakMode = .byWordWrapping
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subtitleLabel)

        // Layout constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            subtitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            subtitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
        ])
    }
}
