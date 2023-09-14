//
//  UserContentCollectionCell.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/08.
//

import Foundation
import UIKit
import SnapKit
import Kingfisher
import RxSwift
import RxGesture

protocol UserContentCollectionCellDelegate: AnyObject {
    func didTapContentImage(sender: UserContentCollectionCell)
}

class UserContentCollectionCell: UICollectionViewCell {
    static var identifier: String {
        return "UserContentCollectionCell"
    }
    
    weak var delegate: UserContentCollectionCellDelegate?
    let disposeBag = DisposeBag()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "name"
        label.textColor = .white
        label.font = .systemFont(ofSize: 8)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureAtributes()
        self.configureUI()
        self.bindUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension UserContentCollectionCell {
    func configureAtributes() {
        self.contentView.backgroundColor = .systemBackground
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }
    
    func configureUI() {
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.imageView)
        self.nameLabel.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
            make.leading.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            
        }
        self.imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func bindUI() {
//        self.imageView.rx.tapGesture()
//            .when(.recognized)
//            .withUnretained(self)
//            .subscribe { owner, _ in
//                owner.delegate?.didTapContentImage(sender: owner)
//            }
//            .disposed(by: self.disposeBag)
    }
    
    func setImage(imageURLString: String) {
        guard let url = URL(string: imageURLString) else { return }
        let maxProfileImageSize = CGSize(width: 100, height: 100)
        let downsamplingProcessor = DownsamplingImageProcessor(size: maxProfileImageSize)
        self.imageView.kf.setImage(with: url, placeholder: .none, options: [.processor(downsamplingProcessor)])
    }
    
}

extension UserContentCollectionCell {
    func configureCell(meloPlace: MeloPlace) {
        guard let image = meloPlace.images.first else { return }
        self.nameLabel.text = meloPlace.musicName
        self.setImage(imageURLString: image)
    }
}
