//
//  File.swift
//  
//
//  Created by Josip Hranić on 01.10.2021..
//

import UIKit
import SnapKit

public enum InfoViewStatus {
    case info(String)
    case warning(String)
}

public class InfoView: UIView {
    
    private let iconImageView = UIImageView()
    private let messageLabel = UILabel()
    private var status: InfoViewStatus?
    
    public init() {
        super.init(frame: .zero)
        addSubviews()
        makeConstraints()
        setupViews()
        setupLabels()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public methods
public extension InfoView {
    
    func update(_ status: InfoViewStatus) {
        self.status = status
        updateLabels()
        updateImageViews()
        updateBackgroundColor()
    }
}

// MARK: - Private methods
private extension InfoView {
    
    func addSubviews() {
        addSubview(iconImageView)
        addSubview(messageLabel)
    }
    
    func makeConstraints() {
        iconImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
            $0.height.equalToSuperview().multipliedBy(0.4)
            $0.width.equalTo(iconImageView.snp.height)
        }
        messageLabel.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview()
            $0.leading.equalTo(iconImageView.snp.trailing).offset(5)
        }
    }

    func setupLabels() {
        messageLabel.adjustsFontSizeToFitWidth = true
        messageLabel.textAlignment = .center
    }
    
    func setupImageViews() {
        iconImageView.contentMode = .scaleAspectFit
    }
    
    func setupViews() {
        backgroundColor = .lightGray.withAlphaComponent(0.7)
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .init(width: 3, height: 3)
        layer.shadowOpacity = 0.7
        layer.shadowRadius = 4
    }
    
    func updateImageViews() {
        guard let status = status else {
            return
        }
        switch status {
        case .info( _):
            iconImageView.image = .info
        case .warning( _):
            iconImageView.image = .warning
        }
    }
    
    func updateLabels() {
        guard let status = status else {
            return
        }
        switch status {
        case .info(let message):
            messageLabel.text = message
        case .warning(let message):
            messageLabel.text = message
        }
    }
    
    func updateBackgroundColor() {
        guard let status = status else {
            return
        }
        switch status {
        case .info( _):
            backgroundColor = .darkBlue.withAlphaComponent(0.4)
        case .warning( _):
            backgroundColor = .darkYellow.withAlphaComponent(0.4)
        }
    }
}
