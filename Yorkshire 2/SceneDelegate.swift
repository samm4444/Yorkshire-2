//
//  SceneDelegate.swift
//  Yorkshire 2
//
//  Created by Samuel Miller on 19/06/2022.
//

import UIKit
import MapKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    var locationManager = CLLocationManager()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        self.locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        createGeofence()
        guard let _ = (scene as? UIWindowScene) else { return }
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

// MARK: - Map stuff

extension SceneDelegate: CLLocationManagerDelegate {
    // called when user Exits a monitored region
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("event called")
        if region is CLCircularRegion {
            // Do what you want if this information
            self.handleEvent(forRegion: region)
        }
    }
    
    // called when user Enters a monitored region
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
       
        if region is CLCircularRegion {
            // Do what you want if this information
            self.handleEvent(forRegion: region)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        manager.requestAlwaysAuthorization()
    }
    
    func handleEvent(forRegion: CLRegion) {
        createGeofence()
        
        
        var coords: Array<CLLocationCoordinate2D> = []
        if let asset = NSDataAsset(name: "coordinates") {
            let data = asset.data
            let d = try? (JSONSerialization.jsonObject(with: data, options: []) as! Array<Array<NSNumber>>)
            
            for i in d! {
                coords.append(CLLocationCoordinate2D(latitude: CLLocationDegrees(truncating: i[1]),
                                                     longitude: CLLocationDegrees(truncating: i[0])))
            }
        
        }
        
        let yorkshirePolygon = MKPolygon(coordinates: &coords, count: coords.count)
        
        
        var inside = false
        let locationManager = CLLocationManager()
        
        let renderer = MKPolygonRenderer(polygon: yorkshirePolygon)
        let mapPoint: MKMapPoint = MKMapPoint(locationManager.location!.coordinate)
        let polygonViewPoint: CGPoint = renderer.point(for: mapPoint)


        if renderer.path.contains(polygonViewPoint) {
            inside = true
        } else {
            inside = false
        }
        
        
        let checked = UserDefaults.standard.bool(forKey: "checkedPosition")
        let previousInside = UserDefaults.standard.bool(forKey: "previousInside")
        
        if !checked {
            UserDefaults.standard.setValue(true, forKey: "checkedPosition")
            UserDefaults.standard.setValue(inside, forKey: "previousInside")
            return
        }
        
        if previousInside == inside {

            return
        }
        
        if !inside {
            UserDefaults.standard.setValue(inside, forKey: "previousInside")
            let userNotificationCenter = UNUserNotificationCenter.current()
            // Create new notifcation content instance
            let notificationContent = UNMutableNotificationContent()

            // Add the content to the notification content
            notificationContent.title = "⚠️ You're leaving Yorkshire ⚠️"
            notificationContent.body = "Be careful!"
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1,
                                                            repeats: false)
            
            let request = UNNotificationRequest(identifier: "testNotification",
                                                content: notificationContent,
                                                trigger: trigger)
            
            userNotificationCenter.add(request) { (error) in
                if let error = error {
                    print("Notification Error: ", error)
                }
            }
            return
        }
        
        if inside {
            UserDefaults.standard.setValue(inside, forKey: "previousInside")
            let userNotificationCenter = UNUserNotificationCenter.current()
            // Create new notifcation content instance
            let notificationContent = UNMutableNotificationContent()

            // Add the content to the notification content
            notificationContent.title = "✅ You have entered Yorkshire ✅"
            notificationContent.body = "Welcome!"
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1,
                                                            repeats: false)
            
            let request = UNNotificationRequest(identifier: "testNotification",
                                                content: notificationContent,
                                                trigger: trigger)
            
            userNotificationCenter.add(request) { (error) in
                if let error = error {
                    print("Notification Error: ", error)
                }
            }
            return
        }
        
        
        
    }
    
    
    func createGeofence() {
        
        guard let currentLocation = locationManager.location else { return }
        var origins: Array<CLLocationCoordinate2D> = []
        if let asset = NSDataAsset(name: "coordinates") {
            let data = asset.data
            let d = try? (JSONSerialization.jsonObject(with: data, options: []) as! Array<Array<NSNumber>>)
            
            for i in d! {
                origins.append(CLLocationCoordinate2D(latitude: CLLocationDegrees(truncating: i[1]),
                                                     longitude: CLLocationDegrees(truncating: i[0])))
            }
        
        }
        var closestDist = Double.infinity
        for i in Global.Data.circleOrigins {
            let origin = CLLocation(latitude: i.latitude, longitude: i.longitude)
            let dist = origin.distance(from: currentLocation)
            if dist < closestDist {
                closestDist = dist
                //closestOrigin = origin
            }
        }
        
        
        
        let region = CLCircularRegion(center: currentLocation.coordinate,
                                      radius: closestDist,
                                      identifier: "centre")
        region.notifyOnExit = true
        region.notifyOnEntry = false
        locationManager.startMonitoring(for: region)
        
    }
    
    func mod(_ a: Int, _ n: Int) -> Int {
        precondition(n > 0, "modulus must be positive")
        let r = a % n
        return r >= 0 ? r : r + n
    }
    
    
}
