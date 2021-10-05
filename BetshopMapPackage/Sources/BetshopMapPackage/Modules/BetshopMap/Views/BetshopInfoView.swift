//
//  File.swift
//  
//
//  Created by Josip Hranić on 25.09.2021..
//

import UIKit
import CommonUIPackage
import RxSwift

class BetshopInfoView: UIView {
    
    private let nameLabel = UILabel()
    private let addressLabel = UILabel()
    private let cityLabel = UILabel()
    private let countyLabel = UILabel()
    private let workingHoursLabel = UILabel()
    private let pinImageView = UIImageView()
    private let routeButton = UIButton()
    private let closeButton = UIButton()
    private var betshop: BetshopMapModel?
    
    init() {
        super.init(frame: .zero)
        addSubviews()
        setupView()
        setupImageViews()
        setupButtons()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public properties
extension BetshopInfoView {
    
    var closeTap: Observable<()> {
        closeButton.rx.tap.asObservable()
    }
    
    var routeTap: Observable<BetshopMapModel> {
        routeButton.rx.tap.compactMap { [unowned self] in betshop }
    }
}

// MARK: - Public methods
extension BetshopInfoView {
    
    func update(betshop: BetshopMapModel) {
        self.betshop = betshop
        updateLabels()
    }
}

// MARK: - Private methods
private extension BetshopInfoView {
    
    func addSubviews() {
        addSubview(nameLabel)
        addSubview(addressLabel)
        addSubview(cityLabel)
        addSubview(countyLabel)
        addSubview(workingHoursLabel)
        addSubview(pinImageView)
        addSubview(routeButton)
        addSubview(closeButton)
    }
    
    func setupImageViews() {
        pinImageView.image = .greenPin
        closeButton.setImage(.closeIcon, for: .normal)
    }
    
    func setupView() {
        backgroundColor = .white
        layer.cornerRadius = 10
        layer.shadowRadius = 5
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.7
    }
    
    func setupButtons() {
        routeButton.setTitle("Route", for: .normal)
        routeButton.setTitleColor(.black, for: .normal)
        routeButton.backgroundColor = .gray.withAlphaComponent(0.6)
        routeButton.layer.cornerRadius = 5
    }
    
    func makeConstraints() {
        pinImageView.snp.makeConstraints {
            $0.leading.top.equalToSuperview().inset(10)
            $0.width.equalTo(10)
            $0.height.equalTo(15)
        }
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(pinImageView)
            $0.leading.equalTo(pinImageView.snp.trailing).offset(5)
            $0.trailing.lessThanOrEqualTo(closeButton.snp.leading).offset(-5)
        }
        addressLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(nameLabel)
            $0.top.equalTo(nameLabel.snp.bottom).offset(5)
            $0.trailing.lessThanOrEqualTo(closeButton.snp.leading).offset(-5)
        }
        cityLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel)
            $0.top.equalTo(addressLabel.snp.bottom).offset(5)
        }
        countyLabel.snp.makeConstraints {
            $0.top.equalTo(cityLabel)
            $0.leading.equalTo(cityLabel.snp.trailing).offset(5)
            $0.trailing.lessThanOrEqualTo(closeButton.snp.leading).offset(-5)
        }
        workingHoursLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel)
            $0.top.equalTo(countyLabel.snp.bottom).offset(15)
            $0.bottom.lessThanOrEqualToSuperview()
        }
        routeButton.snp.makeConstraints {
            $0.leading.greaterThanOrEqualTo(workingHoursLabel.snp.trailing)
            $0.bottom.equalTo(workingHoursLabel)
            $0.trailing.equalTo(closeButton.snp.leading)
            $0.top.greaterThanOrEqualToSuperview()
            $0.width.equalTo(100)
        }
        closeButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(10)
            $0.width.height.equalTo(25)
        }
    }
    
    func updateLabels() {
        guard let betshop = betshop else {
            return
        }
        nameLabel.text = betshop.name
        addressLabel.text = betshop.address
        cityLabel.text = betshop.city
        countyLabel.text = betshop.county
        workingHoursLabel.text = isCurrentlyOpen() ? "Open now until 16:00" : "Opens tomorrow at 08:00"
    }
    
    func isCurrentlyOpen() -> Bool {
        let calendar = Calendar.current
        let startTimeComponent = DateComponents(calendar: calendar, hour:08)
        let endTimeComponent   = DateComponents(calendar: calendar, hour: 16)
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        guard let openingHours = calendar.date(byAdding: startTimeComponent, to: startOfToday),
              let closingHours = calendar.date(byAdding: endTimeComponent, to: startOfToday) else {
            return false
        }
        
        return openingHours <= now && now < closingHours
    }
}
