//
//  TabController.swift
//  Vion
//
//  Created by Jarrod Norwell on 7/5/2026.
//

import UIKit

class TabController : UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let viewController: GamesController = GamesController(collectionViewLayout: LayoutManager.shared.library)
        viewController.tabBarItem = UITabBarItem(title: "Games", image: UIImage(systemName: "opticaldisc.fill"), tag: 0)
        
        let viewController2: UIViewController = UIViewController()
        viewController2.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape.fill"), tag: 1)
        
        let navigationController: UINavigationController = UINavigationController(rootViewController: viewController)
        // let navigationController2: UINavigationController = UINavigationController(rootViewController: viewController2)
        
        viewControllers = [
            navigationController
            //navigationController2
        ]
    }
}
