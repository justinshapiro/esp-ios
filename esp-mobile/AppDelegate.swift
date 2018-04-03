//
//  AppDelegate.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 10/18/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locationManager: CLLocationManager!
    var backgroundTask = UIBackgroundTaskInvalid

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // prepare alert manager
        UserDefaults.standard.set("", forKey: "alertForLocationSent")
        
        // setup the ability to grab user location
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        
        // setup the ability to get location-autocomplete information from Google
        GMSPlacesClient.provideAPIKey("AIzaSyDN3kxrmaJKv88kLtESOSiHsq9lnPGeE-c")
        
        window = UIWindow.init(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if UserDefaults.standard.object(forKey: "loggedInUser") != nil {
            UserDefaults.standard.set(false, forKey: "rootVCIsPresent")
            window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "primaryNavigationController")
        } else {
             UserDefaults.standard.set(true, forKey: "rootVCIsPresent")
            window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "loginVC")
        }
        
        window?.makeKeyAndVisible()
        
        return true
    }
    
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        backgroundTask = application.beginBackgroundTask(withName: "ProximityCheck") {
            application.endBackgroundTask(self.backgroundTask)
            self.backgroundTask = UIBackgroundTaskInvalid
        }
        
        DispatchQueue.global().async {
            guard let location = self.locationManager.location else { return }
            let userLatitude = String(location.coordinate.latitude)
            let userLongitude = String(location.coordinate.longitude)
            ESPMobileAPI.checkForSafetyZoneProximity(with: (userLatitude, userLongitude)) {
                return
            }
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        UserDefaults.standard.removeObject(forKey: "rootVCIsPresent")
    }
}

