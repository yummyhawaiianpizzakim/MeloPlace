//
//  PlayerView.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/09.
//

import Foundation
import UIKit
import SnapKit
import RxRelay
import RxSwift
import RxCocoa

final class PlayerView: UIView {
    let disposeBag = DisposeBag()
    
    var isEnableBackButton: Bool = false {
        didSet {
            self.bindBackButton(self.isEnableBackButton)
        }
    }
    
    var isEnabledNextButton: Bool = false {
        didSet {
            self.bindNextButton(self.isEnabledNextButton)
        }
    }
    
    lazy var musicLabel: UILabel = {
        let label = UILabel()
        label.text = "음악"
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 20)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    lazy var artistLabel: UILabel = {
        let label = UILabel()
        label.text = "음악"
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 16)
        label.textColor = .themeGray300
        label.textAlignment = .center
        return label
    }()
    
    lazy var playerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.isUserInteractionEnabled = true
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    lazy var playBackButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)
        button.setImage(UIImage(systemName: "backward.end.fill", withConfiguration: configuration), for: .normal)
        button.imageView?.tintColor = .black
        return button
    }()
    
    lazy var playPauseButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)
        button.setImage(UIImage(systemName: "play.fill", withConfiguration: configuration), for: .normal)
        button.imageView?.tintColor = .black
        return button
    }()
    
    lazy var playNextButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)
        button.setImage(UIImage(systemName: "forward.end.fill", withConfiguration: configuration), for: .normal)
        button.imageView?.tintColor = .black
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension PlayerView {
    func configureUI() {
        [self.musicLabel, self.artistLabel, self.playerStackView]
            .forEach { self.addSubview($0) }
        
        [self.playBackButton, self.playPauseButton,
         self.playNextButton].forEach {
            self.playerStackView.addArrangedSubview($0)
        }
        
        self.musicLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-5)
        }
        
        self.artistLabel.snp.makeConstraints { make in
            make.top.equalTo(self.musicLabel.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-5)
        }
        
        self.playerStackView.snp.makeConstraints { make in
            make.top.equalTo(self.artistLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
        
        [self.playBackButton, self.playPauseButton,
         self.playNextButton].forEach {
            self.playerStackView.setCustomSpacing(20, after: $0)
        }
    }
    
    func bindNextButton(_ isEnabled: Bool) {
        if isEnabled {
            self.playNextButton.isEnabled = isEnabled
            self.playNextButton.tintColor = .black
        } else {
            self.playNextButton.isEnabled = isEnabled
            self.playNextButton.tintColor = .themeGray100
        }
    }
    
    func bindBackButton(_ isEnabled: Bool) {
        if isEnabled {
            self.playBackButton.isEnabled = isEnabled
            self.playBackButton.tintColor = .black
        } else {
            self.playBackButton.isEnabled = isEnabled
            self.playBackButton.tintColor = .themeGray100
        }
    }
}

extension PlayerView {
    func bindPlayerController(isPaused: Bool) {
        let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)
        if isPaused {
            self.playPauseButton.setImage(UIImage(systemName: "play.fill", withConfiguration: configuration), for: .normal)
        } else {
            self.playPauseButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: configuration), for: .normal)
        }
    }
    
    func bindPlayerView(meloPlace: MeloPlace) {
        self.musicLabel.text = meloPlace.musicName
        self.artistLabel.text = meloPlace.musicArtist
    }
    
}
