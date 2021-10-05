//
//  File.swift
//  
//
//  Created by Josip Hranić on 21.09.2021..
//

import UIKit
import BasePackage
import CommonUIPackage
import SnapKit
import RxSwift
import RxRelay

class RootViewController: BaseViewController {

    private let viewModel: RootViewModel
    private let cloverImageView = UIImageView()
    private let animationEndRelay = PublishRelay<()>()
    
    init(viewModel: RootViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        addSubviews()
        setupImageView()
        setupViews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func bindViewModel() {
        let output = viewModel
            .transform(input: RootViewModelInput(anmationCompleted: animationEndRelay.asObservable()))
        startAnimation { [weak self] in self?.animationEndRelay.accept(()) }
        output
            .networkConnectionAvailable
            .skip(1)
            .subscribe(onNext: { [unowned self] in showInfoView(networkConnectionAvailable: $0) })
            .disposed(by: disposeBag)
    }
    
    override func viewDidDisappear(_ animated: Bool) {

    }
}

// MARK: - Private methods
private extension RootViewController {

    func addSubviews() {
        view.addSubview(cloverImageView)
    }
    
    func setupViews() {
        view.backgroundColor = .white
    }
    
    func setupImageView() {
        cloverImageView.image = .greenCloverPin
        cloverImageView.contentMode = .scaleAspectFit
    }
    
    func makeConstraints() {
        cloverImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(100)
        }
    }
    
    func startAnimation(_ completion: (() -> Void)?) {
        cloverImageView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        UIView.animate(withDuration: 2.2,
                       delay: 0,
                       usingSpringWithDamping: 0.2,
                       initialSpringVelocity: 0.2,
                       options: .curveEaseOut,
                       animations: { [weak self] in self?.cloverImageView.transform = CGAffineTransform(scaleX: 1, y: 1) },
                       completion: { _ in completion?() })
    }
    
    func showInfoView(networkConnectionAvailable: Bool) {
        let infoView = InfoView()
        let infoViewStatus: InfoViewStatus = networkConnectionAvailable ? .info("Network connection available") : .warning("Network connection lost")
        infoView.update(infoViewStatus)
        let topViewController = topMostViewController()
        topViewController?.view.addSubview(infoView)
        infoView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(10)
            $0.height.equalTo(60)
            $0.top.equalToSuperview().offset(-60)
        }
        topViewController?.view.layoutIfNeeded()
        UIView.animate(withDuration: 1,
                       delay: 0,
                       options: [.curveEaseInOut],
                       animations: {
                        infoView.snp.updateConstraints {
                            $0.top.equalToSuperview().offset(100)
                        }
                        topViewController?.view.layoutIfNeeded()
                       },
                       completion: { _ in
                        UIView.animate(withDuration: 1,
                                       delay: 0.5,
                                       animations: {
                                        infoView.snp.updateConstraints {
                                            $0.top.equalToSuperview().offset(-60)
                                        }
                                        topViewController?.view.layoutIfNeeded()
                                       }, completion: { _ in
                                        infoView.removeFromSuperview()
                                       })
                       })
    }
}
