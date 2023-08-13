//
//  LocationView.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/12.
//

import Foundation
import MapKit
import SnapKit
import UIKit

final class MeloLocateView: UIView {
    // MARK: - UI Components

    let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical

        return stackView
    }()

    let topView = UIView()

    let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12.0)
        button.setTitleColor(.black, for: .normal)

        return button
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "위치 선택"
        label.font = .systemFont(ofSize: 12.0)
        label.textColor = .black
        return label
    }()

    let locateMap = MapView()

    let cursor: UIImageView = {
        let cursor = UIImageView(image: UIImage(systemName: "mappin.and.ellipse"))
        cursor.isUserInteractionEnabled = true

        return cursor
    }()

    let locationView = UIView()

    let locationIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "mappin.and.ellipse")
        imageView.tintColor = .orange

        return imageView
    }()

    lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.text = "위치 선택"
        label.font = .systemFont(ofSize: 12.0)
        label.textColor = .black
        return label
    }()

    lazy var doneButton = ThemeButton(title: "완료")

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
        addSubViews()
        makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    func configure() {}

    func addSubViews() {
        [cancelButton, titleLabel].forEach {
            topView.addSubview($0)
        }

        locateMap.addSubview(cursor)

        [locationIcon, locationLabel, doneButton].forEach {
            locationView.addSubview($0)
        }

        [topView, locateMap, locationView].forEach {
            mainStackView.addArrangedSubview($0)
        }

        addSubview(mainStackView)
    }

    func makeConstraints() {
        cursor.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.width.equalTo(30) // 바뀔것 같아서 수정안함!
        }

        cancelButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20.0)
            $0.top.equalToSuperview().offset(20.0)
            $0.bottom.equalToSuperview().offset(-20.0)
        }

        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(cancelButton.snp.centerY)
        }

        locationIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20.0)
            $0.top.equalToSuperview().offset(20.0)
            $0.size.equalTo(30.0)
        }

        locationLabel.snp.makeConstraints {
            $0.centerY.equalTo(locationIcon.snp.centerY)
            $0.leading.equalTo(locationIcon.snp.trailing).offset(20.0)
            $0.trailing.equalToSuperview().offset(-20.0)
        }

        doneButton.snp.makeConstraints {
            $0.leading.equalTo(20.0)
            $0.trailing.equalTo(-20.0)
            $0.top.equalTo(locationIcon.snp.bottom).offset(20.0)
            $0.bottom.equalToSuperview().offset(-20.0)
            $0.height.equalTo(50.0)
        }

        mainStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
