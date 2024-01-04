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
        return view
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15.0)
        button.setTitleColor(.black, for: .normal)
        button.sizeToFit()
        return button
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "음악 검색"
        label.font = .systemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.layer.borderColor = UIColor.systemBackground.cgColor
        searchBar.searchBarStyle = .minimal
        searchBar.layer.borderWidth = 0
        searchBar.tintColor = .themeColor300
        return searchBar
    }()
    
    lazy var musicCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.configureLayout())
        collectionView.delegate = self
        collectionView.register(MusicListCollectionCell.self, forCellWithReuseIdentifier: MusicListCollectionCell.identifier)
        return collectionView
    }()
    
    lazy var doneButton = ThemeButton(title: "선택 완료")
    
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
        self.configureAttributes()
        self.configureUI()
        self.setDataSource()
        self.bindUI()
        self.bindViewModel()
    }
}

private extension MusicListViewController {
    func configureAttributes() {
        self.view.backgroundColor = .white
        self.hideKeyboardWhenTappedAround()
    }
    
    func configureUI() {
        [self.topView, self.musicCollectionView, self.doneButton].forEach {
            self.view.addSubview($0)
        }
        
        [self.titleLabel, self.cancelButton,
         self.searchBar].forEach {
            self.topView.addSubview($0)
        }
        
        self.topView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(120)
        }
        
        self.musicCollectionView.snp.makeConstraints { make in
            make.top.equalTo(self.topView.snp.bottom).offset(10)
            make.bottom.equalTo(self.doneButton.snp.top).offset(-10)
            make.horizontalEdges.equalToSuperview()
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
        }
        
        self.cancelButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(10)
            make.height.equalTo(15)
            
        }
        
        self.searchBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
        
        self.doneButton.snp.makeConstraints { make in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-10)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(50)
        }
    }
    
    func bindUI() {
        self.doneButton.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: self.disposeBag)
        
        self.cancelButton.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: self.disposeBag)
    }
    
    func bindViewModel() {
        let didDeselectItem = self.musicCollectionView.rx.itemDeselected
            .do(onNext: { [weak self] indexPath in
                self?.musicCollectionView.deselectItem(at: indexPath, animated: false)
            }).asObservable()
                
                
        
        let input = MusicListViewModel.Input(
            searchText: self.searchBar.rx.text.orEmpty.asObservable(),
            didSelectItem: self.musicCollectionView.rx.itemSelected.asObservable(),
            didDeselectItem: didDeselectItem,
            didTapDoneButton: self.doneButton.rx.tap.asObservable()
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
                owner.doneButton.isEnabled = isEnable
                
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
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = self.musicCollectionView.cellForItem(at: indexPath) as? MusicListCollectionCell else { return }
        if cell.isSelected {
            self.deselectSectionItem(collectionView, indexPath: indexPath)
        }
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
}
