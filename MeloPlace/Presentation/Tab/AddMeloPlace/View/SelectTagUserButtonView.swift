//
//  SelectTagUserButtonView.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/10/26.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxRelay
import RxGesture

final class SelectTagUserButtonView: UIView {
    private let disposeBag = DisposeBag()
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, String>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, String>
    
    var dataSource: DataSource?
    private var snapshot: Snapshot?
    
    let deletedName = PublishRelay<String>()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textColor = .gray
        return label
    }()
    
    lazy var icon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.down")
        imageView.tintColor = .gray

        return imageView
    }()
    
    lazy var tagedUserCollectionView: UICollectionView = {
        let view = UICollectionView(
            frame: .zero,
            collectionViewLayout: TagedUserCollectionViewLeftAlignFlowLayout(offset: appOffset, direction: .horizontal))
        view.register(TagedUserCollectionCell.self, forCellWithReuseIdentifier: TagedUserCollectionCell.identifier)
        view.allowsSelection = false
        view.delegate = self
        
        return view
    }()
    
    init(text: String) {
        super.init(frame: .zero)
        label.text = text
        
        self.configureAttribute()
        self.addSubViews()
        self.makeConstraints()
        self.generateDataSource()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureAttribute() {
        self.backgroundColor = .white

        self.layer.borderColor = CGColor(gray: 10, alpha: 1)
        self.label.isUserInteractionEnabled = false
        self.icon.isUserInteractionEnabled = false
        
        self.rx.tapGesture()
            .when(.recognized)
            .bind { gesture in
                gesture.cancelsTouchesInView = false
            }
            .disposed(by: self.disposeBag)
        
    }
    
    func addSubViews() {
        [self.label, self.icon,
         self.tagedUserCollectionView].forEach {
            addSubview($0)
        }
    }
    
    func makeConstraints() {
        self.snp.makeConstraints {
            $0.height.equalTo(50.0)
        }

        self.label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview()
        }

        self.icon.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview()
            make.leading.greaterThanOrEqualTo(self.tagedUserCollectionView).offset(10)
        }
        
        self.tagedUserCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.leading.equalTo(self.label.snp.trailing).offset(10)
            make.trailing.equalTo(self.icon.snp.leading).offset(-10)
            make.height.equalTo(20)
        }
    }
}

extension SelectTagUserButtonView: UICollectionViewDelegateFlowLayout {
    private func generateDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource(collectionView: self.tagedUserCollectionView, cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
            
            guard let self,
                  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagedUserCollectionCell.identifier, for: indexPath)
                    as? TagedUserCollectionCell
            else { return UICollectionViewCell() }
            cell.didTapDeleteButton
                .bind(to: self.deletedName)
                .disposed(by: self.disposeBag)
                
            cell.configureCell(item: itemIdentifier)
            
            return cell
        })
    }
    
    func setSnapshot(models: [String]) {
        self.snapshot = Snapshot()
        guard var snapshot = self.snapshot else { return }
        snapshot.appendSections([0])
        let oldItems = snapshot.itemIdentifiers(inSection: 0)
        snapshot.deleteItems(oldItems)
        snapshot.appendItems(models, toSection: 0)
        self.dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let text = self.dataSource?.itemIdentifier(for: indexPath)
        else { return .zero }
        
        let width = "\(text)".size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)]).width + 18 + 5 + 10
        
        return CGSize(width: width, height: 20)
    }
    
    func deleteItem(item: String) {
        guard var snapshot = self.dataSource?.snapshot()
        else { return }
        snapshot.deleteItems([item])
        self.dataSource?.apply(snapshot, animatingDifferences: false)
        
    }
}
