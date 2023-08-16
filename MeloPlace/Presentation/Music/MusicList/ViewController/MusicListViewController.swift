//
//  MusicListViewController.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/15.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxRelay
import RxCocoa

class MusicListViewController: UIViewController {
    var viewModel: MusicListViewModel?
    let disposeBag = DisposeBag()
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Music>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Music>
    
    var dataSource: DataSource?
    
    lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "음악 검색"
        label.font = .systemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    lazy var connectButton = ThemeButton(title: "connect")
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.backgroundColor = .white
        searchBar.barTintColor = .white
        return searchBar
    }()
    
    lazy var musicCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.configureLayout())
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.register(MusicListCollectionCell.self, forCellWithReuseIdentifier: MusicListCollectionCell.identifier)
        return collectionView
    }()
    
    lazy var doneMusicButton = ThemeButton(title: "선택 완료")
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(viewModel: MusicListViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.configureUI()
        self.setDataSource()
        self.bindUI()
        self.bindViewModel()
    }
}

private extension MusicListViewController {
    func configureUI() {
        [topView, musicCollectionView, doneMusicButton].forEach {
            self.view.addSubview($0)
        }
        
        [titleLabel, connectButton, searchBar].forEach {
            self.topView.addSubview($0)
        }
        
        self.topView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
        }
        
        self.musicCollectionView.snp.makeConstraints { make in
            make.top.equalTo(self.topView.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(10)
        }
        
        self.connectButton.snp.makeConstraints { make in
//            make.leading.equalTo(self.titleLabel.snp.trailing).offset()
            make.trailing.top.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(30)
        }
        
        self.searchBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(self.connectButton.snp.bottom)
            make.height.equalTo(40)
        }
        
        self.doneMusicButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(50)
        }
    }
    
    func bindUI() {
//        self.musicCollectionView.rx
    }
    
    func bindViewModel() {
        let input = MusicListViewModel.Input(
//            connectSpotify: Observable.just(()),
            connectSpotify: self.connectButton.rx.tap.asObservable(),
            searchText: self.searchBar.rx.text.orEmpty.asObservable(),
            didTapCell: self.musicCollectionView.rx.itemSelected.asObservable(),
            didTapDoneButton: self.doneMusicButton.rx.tap.asObservable()
        )
        let output = self.viewModel?.transform(input: input)
        
        output?.dataSource.asDriver(onErrorJustReturn: [])
            .drive(with: self, onNext: { owner, musics in
                owner.setSnapshot(models: musics)
            })
            .disposed(by: self.disposeBag)
        
        output?.isDoneButtonEnable
            .asDriver()
            .drive(with: self,
                   onNext: { owner, isEnable in
                owner.doneMusicButton.isEnabled = isEnable
            })
            .disposed(by: self.disposeBag)
        
    }
    
}

private extension MusicListViewController {
    func configureLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(60))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    func setDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource(collectionView: self.musicCollectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MusicListCollectionCell.identifier, for: indexPath) as? MusicListCollectionCell else { return UICollectionViewCell() }
            cell.bindCell(item: itemIdentifier)
            return cell
        })
        
    }
    
    func setSnapshot(models: [Music]) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(models, toSection: 0)
        self.dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
}

extension MusicListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        self.deselectSectionItem(collectionView, indexPath: indexPath)
        return true
    }
    
    func deselectSectionItem(_ collectionView: UICollectionView, indexPath: IndexPath?) {
        guard
            let selectedItemSection = collectionView.indexPathsForSelectedItems,
            let indexPath = indexPath
        else {
            return
        }
        let selectedItemIndexPath = selectedItemSection.filter { $0.section == indexPath.section }
        
        if let indexPath = selectedItemIndexPath.last {
            collectionView.deselectItem(at: indexPath, animated: false)
        }
    }
    
//    func asd() -> Observable<Music> {
//        return Observable.create { observer in
//            self.musicCollectionView.rx.itemSelected
//                .asObservable()
//                .subscribe { indexPath in
//
//                }
//
//            return Disposables.create()
//        }
//    }
//
//    func transformSelectedItemToInput() -> Observable<Music> {
//        return self.collectionView.rx.itemSelected
//            .asObservable()
//            .compactMap { [weak self] indexPath in
//                guard
//                    let self,
//                    let music = self.dataSource?.itemIdentifier(for: indexPath)
//                else {
//                    return
//                }
////                if indexPath.section == 0 {
////                    return Observable.just(music)
////                }
//
//                switch indexPath.section {
//                case 0:
//                    return Observable.just(music)
//
//                }
//            }
//    }
//
//    func transformDeselectedItemToInput() -> Observable<Music> {
//        return self.collectionView.rx.itemDeselected
//            .asObservable()
//            .compactMap { indexPath -> Music? in
//                switch indexPath.section {
//                case 0:
//                    return 0
//                }
//            }
//    }
}
