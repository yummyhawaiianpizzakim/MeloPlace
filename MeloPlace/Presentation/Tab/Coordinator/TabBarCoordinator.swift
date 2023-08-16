//
//  TabCoordinator.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/07.
//

import Foundation
import UIKit

enum TabBarPage: Int, CaseIterable {
    case main
    case map
    case browse
    case setting
    
    func pageTitleValue() -> String {
        switch self {
        case .main:
            return ""
        case .map:
            return ""
        case .browse:
            return ""
        case .setting:
            return ""
        }
    }
    
    func pageTabIcon() -> UIImage? {
        switch self {
        case .main:
            return UIImage(systemName: "house")
        case .map:
            return UIImage(systemName: "map")
        case .browse:
            return UIImage(systemName: "list.bullet")
        case .setting:
            return UIImage(systemName: "person")
        }
    }
}

class TabBarCoordinator: CoordinatorProtocol {
    var finishDelegate: CoordinatorFinishDelegate?
    var childCoordinators: [CoordinatorProtocol] = []
    var type: CoordinatorType = .tab
    var navigationController: UINavigationController
    private var tabBarController: UITabBarController
    private var currentPage: TabBarPage = .main
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.tabBarController = UITabBarController()
        tabBarController.tabBar.tintColor = .orange
        tabBarController.tabBar.unselectedItemTintColor = .themeGray300
        tabBarController.tabBar.backgroundColor = .white
    }
    
    func start() {
        let pages = TabBarPage.allCases
        let controllers: [UINavigationController] = pages.map { TabBarPage in
            self.getController(page: TabBarPage)
        }
        self.navigationController.setNavigationBarHidden(true, animated: true)
        self.prepareTabBarController(controllers: controllers)
    }
    
}

extension TabBarCoordinator {
    private func prepareTabBarController(controllers: [UIViewController]) {
        self.tabBarController.setViewControllers(controllers, animated: true)
        self.tabBarController.selectedIndex = TabBarPage.main.rawValue
        tabBarController.tabBar.isTranslucent = false
        tabBarController.tabBar.backgroundColor = .systemBackground
        
        navigationController.viewControllers = [tabBarController]
    }
    
    private func getController(page: TabBarPage) -> UINavigationController {
        let navigation = UINavigationController()
        
        navigation.tabBarItem = UITabBarItem.init(
            title: page.pageTitleValue(),
            image: page.pageTabIcon(),
            tag: page.rawValue
        )
        
        switch page {
        case .main:
            let mainCoordinator = MainCoordinator(navigation: navigation)
            mainCoordinator.finishDelegate = self
            self.childCoordinators.append(mainCoordinator)
            mainCoordinator.start()
        case .map:
            let mapCoordinator = MapCoordinator(navigation: navigation)
            mapCoordinator.finishDelegate = self
            self.childCoordinators.append(mapCoordinator)
            mapCoordinator.start()
        case .browse:
            let browseCoordinator = BrowseCoordinator(navigation: navigation)
            browseCoordinator.finishDelegate = self
            self.childCoordinators.append(browseCoordinator)
            browseCoordinator.start()
        case .setting:
            let settingCoordinator = SettingCoordinator(navigation: navigation)
            settingCoordinator.finishDelegate = self
            self.childCoordinators.append(settingCoordinator)
            settingCoordinator.start()
        }
        
        return navigation
    }
}

extension TabBarCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinished(childCoordinator: CoordinatorProtocol) {
        self.childCoordinators = self.childCoordinators.filter({ Coordinator in
            Coordinator.type != childCoordinator.type
        })
    }
}


