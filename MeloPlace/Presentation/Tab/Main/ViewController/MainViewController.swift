//
//  MainViewController.swift
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


class MainViewController: UIViewController {
    var viewModel: MainViewModel?
    let disposeBag = DisposeBag()
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, MeloPlace>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, MeloPlace>
    
    var dataSource: DataSource?
    
//    var centerIndex: CGFloat {
//        return self.mainCollectionView.contentOffset.x / (216.0 * 0.75 + 10)
//       }
//
    lazy var testLabel: UILabel = {
        let label = UILabel()
        label.text = "aaa"
        label.font = .systemFont(ofSize: 40)
        return label
    }()
    
    lazy var addButton: UIButton = {
        let button = UIButton()
        button.frame.size = CGSize(width: 50.0, height: 50.0)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.backgroundColor = .yellow
        button.tintColor = .black
        button.layer.cornerRadius = 50.0 / 2
        return button
    }()
    
    lazy var mainCollectionView: UICollectionView = {
        let layout = ZoomAndSnapFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.collectionViewLayout = layout
        collectionView.contentInsetAdjustmentBehavior = .always
        
        collectionView.register(MainCell.self, forCellWithReuseIdentifier: MainCell.id)
        collectionView.backgroundColor = .none
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.clipsToBounds = true
        collectionView.backgroundColor = .magenta
        return collectionView
    }()
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(viewModel: MainViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.backgroundColor = .green
        self.configureUI()
        self.setDataSource()
        self.bindViewModel()
    }
}

private extension MainViewController {
    func configureUI() {
        [self.mainCollectionView, self.addButton].forEach {
            self.view.addSubview($0)
        }
        
        self.mainCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.addButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-10)
            make.right.equalToSuperview().offset(-10)
            make.width.height.equalTo(50.0)
        }
    }
    
    func bindViewModel() {
        let input = MainViewModel.Input(
            didTapAddButton: self.addButton.rx.tap.asObservable()
        )
        
        let output = self.viewModel?.transform(input: input)
        
        output?.dataSource
            .asDriver(onErrorJustReturn: [])
            .map({[weak self] models in
                self!.generateSnapshot(models: models)
            })
            .drive(onNext: {[weak self] snapshot in
                self!.dataSource?.apply(snapshot)
            })
            .disposed(by: self.disposeBag)
        
    }
    
    func setDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource<Section, MeloPlace>(collectionView: self.mainCollectionView, cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
            guard let self = self else { return UICollectionViewCell() }
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainCell.id, for: indexPath) as? MainCell else { return UICollectionViewCell() }
            cell.configureCell(item: itemIdentifier)
            
            return cell
        })
    }
    
    func generateSnapshot(models: [MeloPlace]) -> Snapshot {
        var snapshot = Snapshot()
        if !models.isEmpty {
            snapshot.appendSections([.main])
            snapshot.appendItems(models, toSection: .main)
        } else {
            
        }
        
        return snapshot
    }
    
//    func getIndexRange(index: Int) -> ClosedRange<CGFloat> {
//        let index = CGFloat(index)
//        return (index - 0.1)...(index + 0.1)
//    }
}

extension MainViewController {
    enum Section {
        case main
    }
}
