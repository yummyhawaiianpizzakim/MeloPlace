//
//  FollowingUserListViewController.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/11/09.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxRelay
import RxCocoa
import RxGesture

class FollowingUserListViewController: UIViewController {
    var viewModel: FollowingUserListViewModel?
    var disposeBag = DisposeBag()
    
    typealias DataSource = UICollectionViewDiffableDataSource<FollowingListSection, FollowingListSection.Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<FollowingListSection, FollowingListSection.Item>
    
    var dataSource: DataSource?
    var searchText = ""
    let tabstate = BehaviorRelay<Int>(value: 0)
//    private lazy var placeholderView = profilePlaceholderView()
    
    private lazy var filterView = FilterCollectionView(filterMode: .follingUserList)
    
    private lazy var colView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.configureLayout())
        view.register(FollowingUserListCollectionCell.self, forCellWithReuseIdentifier: FollowingUserListCollectionCell.identifier)
        view.allowsMultipleSelection = false

        return view
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(viewModel: FollowingUserListViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureAttributes()
        self.configureDataSource()
        self.bindUI()
        self.bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar()
    }
}

private extension FollowingUserListViewController {
    func configureUI() {
        self.addSubview()
        self.constraintView()
    }
    
    func addSubview() {
        [self.filterView, self.colView].forEach {
            self.view.addSubview($0)
        }
    }
    
    func constraintView() {
        self.filterView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
//                .offset(self.view.appOffset)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(self.view.appOffset * 6)
        }
//        self.colView.backgroundColor = .blue
        self.colView.snp.makeConstraints { make in
            make.top.equalTo(self.filterView.snp.bottom).offset(self.view.appOffset)
            make.horizontalEdges.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    func configureAttributes() {
        let indexPath = IndexPath(row: self.tabstate.value, section: 0)
        self.filterView.scrollToItem(at: indexPath, at: .top, animated: false)
    }
    
    func bindUI() {
        self.filterView.rx
            .itemSelected
            .map { $0.row }
            .bind(to: self.tabstate)
            .disposed(by: self.disposeBag)
    }
    
    func bindViewModel() {
        
        let input = FollowingUserListViewModel.Input(
            tabstate: self.tabstate.asObservable()
        )
        
        let output = self.viewModel?.transform(input: input)
        
        self.colView.rx.itemSelected
            .withUnretained(self)
            .subscribe { owner, indexPath in
                if owner.colView.cellForItem(at: indexPath) is FollowingUserListCollectionCell {
                    let int = self.tabstate.value
                    owner.viewModel?.showAnotherUserProfileView(state: int, indexPath: indexPath)
                }
            }
            .disposed(by: self.disposeBag)
        
        output?.dataSources
            .debug("datasource")
            .compactMap({[weak self] dataSources in
                self?.generateSnapshot(dataSources: dataSources)
            })
            .drive(onNext: {[weak self] snapshot in
                self?.dataSource?.apply(snapshot, animatingDifferences: false)
            })
            .disposed(by: self.disposeBag)
        
    }
    
    func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        let backButtonImage = UIImage(systemName: "arrow.backward")
        
        appearance.configureWithOpaqueBackground()
        appearance.setBackIndicatorImage(backButtonImage, transitionMaskImage: backButtonImage)
        appearance.shadowColor = .systemBackground
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.title = "팔로우 목록"
        self.navigationItem.standardAppearance = appearance
        self.navigationItem.scrollEdgeAppearance = appearance
        self.navigationItem.backButtonTitle = ""
        
    }
    
}

private extension FollowingUserListViewController {
    private func configureLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(self.view.appOffset * 6))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(self.view.appOffset * 6))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = NSCollectionLayoutSpacing.fixed(10)
//        group.contentInsets = .init(top: self.view.appOffset, leading: 0, bottom: 0, trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    func generateSnapshot(dataSources: [FollowingListDataSource]) -> Snapshot {
        var snapshot = Snapshot()
        dataSources.forEach { items in
            items.forEach { section, values in
                if !values.isEmpty {
                    snapshot.appendSections([section])
                    snapshot.appendItems(values, toSection: section)
                } else {
//                    snapshot.appendSections([section])
//                    self.placeholderView.isHidden = false
                }
            }
        }
        return snapshot
    }
    
    func configureDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource(collectionView: self.colView, cellProvider: { [weak self]
            collView, indexPath, item in
            guard let self = self else { return UICollectionViewCell() }
            switch item {
            case .follower(let user):
                guard
                    let cell = collView.dequeueReusableCell(withReuseIdentifier: FollowingUserListCollectionCell.identifier, for: indexPath) as? FollowingUserListCollectionCell
                else { return UICollectionViewCell() }
                
                cell.configureCell(user: user)
                
                return cell
                
            case .following(let user):
                guard
                    let cell = collView.dequeueReusableCell(withReuseIdentifier: FollowingUserListCollectionCell.identifier, for: indexPath) as? FollowingUserListCollectionCell
                else { return UICollectionViewCell() }
                cell.configureCell(user: user)
                
//                self.placeholderView.isHidden = true
                return cell
            }
        })
    }
}
