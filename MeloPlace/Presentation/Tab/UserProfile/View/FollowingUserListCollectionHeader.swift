//
//  FollowingUserListCollectionHeader.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/11/09.
//

import Foundation
import UIKit
import SnapKit

final class FollowingUserListCollectionHeader: UICollectionReusableView {
    static var id: String {
        return "FollowingUserListCollectionHeader"
    }
    
    lazy var followingUserListFilter = FilterCollectionView(filterMode: .follingUserList)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension FollowingUserListCollectionHeader {
    func configureUI() {
        self.addSubview(self.followingUserListFilter)
        
        self.followingUserListFilter.snp.makeConstraints { make in
            make.edges.equalTo(self.safeAreaLayoutGuide)
        }
    }
}
