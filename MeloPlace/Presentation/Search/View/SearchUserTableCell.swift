//
//  SearchUserTableCell.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/10/09.
//

import Foundation
import UIKit
import SnapKit
import Kingfisher

final class SearchUserTableCell: UITableViewCell {
    static var id: String {
        return "SearchUserTableCell"
    }
    
    lazy var profileImageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        let cornerRadius = appOffset * 6 / 2
        view.layer.cornerRadius = cornerRadius
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.themeColor300?.cgColor
        view.tintColor = .black
        return view
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: appOffset * 2)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configureUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

private extension SearchUserTableCell {
    func configureUI() {
        [self.profileImageView, self.label].forEach {
            self.contentView.addSubview($0)
        }
        
        self.profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(appOffset * 6)
            make.top.equalToSuperview().offset(appOffset)
            make.leading.equalToSuperview().offset(appOffset)
            make.bottom.equalToSuperview().offset(-appOffset)
        }
        
        self.label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(self.profileImageView.snp.trailing).offset(appOffset * 2)
            make.trailing.equalToSuperview().offset(-(appOffset * 2))
        }
    }
    
    
    private func setImage(at profileImageURL: String) {
        let url = URL(string: profileImageURL)
        let size = appOffset * 10
        let maxProfileImageSize = CGSize(width: size, height: size)
        let downsamplingProcessor = DownsamplingImageProcessor(size: maxProfileImageSize)
        let placeholder = UIImage(systemName: "person")
        self.profileImageView.kf.setImage(with: url, placeholder: placeholder, options: [.processor(downsamplingProcessor)] )
    }
    
}

extension SearchUserTableCell {
    func configureCell(item: User) {
        self.label.text = item.name
        self.setImage(at: item.imageURL)
    }
}
