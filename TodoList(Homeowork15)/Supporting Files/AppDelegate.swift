//
//  AppDelegate.swift
//  TodoList
//
//  Created by Рауан Бимат on 20.05.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        let navController = UINavigationController()
        let toDoListViewController = TodoListViewContrtoller()
        navController.viewControllers = [toDoListViewController]
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        return true
    }

}

