//
//  SearchUserViewController.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/10/09.
//

import Foundation
import UIKit
import MapKit
import SnapKit
import RxSwift
import RxRelay
import RxCocoa


class SearchUserViewController: UIViewController {
    var viewModel: SearchUserViewModel?
    let disposeBag = DisposeBag()
    
    private var dataSource: UITableViewDiffableDataSource<Int, User>?
    
    lazy var searchBar = SearchView()
    
    private lazy var searchTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SearchUserTableCell.self, forCellReuseIdentifier: SearchUserTableCell.id)
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
    
    convenience init(viewModel: SearchUserViewModel) {
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

private extension SearchUserViewController {
    func configureUI() {
        [self.searchTableView].forEach {
            self.view.addSubview($0)
        }
        
        self.searchTableView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(10)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    func bindUI() {
        
    }
    
    func bindViewModel() {
        let input = SearchUserViewModel.Input(
            didEditSearchText: self.searchBar.searchTextField.rx.text.orEmpty.asObservable(),
            didTapSearchTableCell: self.searchTableView.rx.itemSelected
                .do(onNext: { [weak self] indexPath in
                    self?.searchTableView.deselectRow(at: indexPath, animated: false)
                }).asObservable()
        )
        
        let output = self.viewModel?.transform(input: input)
            
        output?.searchedUser
            .compactMap({ [weak self] users in
                self?.generateSnapshot(sources: users)
            })
            .drive(onNext: { [weak self] snapshot in
                self?.dataSource?.apply(snapshot, animatingDifferences: false)
            })
            .disposed(by: self.disposeBag)
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
    
    func generateSnapshot(sources: [User]) -> NSDiffableDataSourceSnapshot<Int, User> {
        var snapshot = NSDiffableDataSourceSnapshot<Int, User>()
        
        snapshot.appendSections([0])
        snapshot.appendItems(sources)
        
        return snapshot
    }
    
    func setDataSource() {
        self.dataSource = UITableViewDiffableDataSource(tableView: self.searchTableView) { tableView, indexPath, itemIdentifier in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchUserTableCell.id, for: indexPath) as? SearchUserTableCell
            else { return UITableViewCell() }
            
            cell.configureCell(item: itemIdentifier)
            
            return cell
        }
    }
}
