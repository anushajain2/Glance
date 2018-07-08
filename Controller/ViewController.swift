//
//  ViewController.swift
//  Glance
//
//  Created by Anusha on 9/22/17.
//  Copyright © 2017 Anusha. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreLocation
import ARCL
import Firebase
import GeoFire

class ViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate, SceneLocationViewDelegate {

    let sceneLocationView = SceneLocationView()
    var adjustNorthByTappingSidesOfScreen = false
    
    var geoFireRef: DatabaseReference?
    var geoFire: GeoFire?
    
    var nearbyUsers = [String]()
    var circleQuery = GFQuery()
    let userID = (Auth.auth().currentUser?.uid)!
    
    let locmanager = CLLocationManager()
    var myLocation = CLLocation(latitude: 0, longitude: 0)
    
    
    var infoNode = InfoNode()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Update location of current user
        let loc = locations[0]
        myLocation = CLLocation(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
        
        geoFire!.setLocation(myLocation, forKey: userID)
        
        circleQuery = (geoFire?.query(at: myLocation, withRadius: 100/1000))!
        circleQuery.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
            if !self.nearbyUsers.contains(key!) && key != self.userID {
                self.nearbyUsers.append(key!)
            }
        })
        
        var pinLocationNodes: [LocationAnnotationNode] = []
        
        
        for user in nearbyUsers {
            print(user)
            Database.database().reference().child("users").child(user).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let info = value?["info"] as! NSString
                self.infoNode.textImage = self.textToImage(drawText: info, inImage: self.infoNode.pinImage, atPoint: CGPoint(x: 50, y: 50))
            })
            geoFire?.getLocationForKey(user, withCallback: { (location, error) in
                if (error != nil) {
                    print("An error occurred getting the location")
                } else if (location != nil){
                    let pinLocationNode = LocationAnnotationNode(location: location, image: self.infoNode.textImage)
                    pinLocationNodes.append(pinLocationNode)
                    pinLocationNode.scaleRelativeToDistance = true
                    self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: pinLocationNode)
                } else {
                    print("GeoFire does not contain a location")
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Set the view's delegate
        sceneView.delegate = self
 
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene */
        
        locmanager.delegate = self
        locmanager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locmanager.requestAlwaysAuthorization()
        locmanager.startUpdatingLocation()
        
        sceneLocationView.locationEstimateMethod = .mostRelevantEstimate
        sceneLocationView.showAxesNode = true
        sceneLocationView.locationDelegate = self
        
        geoFireRef = Database.database().reference().child("locations")
        geoFire = GeoFire(firebaseRef: geoFireRef)
        
        
        /*
        Database.database().reference().child("users").observeSingleEvent(of: .value) { (snapshot) in
            for rest in snapshot.children.allObjects as! [DataSnapshot] {
                guard let value = rest.value as? NSDictionary else { continue }
                let info = value["info"] as! NSString
                print(value)
                self.infoNode.textImage = self.textToImage(drawText: info, inImage: self.infoNode.pinImage, atPoint: CGPoint(x: 50, y: 50))
                let pinLocationNode = LocationAnnotationNode(location: self.myLocation, image: self.infoNode.textImage)
                pinLocationNodes.append(pinLocationNode)
                self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: pinLocationNode)
            }
        } */
        
        
        view.addSubview(sceneLocationView)
    }
    
    func textToImage(drawText text: NSString, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        let textColor = UIColor.white
        let textFont = UIFont(name: "Helvetica Bold", size: 12)!
        
        
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        let textFontAttributes = [
            NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): textFont,
            NSAttributedStringKey.foregroundColor: textColor,
            ] as [NSAttributedStringKey : Any]?
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        
      //  let rect = CGRect(origin: point, size: image.size)
        
        let textSize = text.size(withAttributes: textFontAttributes)
        let rect = CGRect(x: image.size.width / 2 - textSize.width / 2, y: 0, width: image.size.width / 2 + textSize.width / 2, height: image.size.height - textSize.height)
        
        text.draw(in: rect, withAttributes: textFontAttributes)
        
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
       // let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
       // sceneView.session.run(configuration)
        
        sceneLocationView.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
      //  sceneView.session.pause()
        sceneLocationView.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = CGRect(
            x: 0,
            y: 0,
            width: self.view.frame.size.width,
            height: self.view.frame.size.height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        
    }
    
    func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        
    }
    
    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {
        
    }
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
        
    }
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {
        
    }
}
