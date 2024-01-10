//
//  SearchViewController.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/04.
//

import Foundation
import UIKit
import MapKit
import SnapKit
import RxSwift
import RxRelay
import RxCocoa

final class SearchViewController: UIViewController {
    var viewModel: SearchViewModel?
    let disposeBag = DisposeBag()
    
    private var dataSource: UITableViewDiffableDataSource<Int, Space>?
    
    lazy var searchBar = SearchView()
    
    private lazy var currentLocationButton = ThemeButton(title: "현재 위치 검색")
    
    private lazy var searchTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SearchTableCell.self,forCellReuseIdentifier: SearchTableCell.id)
        tableView.separatorStyle = .singleLine
        tableView.allowsSelection = true
        tableView.separatorInset = .init(top: 2.5, left: 0, bottom: 2.5, right: 0)
        tableView.delegate = self
        return tableView
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(viewModel: SearchViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.searchBar.searchTextField.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.setDataSource()
        self.bindUI()
        self.bindViewModel()
    }
}

private extension SearchViewController {
    func configureUI() {
        [self.currentLocationButton,
         self.searchTableView].forEach {
            self.view.addSubview($0)
        }
        
        self.currentLocationButton.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(36)
        }
        
        self.searchTableView.snp.makeConstraints { make in
            make.top.equalTo(self.currentLocationButton.snp.bottom).offset(5)
            make.horizontalEdges.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    func bindUI() {
        
    }
    
    func bindViewModel() {
        let input = SearchViewModel.Input(
            didEditSearchText: self.searchBar.searchTextField.rx.text.orEmpty.asObservable(),
            didTapCurrentLocationButton: self.currentLocationButton.rx.tap.asObservable(),
            didTapSearchTableCell: self.searchTableView.rx.itemSelected.asObservable()
        )
        
        let output = self.viewModel?.transform(input: input)
        
        output?.searchSpaces.asDriver(onErrorJustReturn: [])
            .compactMap { [weak self] spaces in
                self?.generateSnapshot(sources: spaces)
            }
            .drive { [weak self] snapshot in
                self?.dataSource?.apply(snapshot, animatingDifferences: false)
            }
            .disposed(by: disposeBag)
    }
    
    func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        let backButtonImage = UIImage(systemName: "arrow.left")?
            .withTintColor(.black, renderingMode: .alwaysOriginal)
        
        appearance.configureWithTransparentBackground()
        appearance.setBackIndicatorImage(backButtonImage, transitionMaskImage: backButtonImage)
        
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.titleView = searchBar
        self.navigationItem.standardAppearance = appearance
        self.navigationItem.scrollEdgeAppearance = appearance
    }
    
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70
    }
    
    func generateSnapshot(sources: [Space]) -> NSDiffableDataSourceSnapshot<Int, Space> {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Space>()
        
        snapshot.appendSections([0])
        snapshot.appendItems(sources)
        
        return snapshot
    }
    
    func setDataSource() {
        self.dataSource = UITableViewDiffableDataSource(tableView: self.searchTableView) { tableView, indexPath, itemIdentifier in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableCell.id, for: indexPath) as? SearchTableCell
            else { return UITableViewCell() }
            
            cell.configureCell(item: itemIdentifier)
            
            return cell
        }
    }
}
