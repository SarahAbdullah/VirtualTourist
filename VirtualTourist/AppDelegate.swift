//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Sarah on 1/25/19.
//  Copyright © 2019 Sarah. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    
    var window: UIWindow?
    let dataController = DataController(modelName:"VirtualTourist") 


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        dataController.load()
        let navigationController = window?.rootViewController as! UINavigationController
        let travelLocationsMapView = navigationController.topViewController as! TravelLocationsMapView
        //Injecting the DataController Dependency
        travelLocationsMapView.dataController = dataController
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        saveViewContext()
    
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveViewContext()
    }

    func saveViewContext() {
        try? dataController.viewContext.save()
    }

}

