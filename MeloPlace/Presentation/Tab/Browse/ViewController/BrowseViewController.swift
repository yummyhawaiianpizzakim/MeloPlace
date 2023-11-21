//
//  BrowseViewController.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/07.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxRelay
import RxCocoa
import RxGesture

class BrowseViewController: UIViewController {
    let disposeBag = DisposeBag()
    var viewModel: BrowseViewModel?
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Browse>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Browse>
    
    var dataSource: DataSource?
    
    let paginationTrigger = PublishRelay<Void>()
    
    lazy var searchBar = SearchBarView()
    
    lazy var browseCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.configureLayout())
        
        view.register(BrowseCollectionCell.self, forCellWithReuseIdentifier: BrowseCollectionCell.id)
        return view
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(viewModel: BrowseViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.setDataSource()
        self.bindUI()
        self.bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar()
    }
    
}

private extension BrowseViewController {
    func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithTransparentBackground()
        
        self.navigationItem.titleView = self.searchBar
        self.searchBar.configure(searchText: "이용자 검색")
        self.navigationItem.backButtonTitle = ""
        self.navigationItem.standardAppearance = appearance
        self.navigationItem.scrollEdgeAppearance = appearance
    }
    
    func configureUI() {
        self.view.addSubview(self.browseCollectionView)
        
        self.browseCollectionView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(5)
            make.horizontalEdges.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    func bindUI() {
        self.browseCollectionView.rx.prefetchItems
            .debug("prefetchItems")
            .compactMap(\.last?.row)
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .withUnretained(self)
            .filter { owner, row in
                guard let count = owner.viewModel?.browses.value.count,
                      let isLastFetch = owner.viewModel?.isLastFetch.value
                else { return false }
                if (row == count - 1) && !isLastFetch {
                    return true
                }
                return false
            }
            .bind { owner, row in
                print(row)
                owner.paginationTrigger.accept(())
            }
            .disposed(by: self.disposeBag)
    }
    
    func bindViewModel() {
        let input = BrowseViewModel.Input(
            viewWillAppear: self.rx.viewWillAppear.map { _ in return () },
            didTapSearchBar: self.searchBar.rx.tapGesture()
            .when(.recognized)
            .map({ _ in })
            .asObservable(),
            pagination: self.paginationTrigger.asObservable()
        )
        
        let output = self.viewModel?.transform(input: input)
        
        output?.browses
            .drive(onNext: { [weak self] browses in
                self?.setSnapshot(models: browses)
            })
            .disposed(by: self.disposeBag)
        
    }
    
    func configureLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)

        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    func setDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource(collectionView: self.browseCollectionView, cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
            
            guard
                let self = self,
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BrowseCollectionCell.id, for: indexPath) as? BrowseCollectionCell
            else { return UICollectionViewCell() }
            
            cell.didTapUserNameLabel
                .bind { userID in
                    self.viewModel?.showAnotherUserProfileView(userID: userID)
                }
                .disposed(by: self.disposeBag)
            
            cell.didTapImageView
                .bind { meloPlaceID in
                    self.viewModel?.showDetailView(meloPlaceID: meloPlaceID)
                }
                .disposed(by: self.disposeBag)
            
            cell.didTapProfileImageL
                .bind { id in
                    self.viewModel?.showAnotherUserProfileView(userID: id)
                }
                .disposed(by: self.disposeBag)
            
            cell.didTapCommentLabel
                .bind { id in
                    self.viewModel?.showCommentsView(meloPlaceID: id)
                }
                .disposed(by: self.disposeBag)
            
            cell.didTapPlayButton
                .flatMap { uri -> Observable<Bool> in
                    guard let isPaused = self.viewModel?.playMusic(with: uri) else { return Observable.just(false) }
                    return isPaused
                }
                .bind { isPaused in
                    cell.isPlayPauseButtonPaused = isPaused
                }
                .disposed(by: self.disposeBag)
            
            cell.configureCell(item: itemIdentifier)
            cell.backgroundColor = .systemBackground
            
            return cell
        })
        
    }
    
    func setSnapshot(models: [Browse]) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(models, toSection: 0)
        self.dataSource?.apply(snapshot, animatingDifferences: false)
    }
}
