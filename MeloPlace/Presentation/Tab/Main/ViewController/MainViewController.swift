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
    let disposeBag = DisposeBag()
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, MeloPlace>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, MeloPlace>
    
    var dataSource: DataSource?
    var currentIndex = BehaviorRelay<Int>(value: 0)
    let indexPathCount = BehaviorRelay<Int>(value: 1)
    
    private lazy var placeHolderView = PlaceHolderView(text: "멜로플레이스가 없습니다.")
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24.0)
        label.textColor = .black
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    private lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20.0)
        label.textColor = .black
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20.0)
        label.textColor = .black
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    private lazy var mainCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.configureLayout())
        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.register(MainCell.self, forCellWithReuseIdentifier: MainCell.id)
        collectionView.backgroundColor = .none
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.clipsToBounds = true
        
        return collectionView
    }()
    
    private lazy var playerView = PlayerView()
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar()
    }
}

private extension MainViewController {
    func configureUI() {
        [self.mainCollectionView, self.playerView, self.titleLabel, self.addressLabel].forEach {
            self.view.addSubview($0)
        }
        
        self.addressLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(50)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        self.mainCollectionView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(self.titleLabel.snp.bottom).offset(10)
            make.height.equalTo(260)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.addressLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        self.playerView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(self.mainCollectionView.snp.bottom).offset(10)
//            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
            make.height.equalTo(150)
        }
    }
    
    func bindUI() {
        self.mainCollectionView.rx.contentOffset
            .observe(on: MainScheduler.asyncInstance)
            .bind(onNext: { [weak self] offset in
                if offset.y != 0 {
                    self?.mainCollectionView.contentOffset.y = 0
                }
            })
            .disposed(by: self.disposeBag)
        
        Observable.combineLatest(self.currentIndex.distinctUntilChanged(), self.viewModel!.meloPlaces)
            .asDriver(onErrorJustReturn: (0, []))
            .drive(with: self) { owner, val in
                let (currentIndex, meloPlaces) = val
                if meloPlaces.count - 1 > currentIndex {
                    owner.playerView.isEnabledNextButton = true
                } else {
                    owner.playerView.isEnabledNextButton = false
                }
                
                if currentIndex > 0 {
                    owner.playerView.isEnableBackButton = true
                } else {
                    owner.playerView.isEnableBackButton = false
                }
            }
            .disposed(by: self.disposeBag)
        
        self.playerView.playNextButton.rx.tap
            .withUnretained(self)
            .bind { owner, _ in
                owner.scrollToNextCell(index: owner.currentIndex.value)
            }
            .disposed(by: self.disposeBag)
        
        self.playerView.playBackButton.rx.tap
            .withUnretained(self)
            .bind { owner, _ in
                owner.scrollToBackCell(index: owner.currentIndex.value)
            }
            .disposed(by: self.disposeBag)
        
    }
    
    func bindViewModel() {
        let input = MainViewModel.Input(
            viewWillAppear: self.rx.viewWillAppear.map({ _ in ()}).asObservable(),
            didSelectItem: self.mainCollectionView.rx.itemSelected.asObservable(),
            didTapPlayPauseButton: self.playerView.playPauseButton.rx.tap.asObservable()
        )
        
        let output = self.viewModel?.transform(input: input)
        
        output?.dataSource
            .compactMap({[weak self] models in
                self?.configurePlaceHolderView(with: models)
                self?.indexPathCount.accept(models.count)
                self?.bindPlayingMusic(meloPlaces: models)
                self?.bindView(meloPlaces: models)
                self?.bindPlayer(meloPlaces: models)
                return self!.generateSnapshot(models: models)
            })
            .drive(onNext: {[weak self] snapshot in
                self!.dataSource?.apply(snapshot)
            })
            .disposed(by: self.disposeBag)
        
        output?.isPaused
            .drive(with: self,onNext: { owner, isPaused in
                self.playerView.bindPlayerController(isPaused: isPaused)
                
            })
            .disposed(by: self.disposeBag)
    }
    
    func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()

        appearance.configureWithTransparentBackground()
        self.navigationItem.title = "뮤직 플레이어"
        self.navigationItem.standardAppearance = appearance
        self.navigationItem.scrollEdgeAppearance = appearance
    }
    
    func configurePlaceHolderView(with meloPlaces: [MeloPlace]) {
        if meloPlaces.isEmpty {
            self.view.addSubview(self.placeHolderView)
            
            self.placeHolderView.snp.makeConstraints { make in
                make.edges.equalTo(self.view.safeAreaLayoutGuide)
            }
        } else {
            self.placeHolderView.removeFromSuperview()
        }
    }
    
    func bindView(meloPlaces: [MeloPlace]) {
        Driver.combineLatest(
            self.currentIndex.asDriver()
                .debounce(.milliseconds(200))
                .distinctUntilChanged(),
            Driver.of(meloPlaces)
        )
        .drive(onNext: { [weak self] index, meloPlaces in
            guard let self = self else { return }
            if !meloPlaces.isEmpty && meloPlaces.count > index {
                let meloPlace = meloPlaces[index]
                let spaceName = meloPlace.spaceName.replaceString(where: "대한민국", of: "대한민국 ", with: "")
                self.addressLabel.text = "\(meloPlace.memoryDate.toString()) \(spaceName)에서"
                self.titleLabel.text = meloPlace.title
            }
        })
        .disposed(by: self.disposeBag)
    }
    
    func bindPlayingMusic(meloPlaces: [MeloPlace]) {
        Driver.combineLatest(
            self.currentIndex.asDriver()
                .debounce(.milliseconds(100))
                .distinctUntilChanged(),
            Driver.of(meloPlaces)
        )
        .drive(onNext: { [weak self] index, meloPlaces in
            guard let self = self else { return }
            if !meloPlaces.isEmpty && meloPlaces.count > index {
                print("bbbb: \(index)")
                let musicURI = meloPlaces[index].musicURI
                self.viewModel?.playMusic(uri: musicURI)
            }
        })
        .disposed(by: self.disposeBag)
    }
    
    func bindPlayer(meloPlaces: [MeloPlace]) {
        Driver.combineLatest(
            self.currentIndex.asDriver()
                .debounce(.milliseconds(100))
                .distinctUntilChanged(),
            Driver.of(meloPlaces)
        )
        .drive { [weak self] index, meloPlaces in
            if !meloPlaces.isEmpty && meloPlaces.count > index {
                let meloPlace = meloPlaces[index]
                self?.playerView.bindPlayerView(meloPlace: meloPlace)
                
            }
        }
        .disposed(by: self.disposeBag)
        
    }
    
}

private extension MainViewController {
    func configureLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(240), heightDimension: .absolute(240))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(240), heightDimension: .absolute(240))
        
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
                    centerItemIndex = item.indexPath.item
                }
                
                if self.currentIndex.value != centerItemIndex {
                    self.currentIndex.accept(centerItemIndex ?? 0)
                }

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

private extension MainViewController {
    func scrollToNextCell(index: Int) {
        guard let meloPlaces = self.viewModel?.meloPlaces.value else { return }
        if meloPlaces.count - 1 > self.currentIndex.value {
            let nextIndexPath = IndexPath(item: index + 1, section: 0)
            DispatchQueue.main.async {
                self.mainCollectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
            }
        }
    }
    
    func scrollToBackCell(index: Int) {
        guard let meloPlaces = self.viewModel?.meloPlaces.value else { return }
        let preIndexPath = IndexPath(item: index - 1, section: 0)
        DispatchQueue.main.async {
            self.mainCollectionView.scrollToItem(at: preIndexPath, at: .centeredHorizontally, animated: true)
        }
    }
}

extension MainViewController {
    enum Section {
        case main
    }
}
