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
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, MeloPlace>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, MeloPlace>
    
    var dataSource: DataSource?
    
    lazy var listView: UIView = {
        let view = UIView()
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
    
    convenience init(viewModel: MapMeloPlaceListViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
//        self.setDataSource()
        self.bindViewModel()
    }
}

private extension MapMeloPlaceListViewController {
    func configureUI() {
        [self.meloPlaceCollectionView].forEach {
            self.view.addSubview($0)
        }
        
        self.meloPlaceCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func bindViewModel() {
        let input = MapMeloPlaceListViewModel.Input()
        let output = self.viewModel?.transform(input: input)
        
//        output?.dataSource
//            .asDriver()
//            .drive(onNext: {[weak self] meloPlaces in
//                self?.setSnapshot(models: meloPlaces)
//            })
//            .disposed(by: self.disposeBag)
    }
   
}

extension MapMeloPlaceListViewController {
    private func configureLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    private func setDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource(collectionView: self.meloPlaceCollectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MapMeloPlaceListCollectionCell.id, for: indexPath) as? MapMeloPlaceListCollectionCell else { return UICollectionViewCell() }
            cell.configureCell(item: itemIdentifier)
            cell.backgroundColor = .green
            return cell
        })
        
    }
    
    func setSnapshot(models: [MeloPlace]) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(models, toSection: 0)
        self.dataSource?.apply(snapshot, animatingDifferences: false)
    }
}
