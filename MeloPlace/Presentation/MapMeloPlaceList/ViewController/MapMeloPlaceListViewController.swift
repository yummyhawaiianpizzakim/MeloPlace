//
//  MapMeloPlaceListViewController.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/31.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxRelay
import RxCocoa

class MapMeloPlaceListViewController: UIViewController {
    var viewModel: MapMeloPlaceListViewModel?
    let disposeBag = DisposeBag()
    
    
    lazy var placeholderView: PlaceHolderView = {
        let view = PlaceHolderView(text: "게시물이 없습니다.")
        view.isHidden = true
        return view
    }()
    
    lazy var scrollView = UIScrollView()
    
    lazy var contentView = UIView()
    
    lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30)
        label.textColor = .black
        return label
    }()
    
    lazy var filterView: UICollectionView = {
        let view = FilterCollectionView(filterMode: .mapMeloPlace)
        return view
    }()
    
    lazy var meloPlaceCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.configureLayout())
        view.register(MapMeloPlaceListCollectionCell.self, forCellWithReuseIdentifier: MapMeloPlaceListCollectionCell.id)
        return view
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureAtributes()
        self.configureUI()
        self.bindViewModel()
    }
}

private extension MapMeloPlaceListViewController {
    func configureAtributes() {
    }
    
    func configureUI() {
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.contentView)
        
        [self.locationLabel, self.filterView,
         self.placeholderView, self.meloPlaceCollectionView
        ].forEach {
            self.contentView.addSubview($0)
        }
        
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        self.locationLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(30)
        }
        
        self.filterView.snp.makeConstraints { make in
            make.top.equalTo(self.locationLabel.snp.bottom).offset(20)
            make.leading.equalTo(self.locationLabel.snp.leading)
            make.trailing.equalTo(self.locationLabel.snp.trailing)
            make.height.equalTo( self.view.appOffset * 6 )
        }
        
        self.meloPlaceCollectionView.snp.makeConstraints { make in
            make.top.equalTo(self.filterView.snp.bottom).offset(20)
            make.leading.equalTo(self.locationLabel.snp.leading)
            make.trailing.equalTo(self.locationLabel.snp.trailing)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        UIView.animate(withDuration: 1.5, delay: 1.0) {
            self.placeholderView.snp.makeConstraints { make in
                make.top.equalTo(self.meloPlaceCollectionView.snp.top).offset(self.view.appOffset * 4)
                make.horizontalEdges.equalToSuperview()
                make.bottom.equalTo(self.meloPlaceCollectionView.snp.bottom)
                make.height.equalTo(150)
            }
        }
    }
    
    func bindViewModel() {
        
    }
   
}

extension MapMeloPlaceListViewController {
    private func configureLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
//
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = NSCollectionLayoutSpacing.fixed(20)

        let section = NSCollectionLayoutSection(group: group)

        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
}
