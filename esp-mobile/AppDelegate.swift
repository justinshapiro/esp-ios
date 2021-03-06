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
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locationManager: CLLocationManager!
    var backgroundTask = UIBackgroundTaskIdentifier.invalid

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
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
        
        // show the splash screen for a fixed amount of time
        Thread.sleep(forTimeInterval: 3)
        
        // communication with AppCenter for crash reporting
        MSAppCenter.start("c93552b8-75fb-4a91-8adb-6256101a41ed", withServices: [MSAnalytics.self, MSCrashes.self])

        return true
    }


    func applicationDidEnterBackground(_ application: UIApplication) {
        backgroundTask = application.beginBackgroundTask(withName: "ProximityCheck") {
            application.endBackgroundTask(convertToUIBackgroundTaskIdentifier(self.backgroundTask.rawValue))
            self.backgroundTask = UIBackgroundTaskIdentifier.invalid
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
    
    func applicationWillTerminate(_ application: UIApplication) {
        UserDefaults.standard.removeObject(forKey: "rootVCIsPresent")
    }

    func applicationWillResignActive(_ application: UIApplication) {}
    func applicationWillEnterForeground(_ application: UIApplication) {}
    func applicationDidBecomeActive(_ application: UIApplication) {}
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIBackgroundTaskIdentifier(_ input: Int) -> UIBackgroundTaskIdentifier {
	return UIBackgroundTaskIdentifier(rawValue: input)
}
