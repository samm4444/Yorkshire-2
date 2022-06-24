//
//  AppDelegate.swift
//  Yorkshire 2
//
//  Created by Samuel Miller on 19/06/2022.
//

import UIKit
import MapKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

 
    var locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        var coords: Array<CLLocationCoordinate2D> = []
        if let asset = NSDataAsset(name: "coordinates") {
            let data = asset.data
            let d = try? (JSONSerialization.jsonObject(with: data, options: []) as! Array<Array<NSNumber>>)
            
            for i in d! {
                coords.append(CLLocationCoordinate2D(latitude: CLLocationDegrees(truncating: i[1]),
                                                     longitude: CLLocationDegrees(truncating: i[0])))
            }
        
        }
        Global.Data.circleOrigins = coords
        
        Global.Data.yorkshirePolygon = MKPolygon(coordinates: &coords, count: coords.count)
        
        
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        let userNotificationCenter = UNUserNotificationCenter.current()
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
            
        userNotificationCenter.requestAuthorization(options: authOptions) { (success, error) in
            if let error = error {
                print("Error: ", error)
            }
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


    
    func insideYorkshire() -> Bool {
        let renderer = MKPolygonRenderer(polygon: Global.Data.yorkshirePolygon)
        let mapPoint: MKMapPoint = MKMapPoint(locationManager.location!.coordinate)
        let polygonViewPoint: CGPoint = renderer.point(for: mapPoint)


        if renderer.path.contains(polygonViewPoint) {
            return true
        }
        return false
    }
    
    
}

