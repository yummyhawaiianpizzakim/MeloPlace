//
//  FilterCollectionView.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/08.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxRelay

enum UserPageFilter: Int, Hashable, CaseIterable {
    case contents = 0
    case taged
    
    var title: String {
        switch self {
        case .contents:
            return "내 게시물"
        case .taged:
            return "태그된 게시물"
        }
    }
}

enum MapMeloPlaceFilter: Int, Hashable, CaseIterable {
    case my = 0
    case following
    
    var title: String {
        switch self {
        case .my:
            return "내 게시물"
        case .following:
            return "팔로잉 게시물"
        }
    }
    
    init(index: Int) {
        switch index {
        case 0: self = .my
        case 1: self = .following
        default: self = .my
        }
    }
}

enum FollowingUserListFilter: Int, Hashable, CaseIterable {
    case follower = 0
    case following
    
    var title: String {
        switch self {
        case .follower:
            return "팔로워"
        case .following:
            return "팔로잉"
        }
    }
    
    init(index: Int) {
        switch index {
        case 0: self = .follower
        case 1: self = .following
        default: self = .follower
        }
    }
}

enum FilterMode: Hashable {
    typealias Item = FilterItem
        
        static func == (lhs: FilterMode, rhs: FilterMode) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }
    
    case userPage
    case mapMeloPlace
    case follingUserList
    
    enum FilterItem: Hashable {
        case userPage(filter: UserPageFilter)
        case mapMeloPlace(filter: MapMeloPlaceFilter)
        case follingUserList(filter: FollowingUserListFilter)
        
        var title: String {
            switch self {
            case .userPage(filter: let item):
                return item.title
            case .mapMeloPlace(filter: let item):
                return item.title
            case .follingUserList(filter: let item):
                return item.title
            }
        }
    }
    
    var items: [Item] {
        switch self {
        case .userPage:
            return UserPageFilter.allCases.map { filter in
                FilterItem.userPage(filter: filter)
            }
        case .mapMeloPlace:
            return MapMeloPlaceFilter.allCases.map { filter in
                FilterItem.mapMeloPlace(filter: filter)
            }
        case .follingUserList:
            return FollowingUserListFilter.allCases.map {
                FilterItem.follingUserList(filter: $0)
            }
        }
    }
}

final class FilterCollectionView: UICollectionView {

    var filterMode: FilterMode
    var filterDataSource: UICollectionViewDiffableDataSource<Int, FilterMode.Item>?
    var disposeBag = DisposeBag()

    lazy var underLineBar: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    init(filterMode: FilterMode) {
        self.filterMode = filterMode
        super.init(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        
        self.configureCollectionview()
        self.configureUI()
        self.bind()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension FilterCollectionView {
    private func configureCollectionview() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        self.collectionViewLayout = layout
        self.showsHorizontalScrollIndicator = false
        self.delegate = self
        
        let snapshot = generateSnapshot(self.filterMode)
        self.register(FilterCollectionCell.self, forCellWithReuseIdentifier: FilterCollectionCell.identifier)
        self.setDataSource()
        self.filterDataSource?.apply(snapshot)
        
        self.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    }
    private func configureUI() {
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = 0.1
        
        self.addSubview(self.underLineBar)
    }
    
    private func bind() {
        self.rx.itemSelected
            .compactMap { [weak self] indexPath in
                return self?.cellForItem(at: indexPath)
            }
            .subscribe(onNext: { [weak self] cell in
                guard let self = self else { return }
                
                let xPosition = cell.frame.origin.x
                let width = cell.frame.width
                
                self.updateView(xPosition: xPosition, width: width)
                UIView.animate(withDuration: 0.3) {
                    self.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
        
        
    }
    
    private func updateView(xPosition: CGFloat, width: CGFloat) {
        self.underLineBar.snp.remakeConstraints { make in
            make.leading.equalToSuperview().inset(xPosition)
            make.width.equalTo(width)
            make.bottom.equalToSuperview().offset(appOffset * 6)
            make.height.equalTo(2)
        }
    }
    
    private func setDataSource() {
        self.filterDataSource = UICollectionViewDiffableDataSource(collectionView: self, cellProvider: {
            collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FilterCollectionCell.identifier,
                for: indexPath) as? FilterCollectionCell else {return UICollectionViewCell()}
            cell.bind(title: item.title)
            return cell
        })
    }
    
    private func generateSnapshot(_ filterMode: FilterMode) -> NSDiffableDataSourceSnapshot<Int, FilterMode.FilterItem> {
        var snapshot = NSDiffableDataSourceSnapshot<Int, FilterMode.FilterItem>()
        snapshot.appendSections([0])
        snapshot.appendItems(filterMode.items, toSection: 0)
        return snapshot
    }
}

extension FilterCollectionView: UICollectionViewDelegateFlowLayout {
    private func configureCollectionViewLoyout() -> UICollectionViewFlowLayout {
           let layout = UICollectionViewFlowLayout()
           layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
           layout.scrollDirection = .horizontal
           return layout
       }
       
       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
           
           let size = CGSize(width: appOffset * 22, height: appOffset * 6)
           
           if indexPath.row == 0 {
               underLineBar.snp.makeConstraints { make in
                   make.left.equalToSuperview().offset(16)
                   make.width.equalTo(size.width)
                   make.height.equalTo(2)
                   make.bottom.equalToSuperview().offset(appOffset * 6)
               }
           }
           return size
       }
}
