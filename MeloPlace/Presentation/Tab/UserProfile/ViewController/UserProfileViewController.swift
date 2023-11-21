//
//  SettingViewController.swift
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

class UserProfileViewController: UIViewController {
    var viewModel: UserProfileViewModel?
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
        view.register(UserProfileCollectionCell.self, forCellWithReuseIdentifier: UserProfileCollectionCell.identifier)
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
    
    convenience init(viewModel: UserProfileViewModel) {
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

private extension UserProfileViewController {
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
        
        let input = UserProfileViewModel.Input(
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
        
        output?.dataSources.asDriver()
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
//        appearance.shadowColor = .themeGray100
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

private extension UserProfileViewController {
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
            guard let self = self else { return UICollectionViewCell() }
            switch item {
            case .profile(let user):
                guard
                    let meloPlaceCount = self.viewModel?.myMeloPlaces.value.count,
                    let cell = collView.dequeueReusableCell(withReuseIdentifier: UserProfileCollectionCell.identifier, for: indexPath) as? UserProfileCollectionCell
                else { return UICollectionViewCell() }
                
                cell.filterView.rx.itemSelected
                    .map { indexPath in
                        indexPath.row
                    }
                    .bind(to: self.tabstate)
                    .disposed(by: self.disposeBag)
                
                cell.searchUserButton.rx.tap
                    .subscribe { _ in
                        self.viewModel?.showSearchUserFlow()
                    }
                    .disposed(by: self.disposeBag)
                
                cell.followerCountLabel.rx.tapGesture()
                    .when(.recognized)
                    .withUnretained(self)
                    .bind { owner, _ in
                        owner.viewModel?.showFollowingUserView(tabState: owner.tabstate.value)
                    }
                    .disposed(by: self.disposeBag)
                
                cell.followingCountLabel.rx.tapGesture()
                    .when(.recognized)
                    .withUnretained(self)
                    .bind { owner, _ in
                        owner.viewModel?.showFollowingUserView(tabState: owner.tabstate.value)
                    }
                    .disposed(by: self.disposeBag)
                
                cell.configureCell(user: user, meloPlaceCount: meloPlaceCount)
                
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
    
//    func setStickyView(with collView: UICollectionView, of cell: UserProfileCollectionCell) {
//        collView.rx.contentOffset
//            .observe(on: MainScheduler.asyncInstance)
//            .bind { offset in
//                let     initialFilterViewPosition = cell.filterView.frame.origin.y // filterView의 초기 위치 저장
//
//                let navBarHeight = self.navigationController?.navigationBar.frame.height ?? 0
//                var statusBarHeight: CGFloat = 0
//                if #available(iOS 13.0, *) {
//                    statusBarHeight = self.view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
//                } else {
//                    statusBarHeight = UIApplication.shared.statusBarFrame.height
//                }
//
//                if offset.y >= cell.frame.height - cell.filterView.frame.height {
//                    collView.contentInset = UIEdgeInsets(
//                        top:
////                                    navBarHeight + statusBarHeight +
//                        cell.filterView.frame.height,
//                        left: 0,
//                        bottom: 0,
//                        right: 0
//                    )
//
//                    cell.filterView.frame = CGRect(
//                        x: 0,
//                        y: offset.y,
//                        width: self.view.frame.width,
//                        height: cell.filterView.frame.height
//                    )
//                } else {
//                    collView.contentInset = UIEdgeInsets(
//                        top: offset.y,
//                        left: 0,
//                        bottom: 0,
//                        right: 0
//                    )
//
//                    cell.filterView.frame = CGRect(
//                        x: 0,
//                        y: initialFilterViewPosition,
//                        width: self.view.frame.width,
//                        height: cell.filterView.frame.height
//                    )
//                }
//            }
//            .disposed(by: self.disposeBag)
//
//    }
}
