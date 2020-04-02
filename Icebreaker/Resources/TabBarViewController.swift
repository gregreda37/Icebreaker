//
//  TabBarViewController.swift
//  Icebreaker
//
//  Created by Gregory Reda on 1/31/20.
//  Copyright © 2020 Gregory Reda. All rights reserved.
//

import UIKit
import Firebase

class TabBarViewController: UITabBarController,UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        if Auth.auth().currentUser == nil {
            //show if not logged in
            DispatchQueue.main.async {
                let loginController = LoginViewController()
                let navController = UINavigationController(rootViewController: loginController)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            }
            setupTabBar()
            //return
        } else {
            setupTabBar()
            
        }
    }
    
    func setupTabBar(){
        let homeViewController = UINavigationController(rootViewController: HomeViewController())
        homeViewController.tabBarItem.image = UIImage(named: "homeIcon")
        homeViewController.title = "Home"
        
        let friendsViewController = UINavigationController(rootViewController: ContactsViewController())
        friendsViewController.tabBarItem.image = UIImage(named: "settingsBarIcon")
        friendsViewController.title = "Friends"
        

        viewControllers = [homeViewController,friendsViewController]
    }


}
