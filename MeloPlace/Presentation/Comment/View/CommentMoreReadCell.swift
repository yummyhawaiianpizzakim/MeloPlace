//
//  CommentMoreReadCell.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/11/14.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import Kingfisher

class CommentMoreReadCell: UICollectionViewCell {
    static var id: String {
        return "CommentMoreReadCell"
    }
    
    var disposeBag = DisposeBag()
    
    lazy var plusImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "plus.circle")
        view.tintColor = .black
        view.clipsToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .brown
        self.configureUI()
        self.bindUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
}

private extension CommentMoreReadCell {
    func configureUI() {
        [self.plusImageView]
            .forEach { self.contentView.addSubview($0) }
        
        self.plusImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
            make.edges.equalToSuperview()
            print("readcell::: loadf")
        }
    }
    
    func bindUI() {
        
    }
    
}
