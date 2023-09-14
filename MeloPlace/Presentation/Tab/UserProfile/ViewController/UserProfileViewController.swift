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

class UserProfileViewController: UIViewController {
    var viewModel: UserProfileViewModel?
    var disposeBag = DisposeBag()
    typealias DataSource = UICollectionViewDiffableDataSource<UserProfileSection, UserProfileSection.Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<UserProfileSection, UserProfileSection.Item>
        
    var dataSource: DataSource?
    
    let tabstate = BehaviorRelay<Int>(value: 0)
    
//    private lazy var placeholderView = profilePlaceholderView()
    
    private lazy var colView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout(section: .likes))
//        let view = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout())
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
        self.bindViewModel()
    }
}

extension UserProfileViewController {
    private func configureUI() {
//        self.placeholderView.isHidden = true
        self.colView.rx.contentOffset
            .scan((0, .zero)) { (previous, current) in
                return (current.y, current)
            }
            .subscribe(onNext: {[weak self] (previousY, currentOffset) in
                let scrollingUpwards = currentOffset.y < previousY
                if scrollingUpwards {
                    self?.colView.contentOffset = CGPoint(x: currentOffset.x, y: previousY)
                }
            })
            .disposed(by: disposeBag)
        self.addSubview()
        self.constraintView()
    }
    
    private func addSubview() {
        self.view.addSubview(self.colView)
//        self.view.addSubview(self.placeholderView)
    }
    
    private func constraintView() {
        self.colView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
//        UIView.animate(withDuration: 1.5, delay: 1.0) {
//            self.placeholderView.snp.makeConstraints { make in
//                make.leading.trailing.equalToSuperview()
////                make.centerY.equalToSuperview()
////                make.height.equalTo(self.view.appOffset * 18)
//                make.bottom.equalToSuperview()
//                make.height.equalTo(self.view.appOffset * 50)
//            }
//        }
    }
    
    func bindViewModel() {
        
        let input = UserProfileViewModel.Input(
            tabstate: tabstate.asObservable()
        )
        let output = self.viewModel?.transform(input: input)
        
        self.colView.rx.itemSelected
            .withUnretained(self)
//            .asObservable()
            .subscribe { owner, indexPath in
                if owner.colView.cellForItem(at: indexPath) is UserContentCollectionCell {
                    owner.viewModel?.showMeloPlaceDetailView(indexPath: indexPath)
                }
            }
            .disposed(by: self.disposeBag)
        
        self.tabstate
            .compactMap { int in
                UserProfileLayout(rawValue: int)
            }
            .withUnretained(self)
            .subscribe { owner, section in
                owner.colView.setCollectionViewLayout(owner.createLayout(section: section), animated: false)
            }
            .disposed(by: disposeBag)
        
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
    
    private func createLayout(section: UserProfileLayout) -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { int, layoutEnvironment -> NSCollectionLayoutSection? in
            return section.createLayout(index: int)
            
        }
        return layout
    }
    
    private func generateSnapshot(dataSources: [UserDataSource]) -> Snapshot {
        var snapshot = Snapshot()
        dataSources.forEach { items in
            items.forEach { section, values in
                if !values.isEmpty {
                    snapshot.appendSections([section])
                    snapshot.appendItems(values, toSection: section)
                } else {
//                    self.placeholderView.isHidden = false
                }
            }
        }
        return snapshot
    }
    
    private func configureDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource(collectionView: self.colView, cellProvider: { [weak self]
            collView, indexPath, item in
            guard let self = self else { return UICollectionViewCell() }
            switch item {
            case .profile(let user):
                guard let cell = collView.dequeueReusableCell(withReuseIdentifier: UserProfileCollectionCell.identifier, for: indexPath) as? UserProfileCollectionCell
                else { return UICollectionViewCell() }
                cell.filterView.rx.itemSelected
                    .map { indexPath in
                        indexPath.row
                    }
                    .bind(to: self.tabstate)
                    .disposed(by: self.disposeBag)
                
                cell.configureCell(user: user)
                cell.delegate = self
//                cell.backgroundColor = .cyan
                return cell
            case .likes(let meloPlace):
                guard let meloPlace = meloPlace, let cell = collView.dequeueReusableCell(withReuseIdentifier: UserContentCollectionCell.identifier, for: indexPath) as? UserContentCollectionCell
                else { return UICollectionViewCell() }
                cell.configureCell(meloPlace: meloPlace)
//                cell.delegate = self
                
//                self.placeholderView.isHidden = true
//                cell.backgroundColor = .blue
                return cell
            
            case .collections(let meloPlace):
                guard let meloPlace = meloPlace, let cell = collView.dequeueReusableCell(withReuseIdentifier: UserContentCollectionCell.identifier, for: indexPath) as? UserContentCollectionCell
                else { return UICollectionViewCell() }
                cell.configureCell(meloPlace: meloPlace)
//                self.placeholderView.isHidden = true
//                cell.backgroundColor = .blue
                return cell
            }
        })
    }
    
}

extension UserProfileViewController: UserProfileCollectionCellDelegate {
    func didTapSignInButton(sender: UserProfileCollectionCell) {
        self.viewModel?.showSignInFlow()
    }
}

//extension UserProfileViewController: UserContentCollectionCellDelegate {
//    func didTapContentImage(sender: UserContentCollectionCell) {
//        self.viewModel?.showMeloPlaceDetailView(indexPath: IndexPath)
//    }
//}

//#if canImport(SwiftUI) && DEBUG
//import SwiftUI
//
//struct UserProfileViewController_Preview: PreviewProvider {
//    static var previews: some View {
//        UserProfileViewController().showPreview(.iPhone14Pro)
//    }
//}
//#endif
