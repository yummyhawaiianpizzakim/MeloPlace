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
import SpotifyiOS


class MainViewController: UIViewController {
    var viewModel: MainViewModel?
    var service = SpotifyService.shared
    let disposeBag = DisposeBag()
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, MeloPlace>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, MeloPlace>
    
    var dataSource: DataSource?
    var currentIndex = BehaviorRelay<Int>(value: 0)
//    var itemCount: Int?
    let indexPathCount = BehaviorRelay<Int>(value: 1)
    
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
//        let layout = HSCycleGalleryViewLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.configureLayout())
//        collectionView.collectionViewLayout = layout
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.register(MainCell.self, forCellWithReuseIdentifier: MainCell.id)
        collectionView.backgroundColor = .none
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.clipsToBounds = true
        collectionView.backgroundColor = .magenta
        return collectionView
    }()
    
    lazy var playPauseButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 50, weight: .bold, scale: .large)
        button.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: configuration), for: .normal)
        return button
    }()
    
    lazy var nextButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 50, weight: .bold, scale: .large)
        button.setImage(UIImage(systemName: "chevron.right.to.line", withConfiguration: configuration), for: .normal)
        return button
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
        self.configureUI()
        self.setDataSource()
        self.bindUI()
        self.bindViewModel()
    }
}

private extension MainViewController {
    func configureUI() {
        [self.mainCollectionView, self.addButton, self.playPauseButton, self.nextButton].forEach {
            self.view.addSubview($0)
        }
        
        self.mainCollectionView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(20)
        }
        self.addButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-10)
            make.right.equalToSuperview().offset(-10)
            make.width.height.equalTo(50.0)
        }
        
        self.playPauseButton.snp.makeConstraints { make in
            make.top.equalTo(self.mainCollectionView.snp.bottom).offset(10)
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.width.equalTo(50)
        }
        
        self.nextButton.snp.makeConstraints { make in
            make.top.equalTo(self.playPauseButton.snp.top)
            make.bottom.equalToSuperview()
            make.leading.equalTo(self.playPauseButton.snp.trailing).offset(20)
            make.height.width.equalTo(50)
        }
    }
    
    func bindUI() {
//        self.nextButton.rx.tap.asObservable()
//            .subscribe { [weak self] _ in
//                self?.scrollToNextCell()
//            }
//            .disposed(by: self.disposeBag)
        
    }
    
    func bindViewModel() {
        let input = MainViewModel.Input(
            viewWillAppear: self.rx.viewWillAppear.map({ _ in () }),
            didSelectItem: self.mainCollectionView.rx.itemSelected.asObservable(),
            didTapAddButton:  self.addButton.rx.tap.asObservable(),
            didTapPlayPauseButton: self.playPauseButton.rx.tap.asObservable()
        )
        
        let output = self.viewModel?.transform(input: input)
        
        output?.dataSource
            .asDriver(onErrorJustReturn: [])
            .map({[weak self] models in
                self?.indexPathCount.accept(models.count)
                self?.bindPlayingMusic()
                return self!.generateSnapshot(models: models)
            })
            .drive(onNext: {[weak self] snapshot in
                self!.dataSource?.apply(snapshot)
            })
            .disposed(by: self.disposeBag)
        
        output?.isPaused
            .asDriver()
            .drive(with: self,onNext: { owner, isPaused in
                let configuration = UIImage.SymbolConfiguration(pointSize: 50, weight: .bold, scale: .large)
                if isPaused {
                    self.playPauseButton.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: configuration), for: .normal)
                } else {
                    self.playPauseButton.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: configuration), for: .normal)
                }
            })
            .disposed(by: self.disposeBag)
        
//        output?.music
//            .asDriver(onErrorJustReturn: nil)
//            .drive(onNext: {[weak self] music in
//                guard let music = music else { return }
//                self?.service.playMusic(uri: music.URI)
//            })
//            .disposed(by: self.disposeBag)
        
    }
    
    func bindPlayingMusic() {
        guard let meloPlaces = self.viewModel?.meloPlaces.asDriver() else { return }
        Driver.combineLatest(
            self.currentIndex.asDriver()
                .debounce(.seconds(1))
                .distinctUntilChanged(),
            meloPlaces
        )
        .drive(onNext: { [weak self] index, meloPlaces in
            guard let self = self else { return }
            if !meloPlaces.isEmpty && meloPlaces.count > index {
                print("bbbb: \(index)")
                var musicURI = meloPlaces[index].musicURI
                self.viewModel?.playMusic(uri: musicURI)
            }
        })
        .disposed(by: self.disposeBag)
    }
    
}

private extension MainViewController {
    func configureLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(250), heightDimension: .absolute(400))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(250), heightDimension: .absolute(400))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, offset, environment in
            guard let self = self else { return }
            let cellItems = visibleItems.filter {
                  $0.representedElementKind != UICollectionView.elementKindSectionHeader
                }
            let containerWidth = environment.container.contentSize.width
            
            var minDistanceFromCenter: CGFloat = .greatestFiniteMagnitude
            var centerItemIndex: Int?
//            let centerItemIndex = BehaviorRelay<Int>(value: 0)
            
            cellItems.forEach { item in
                let itemCenterRelativeToOffset = item.frame.midX - offset.x
                
                // 셀이 컬렉션 뷰의 중앙에서 얼마나 떨어져 있는지
                let distanceFromCenter = abs(itemCenterRelativeToOffset - containerWidth / 2.0)
                
                // 셀이 커지고 작아질 때의 최대 스케일, 최소 스케일
                let minScale: CGFloat = 0.7
                let maxScale: CGFloat = 1.0
                let scale = max(maxScale - (distanceFromCenter / containerWidth), minScale)
                
                item.transform = CGAffineTransform(scaleX: scale, y: scale)
                
                if distanceFromCenter < minDistanceFromCenter {
                    minDistanceFromCenter = distanceFromCenter
//                    Driver.just(item.indexPath.item)
//                        .debounce(.seconds(1))
//                        .distinctUntilChanged()
//                        .drive { index in
//                            centerItemIndex = index
//                        }
//                        .disposed(by: self.disposeBag)
//
                    centerItemIndex = item.indexPath.item
                }
                
                if self.currentIndex.value != centerItemIndex {
                    self.currentIndex.accept(centerItemIndex ?? 0)
                }
//                print("The index of the centered item is: \(centerItemIndex ?? -1)")

            }
            
        }

        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    func setDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource<Section, MeloPlace>(collectionView: self.mainCollectionView, cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
            guard let self = self else { return UICollectionViewCell() }
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainCell.id, for: indexPath) as? MainCell else { return UICollectionViewCell() }
            cell.configureCell(item: itemIdentifier)
//            self.viewModel?.playMusic(indexPath: indexPath)
            
//            self.nextButton.rx.tap.asObservable()
//                .subscribe { _ in
//                    self.scrollToNextCell(indexPath: indexPath)
//                }
//                .disposed(by: self.disposeBag)
            
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
    
}

extension MainViewController {
    func scrollToNextCell(indexPath: IndexPath) {
        let nextIndexPath = IndexPath(item: indexPath.item + 1, section: indexPath.section)
        
        DispatchQueue.main.async {
            self.mainCollectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
        }
        
    }
    
}

extension MainViewController {
    enum Section {
        case main
    }
}
