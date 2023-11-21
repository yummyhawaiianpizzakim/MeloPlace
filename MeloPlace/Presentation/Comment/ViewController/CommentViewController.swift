//
//  CommentViewController.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/24.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxRelay
import RxCocoa
import RxGesture
import RxKeyboard
import Kingfisher

class CommentViewController: UIViewController {
    var viewModel: CommentViewModel?
    let disposeBag = DisposeBag()
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Comment>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Comment>
    
    var dataSource: DataSource?
    
    let paginationTrigger = PublishRelay<Void>()
    
    lazy var scrollView = UIScrollView()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "댓글"
        label.font = .systemFont(ofSize: 25)
        return label
    }()
    
    lazy var commentTableView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.configureLayout())
        view.register(CommentCollectionCell.self, forCellWithReuseIdentifier: CommentCollectionCell.id)
//        view.allowsSelection = false
        return view
    }()
    
    lazy var commentInputView = CommentInputView()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(viewModel: CommentViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureAttributes()
        self.configureUI()
        self.setDataSource()
        self.bindUI()
        self.bindViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
}

private extension CommentViewController {
    func configureUI() {
        self.view.addSubview(self.commentTableView)
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.commentInputView)
        
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.centerX.equalToSuperview()
        }
        
        self.commentTableView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(self.commentInputView.snp.top)
        }
        
        self.commentInputView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(56)
        }
        
    }
    
    func configureAttributes() {
        self.view.backgroundColor = .white
        self.commentTableView.layoutIfNeeded()
        
    }
    
    func bindUI() {
        RxKeyboard.instance.visibleHeight
            .skip(1)
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                guard let self else { return }
                if keyboardVisibleHeight == 0 {
                    self.updateButtonLayout(height: self.view.safeAreaInsets.bottom)
                } else {
                    self.updateButtonLayout(height: keyboardVisibleHeight)
                }
            })
            .disposed(by: disposeBag)
    }
    
    
    func bindViewModel() {
        let input = CommentViewModel.Input(
            viewWillAppear: self.rx.viewWillAppear
                .map({ _ in })
                .asObservable(),
            didTapPostWithComment: self.commentInputView.didTapPostWithText,
            pagination: self.paginationTrigger.asObservable()
        )
        
        guard let output = self.viewModel?.transform(input: input) else { return }
        
        output.comments
            .drive(onNext: {[weak self] comments in
                self?.setSnapshot(models: comments)
            })
            .disposed(by: self.disposeBag)
        
        let prefetchItemsRow = self.commentTableView.rx.prefetchItems
            .compactMap(\.last?.row)
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: 0)
            
        Driver.combineLatest(prefetchItemsRow, output.comments, output.isLastFetch)
            .filter { val in
                let (row, comments, isLastFetch) = val
                print("row:::\(row),,,, count:::\(comments.count - 1)")
                if (row == comments.count - 1) && !isLastFetch {
                    return true
                }
                return false
            }
            .drive(with: self) { owner, _ in
                owner.paginationTrigger.accept(())
            }
            .disposed(by: self.disposeBag)
    }
    
}

extension CommentViewController: UICollectionViewDelegate {
    func configureLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)

        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    func setDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource(collectionView: self.commentTableView, cellProvider: { [weak self] collectionView, indexPath, item in
            guard let self else { return UICollectionViewCell() }
            guard
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentCollectionCell.id, for: indexPath) as? CommentCollectionCell
            else { return UICollectionViewCell() }
            
            cell.didTapUserProfile
                .bind { UserID in
                    self.viewModel?.showUserProfileView(id: UserID)
                }
                .disposed(by: self.disposeBag)
            
            cell.configureCell(by: item)
            
            return cell

        })
    }

    func setSnapshot(models: [Comment]) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(models,toSection: 0)
        self.dataSource?.apply(snapshot,animatingDifferences: false)
    }
}

private extension CommentViewController {
    func updateButtonLayout(height: CGFloat) {
        UIView.animate(withDuration: 1) { [weak self] in
            guard let self else { return }
            self.commentInputView.snp.remakeConstraints { make in
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.bottom.equalToSuperview().offset( -(height) )
                make.height.equalTo(56)
            }
        }
    }
}
