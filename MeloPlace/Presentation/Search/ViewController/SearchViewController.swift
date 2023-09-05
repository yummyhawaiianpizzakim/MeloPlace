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


class SearchViewController: UIViewController {
    var viewModel: SearchViewModel?
    let disposeBag = DisposeBag()
    
    private var dataSource: UITableViewDiffableDataSource<Int, Space>?
    
    lazy var searchBar = SearchView()
    
//    private lazy var currentLocationButton = TrinapButton(style: .secondary).than {
//        $0.setTitle("현재 위치", for: .normal)
//        $0.setTitleColor(TrinapAsset.white.color, for: .normal)
//        $0.titleLabel?.font = TrinapFontFamily.Pretendard.bold.font(size: 16)
//    }
//
//    lazy var button: UIButton = {
//        let button = UIButton()
//        button.setTitle("현재 위치", for: .normal)
//        button.setTitleColor(.white, for: .normal)
//        button.tit
//        return button
//    }()
    
    private lazy var searchTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SearchTableCell.self,forCellReuseIdentifier: SearchTableCell.id)
        tableView.separatorStyle = .none
        tableView.allowsSelection = true
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
        self.navigationController?.isNavigationBarHidden = false
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
        [self.searchTableView].forEach {
            self.view.addSubview($0)
        }
        
        self.searchTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func bindUI() {
        
    }
    
    func bindViewModel() {
        let input = SearchViewModel.Input(
            didEditSearchText: self.searchBar.searchTextField.rx.text.orEmpty.asObservable(),
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
        
        self.navigationItem.titleView = searchBar
        self.navigationItem.standardAppearance = appearance
        self.navigationItem.scrollEdgeAppearance = appearance
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
