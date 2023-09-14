//
//  PlayerView.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/09.
//

import Foundation
import UIKit
import SnapKit

class PlayerView: UIView {
    
    private lazy var durationSlider: UISlider = {
        let slider = UISlider()
        slider.maximumValue = 0
        slider.maximumValue = 0
//        slider.frame = CGRect(x: 0, y: view.height - 1, width: view.width, height: 1)
        slider.setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
        slider.tintColor = .tintColor
        slider.thumbTintColor = .white
//        slider.addTarget(self, action: #selector(onChangeSlider(_ :)), for: .valueChanged)
        return slider
    }()
    
    private lazy var sliderCurrentValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.text = "00:00"
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
//        label.frame = CGRect(x: 31, y: 197 + view.width, width: 60, height: 35)
        label.textAlignment = .left
        label.layer.opacity = 0
        return label
    }()
    
    private lazy var sliderMaximumValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.text = "01:00"
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
//        label.frame = CGRect(x: view.width - (31 + 60), y: 197 + view.width, width: 60, height: 35)
        label.textAlignment = .right
        label.layer.opacity = 0
        return label
    }()
    
    lazy var musicLabel: UILabel = {
        let label = UILabel()
        label.text = "음악"
        label.font = .systemFont(ofSize: 20)
        label.textColor = .white
        return label
    }()
    
    lazy var artistLabel: UILabel = {
        let label = UILabel()
        label.text = "아티스트"
        label.font = .systemFont(ofSize: 10)
        label.textColor = .themeGray300
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
        let configuration = UIImage.SymbolConfiguration(pointSize: 35, weight: .bold, scale: .large)
        button.setImage(UIImage(systemName: "backward.end.fill", withConfiguration: configuration), for: .normal)
        return button
    }()
    
    lazy var playPauseButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 50, weight: .bold, scale: .large)
        button.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: configuration), for: .normal)
        return button
    }()
    
    lazy var playNextButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 35, weight: .bold, scale: .large)
        button.setImage(UIImage(systemName: "forward.end.fill", withConfiguration: configuration), for: .normal)
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
        [self.musicLabel, self.artistLabel,
         self.durationSlider, self.sliderCurrentValueLabel, self.sliderMaximumValueLabel,
         self.playerStackView].forEach {
            self.addSubview($0)
        }
        
        [self.playBackButton, self.playPauseButton, self.playNextButton].forEach {
            self.playerStackView.addArrangedSubview($0)
        }
        
        self.musicLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(5)
//            make.height.equalTo(20)
        }
        
        self.artistLabel.snp.makeConstraints { make in
            make.top.equalTo(self.musicLabel.snp.bottom).offset(5)
            make.leading.equalTo(self.musicLabel.snp.leading)
//            make.height.equalTo(10)
        }
        
        self.durationSlider.snp.makeConstraints { make in
            make.top.equalTo(self.artistLabel.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(2)
        }
        
        self.sliderCurrentValueLabel.snp.makeConstraints { make in
            make.top.equalTo(self.durationSlider.snp.bottom).offset(5)
            make.leading.equalTo(self.durationSlider.snp.leading)
        }
        
        self.sliderMaximumValueLabel.snp.makeConstraints { make in
            make.top.equalTo(self.durationSlider.snp.bottom).offset(5)
            make.trailing.equalTo(self.durationSlider.snp.trailing)
        }
        
        self.playerStackView.snp.makeConstraints { make in
            make.top.equalTo(self.sliderCurrentValueLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(85)
        }
        
//        self.playPauseButton.snp.makeConstraints { make in
//            make.top.equalTo(self.sliderCurrentValueLabel.snp.bottom).offset(5)
//            make.centerX.equalToSuperview()
//            make.height.width.equalTo(50)
//        }
//
//        self.playBackButton.snp.makeConstraints { make in
//            make.top.equalTo(self.sliderCurrentValueLabel.snp.bottom).offset(5)
//            make.centerX.equalToSuperview()
//            make.height.width.equalTo(50)
//        }
//
//        self.playNextButton.snp.makeConstraints { make in
//            make.top.equalTo(self.sliderCurrentValueLabel.snp.bottom).offset(5)
//            make.centerX.equalToSuperview()
//            make.height.width.equalTo(50)
//        }
        
    }
    
}

extension PlayerView {
    
}
