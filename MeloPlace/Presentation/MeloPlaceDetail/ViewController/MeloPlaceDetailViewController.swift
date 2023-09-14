//
//  MeloPlaceViewController.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/25.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxRelay
import RxCocoa
import Kingfisher


class MeloPlaceDetailViewController: UIViewController {
    var viewModel: MeloPlaceDetailViewModel?
    let disposeBag = DisposeBag()
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, MeloPlace>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, MeloPlace>
    
    var dataSource: DataSource?
    
    private let currentIndexTrigger = PublishSubject<Void>()

    var previousOffset: CGFloat = 0
    
    lazy var scrollView = UIScrollView()
    
    lazy var mainView = MeloPlaceDetailView()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(viewModel: MeloPlaceDetailViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureAtributes()
        self.setDataSource()
        self.bindViewModel()
        self.currentIndexPathDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.currentIndexTrigger.onNext(())
        self.didLayoutSubviewsAtributes()
    }
}

private extension MeloPlaceDetailViewController {
    func configureUI() {
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.mainView)
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
    func configureAtributes() {
//        self.mainView.imageCollectionView.delegate = self
    }
    
    func bindViewModel() {
        let input = MeloPlaceDetailViewModel.Input(
            viewDidLoad: self.rx.viewDidLoad.asObservable(),
            didTapPlayPauseButton: self.mainView.playerView.playPauseButton.rx.tap.asObservable(),
            didTapPlayBackButton: self.mainView.playerView.playBackButton.rx.tap.asObservable(),
            didTapPlayNextButton: self.mainView.playerView.playNextButton.rx.tap.asObservable()
        )
        let output = self.viewModel?.transform(input: input)
        
        output?.dataSource
            .subscribe(onNext: { [weak self] (meloPlaces: [MeloPlace], indexPath: IndexPath) in
                guard let self = self else { return }
//                self.mainView.currentIndex = indexPath.row
                self.mainView.currentIndex.accept(indexPath.row)
                self.setSnapshot(models: meloPlaces)
                print("cuurrntPath::: \(indexPath)")
                self.bindMeloPlace(meloPlaces: meloPlaces)

            })
            .disposed(by: self.disposeBag)
        
        output?.isPaused
            .asDriver()
            .drive(with: self,onNext: { owner, isPaused in
                let configuration = UIImage.SymbolConfiguration(pointSize: 50, weight: .bold, scale: .large)
                if isPaused {
                    self.mainView.playerView.playPauseButton.setImage(UIImage(systemName: "play.circle.fill", withConfiguration: configuration), for: .normal)
                } else {
                    self.mainView.playerView.playPauseButton.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: configuration), for: .normal)
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    func didLayoutSubviewsAtributes() {
        self.mainView.gradientBackground.frame = self.mainView.imageBackgroundView.bounds
        self.mainView.imageBackgroundView.layer.addSublayer(self.mainView.gradientBackground)
        self.mainView.imageBackgroundView.layer.insertSublayer(self.mainView.gradientBackground, at: 0)
//        let blurEffect = UIBlurEffect(style: .light)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        let bounds = self.mainView.imageBackgroundView.bounds
//        blurEffectView.frame =  bounds
////        blurEffectView.tag = 129
//        self.mainView.imageBackgroundView.addSubview(blurEffectView)
    }
    
}

extension MeloPlaceDetailViewController {
    func setDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource(collectionView: self.mainView.imageCollectionView, cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
            
            guard let self = self, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MeloPlaceDetailCollectionCell.id, for: indexPath) as? MeloPlaceDetailCollectionCell else { return UICollectionViewCell() }
            cell.configureCell(item: itemIdentifier)
            cell.backgroundColor = .systemBackground
            return cell
        })
        
    }
    
    func setSnapshot(models: [MeloPlace]) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(models, toSection: 0)
        self.dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    func bindMeloPlace(meloPlaces: [MeloPlace]) {
        self.mainView.currentIndex
            .asDriver()
            .debounce(.seconds(1))
            .distinctUntilChanged()
            .drive { [weak self] index in
                guard let self = self else { return }
                let meloPlace = meloPlaces[index]
                print("bbbb: \(index)")
                var imageURLString = meloPlace.images.first
                self.mainView.dateLabel.text = meloPlace.memoryDate.toString()
                self.mainView.placeLabel.text = meloPlace.simpleAddress
                self.mainView.titleLabel.text = meloPlace.title
                self.mainView.contentLabel.text = meloPlace.description
                self.mainView.playerView.musicLabel.text = meloPlace.musicName
                self.mainView.playerView.artistLabel.text = meloPlace.musicArtist
//                self.mainView.setImage(imageURLString: imageURLString!)
                
                self.playMusic(index: index, meloPlaces: meloPlaces)
                
            }
            .disposed(by: self.disposeBag)
        
    }
    
    func collectionViewScroll(currentIndex: Int) {
        print(currentIndex)
        DispatchQueue.main.async {
            self.mainView.imageCollectionView.isPagingEnabled = false
            self.mainView.imageCollectionView.scrollToItem(at: IndexPath(row: currentIndex, section: 0), at: .left, animated: false)
            self.mainView.imageCollectionView.isPagingEnabled = true
        }
        
    }
    
    func currentIndexPathDidLoad() {
        currentIndexTrigger
            .take(1)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self
//                      let index = self.mainView.currentIndex
                else { return }
                let index = self.mainView.currentIndex.value
                self.collectionViewScroll(currentIndex: index)
            })
            .disposed(by: disposeBag)
    }
    
}

extension MeloPlaceDetailViewController {
    func playMusic(index: Int, meloPlaces: [MeloPlace]) {
        if !meloPlaces.isEmpty && meloPlaces.count > index {
            print("bbbb: \(index)")
            let musicURI = meloPlaces[index].musicURI
            self.viewModel?.playMusic(uri: musicURI)
        }
    }
}

// MARK: - View Controller Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct MeloPlaceDetailViewController_Preview: PreviewProvider {
    static var previews: some View {
        MeloPlaceDetailViewController().showPreview(.iPhone8)
    }
}
#endif

