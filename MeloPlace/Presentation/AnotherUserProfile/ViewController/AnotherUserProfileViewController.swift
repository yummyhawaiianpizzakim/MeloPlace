//
//  AnotherUserProfileViewController.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/10/31.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxRelay
import RxCocoa
import RxGesture

class AnotherUserProfileViewController: UIViewController {
    var viewModel: AnotherUserProfileViewModel?
    var disposeBag = DisposeBag()
    
    typealias DataSource = UICollectionViewDiffableDataSource<UserProfileSection, UserProfileSection.Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<UserProfileSection, UserProfileSection.Item>
        
    var dataSource: DataSource?
    
    let tabstate = BehaviorRelay<Int>(value: 0)
    
    private lazy var placeholderView: PlaceHolderView = {
        let view = PlaceHolderView(text: "게시물이 없습니다.")
        view.isHidden = true
        return view
    }()
    
    private lazy var colView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout(section: .contents))
        view.register(AnotherUserProfileCollectionCell.self, forCellWithReuseIdentifier: AnotherUserProfileCollectionCell.identifier)
        view.register(UserContentCollectionCell.self, forCellWithReuseIdentifier: UserContentCollectionCell.identifier)
        view.allowsMultipleSelection = true

        return view
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(viewModel: AnotherUserProfileViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureDataSource()
        self.bindUI()
        self.bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar()
    }
}

private extension AnotherUserProfileViewController {
    func configureUI() {
        self.addSubview()
        self.constraintView()
    }
    
    func addSubview() {
        self.view.addSubview(self.colView)
        self.view.addSubview(self.placeholderView)
    }
    
    func constraintView() {
        self.colView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        UIView.animate(withDuration: 1.5, delay: 1.0) {
            self.placeholderView.snp.makeConstraints { make in
                make.top.equalTo(self.view.safeAreaLayoutGuide).offset(self.view.appOffset * 35)
                make.horizontalEdges.equalToSuperview()
                make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            }
        }
    }
    
    func bindUI() {
        self.tabstate
            .compactMap { int in
                UserProfileLayout(rawValue: int)
            }
            .withUnretained(self)
            .bind { owner, section in
                owner.colView.setCollectionViewLayout(owner.createLayout(section: section), animated: false)
            }
            .disposed(by: disposeBag)
    }
    
    func bindViewModel() {
        
        let input = AnotherUserProfileViewModel.Input(
            tabstate: self.tabstate.asObservable()
        )
        let output = self.viewModel?.transform(input: input)
        
        self.colView.rx.itemSelected
            .withUnretained(self)
            .subscribe { owner, indexPath in
                if owner.colView.cellForItem(at: indexPath) is UserContentCollectionCell {
                    let int = self.tabstate.value
                    owner.viewModel?.showMeloPlaceDetailView(state: int, indexPath: indexPath)
                }
            }
            .disposed(by: self.disposeBag)
        
        output?.dataSources
            .compactMap({[weak self] dataSources in
                self?.generateSnapshot(dataSources: dataSources)
            })
            .drive(onNext: {[weak self] snapshot in
//                self?.hideFullSizeIndicator()
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
        self.viewModel?.userName
            .asDriver()
            .drive(onNext: { name in
                self.navigationController?.navigationBar.topItem?.title = name
            })
            .disposed(by: self.disposeBag)
        
        self.navigationItem.standardAppearance = appearance
        self.navigationItem.scrollEdgeAppearance = appearance
        self.navigationItem.backButtonTitle = ""
        
    }
    
}

private extension AnotherUserProfileViewController {
    func createLayout(section: UserProfileLayout) -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { int, layoutEnvironment -> NSCollectionLayoutSection? in
            return section.createLayout(index: int)
            
        }
        return layout
    }
    
    func generateSnapshot(dataSources: [UserDataSource]) -> Snapshot {
        var snapshot = Snapshot()
        dataSources.forEach { items in
            items.forEach { section, values in
                if !values.isEmpty {
                    snapshot.appendSections([section])
                    snapshot.appendItems(values, toSection: section)
                } else {
                    self.placeholderView.isHidden = false
                }
            }
        }
        return snapshot
    }
    
    func configureDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource(collectionView: self.colView, cellProvider: { [weak self]
            collView, indexPath, item in
            guard
                let self = self,
                let viewModel = self.viewModel
            else { return UICollectionViewCell() }
            switch item {
            case .profile(let user):
                guard
                    let meloPlaceCount = self.viewModel?.myMeloPlaces.value.count,
                    let cell = collView.dequeueReusableCell(withReuseIdentifier: AnotherUserProfileCollectionCell.identifier, for: indexPath) as? AnotherUserProfileCollectionCell
                else { return UICollectionViewCell() }
                
                cell.filterView.rx.itemSelected
                    .map { indexPath in
                        indexPath.row
                    }
                    .bind(to: self.tabstate)
                    .disposed(by: self.disposeBag)
                
                cell.searchUserButton.rx.tap
                    .subscribe { _ in
                        viewModel.showSearchUserFlow()
                    }
                    .disposed(by: self.disposeBag)
                
                viewModel.isFollowed
                    .debug("isFOllowed")
                    .bind(onNext: { isFollowed in
                        cell.configureFollowButton(isFollowed)
                    })
                    .disposed(by: self.disposeBag)
                
                cell.followingButton.rx.tap
                    .throttle(.seconds(1), scheduler: MainScheduler.instance)
                    .withLatestFrom(viewModel.isFollowed)
                    .do(onNext: { isFollowed in
                        var isFollowed = isFollowed
                        isFollowed.toggle()
                        viewModel.isFollowed.accept(isFollowed)
                    })
                    .bind { _ in
                        viewModel.updateFollowState()
                    }
                    .disposed(by: self.disposeBag)
                
                cell.followerCountLabel.rx.tapGesture()
                    .when(.recognized)
                    .bind { _ in
                        viewModel.showFollowingUserView(tabState: 0)
                    }
                    .disposed(by: self.disposeBag)
                
                cell.followingCountLabel.rx.tapGesture()
                    .when(.recognized)
                    .bind { _ in
                        viewModel.showFollowingUserView(tabState: 1)
                    }
                    .disposed(by: self.disposeBag)
                    
                cell.configureCell(user: user,
                                   meloPlaceCount: meloPlaceCount)
                
                return cell
                
            case .myContents(let meloPlace):
                guard let meloPlace = meloPlace, let cell = collView.dequeueReusableCell(withReuseIdentifier: UserContentCollectionCell.identifier, for: indexPath) as? UserContentCollectionCell
                else { return UICollectionViewCell() }
                cell.configureCell(meloPlace: meloPlace)
                self.placeholderView.isHidden = true
                
                return cell
            
            case .tagedContents(let meloPlace):
                guard let meloPlace = meloPlace, let cell = collView.dequeueReusableCell(withReuseIdentifier: UserContentCollectionCell.identifier, for: indexPath) as? UserContentCollectionCell
                else { return UICollectionViewCell() }
                cell.configureCell(meloPlace: meloPlace)
                self.placeholderView.isHidden = true

                return cell
            }
        })
    }
}
