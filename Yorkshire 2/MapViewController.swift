//
//  MapViewController.swift
//  Yorkshire 2
//
//  Created by Samuel Miller on 19/06/2022.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    
    var circle = MKCircle(center: CLLocationCoordinate2D(latitude: 1, longitude: 1), radius: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        //locationManager.delegate = self
        //locationManager.requestAlwaysAuthorization()
        mapView.addOverlay(Global.Data.yorkshirePolygon)
        var maxDist = 0.0
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                print("always i guess")
                var count = -1
                for i in Global.Data.circleOrigins {
                    count += 1
                    if count == 0 {continue}
                    
                    let x = CLLocation(latitude: Global.Data.circleOrigins[count - 1].latitude,
                                       longitude: Global.Data.circleOrigins[count - 1].longitude)
                    
                    let y = CLLocation(latitude: i.latitude, longitude: i.longitude)
                    
                    let dist = y.distance(from: x)
                    
                    if dist > maxDist {
                        maxDist = dist
                    }
                    
                    
                }
                
                //
//                let currentLocation = locationManager.location!
//                var origins = Array<CLLocationCoordinate2D>()
//                var closestDist = Double.infinity
//                var closestOrigin = CLLocation()
//                for i in Global.Data.circleOrigins {
//                    let origin = CLLocation(latitude: i.latitude, longitude: i.longitude)
//                    let dist = origin.distance(from: currentLocation)
//                    if dist < closestDist {
//                        closestDist = dist
//                        closestOrigin = origin
//                    }
//                }
//                circle = MKCircle(center: currentLocation.coordinate, radius: closestDist)
//                mapView.addOverlay(circle)
//                count = 0
//                for i in Global.Data.circleOrigins {
//                    if count % 10 == 0 {
//                        mapView.addOverlay(MKCircle(center: i, radius: maxDist / 2))
//
//                    }
//                    count += 1
//
//                }
                
                //
            }
        }
        
        //createGeofence()
        
    }
    
    func createGeofence() {
        
        guard let currentLocation = locationManager.location else { return }
        var origins = Array<CLLocationCoordinate2D>()
        var closestDist = Double.infinity
        var closestOrigin = CLLocation()
        for i in Global.Data.circleOrigins {
            let origin = CLLocation(latitude: i.latitude, longitude: i.longitude)
            let dist = origin.distance(from: currentLocation)
            if dist < closestDist {
                closestDist = dist
                closestOrigin = origin
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
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let currentLocation = locationManager.location!
        var origins = Array<CLLocationCoordinate2D>()
        var closestDist = Double.infinity
        var closestOrigin = CLLocation()
        for i in Global.Data.circleOrigins {
            let origin = CLLocation(latitude: i.latitude, longitude: i.longitude)
            let dist = origin.distance(from: currentLocation)
            if dist < closestDist {
                closestDist = dist
                closestOrigin = origin
            }
        }
        
        mapView.removeOverlay(circle)
        
        circle = MKCircle(center: currentLocation.coordinate, radius: closestDist)
        mapView.addOverlay(circle)
        createGeofence()
    }
    
    
    // MARK: - MapKit
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if (overlay is MKCircle) {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.red.withAlphaComponent(0.5)
            circle.lineWidth = 2
            
            return circle
            
        } else if (overlay is MKPolygon) {
            let polygon = MKPolygonRenderer(overlay: overlay)
            polygon.strokeColor = UIColor.green.withAlphaComponent(0.5)
            polygon.lineWidth = 2
            polygon.fillColor = UIColor.green.withAlphaComponent(0.2)
            
            return polygon
        }
        let renderer = MKTileOverlayRenderer(overlay: overlay)
        
        
        return renderer
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    

}
