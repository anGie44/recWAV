//
//  HomeViewController.swift
//  NoisyGenX
//
//  Created by AnGie on 4/24/17.
//  Copyright © 2017 AnGie. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacePicker
import DGElasticPullToRefresh
import SideMenu

class HomeViewController: UIViewController, MapDataDelegate {
    var containerViewA: LocationView!
    var containerViewB: RequestsView!
    var containerViewC: UserView!
    var formatter:DateFormatter!

    
    /* for location view */
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    let defaultLocation = CLLocation(latitude: -33.869405, longitude: 151.199)

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView(){
        
        super.loadView()
        
        self.containerViewA = LocationView()
        self.containerViewB = RequestsView()
        self.containerViewC = UserView()
        self.view = containerViewA
        setupMap()

        let segment: UISegmentedControl = UISegmentedControl(items: [UIImage(named: "world")!, UIImage(named: "stalker")!, UIImage(named: "person")!])
        segment.sizeToFit()
        segment.tintColor = .white
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(changeContainerView), for: .valueChanged)
        navigationItem.titleView = segment
        
        let menuController = SideMenuTableView()
        menuController.delegate = self
        let menuLeftNavigationController = UISideMenuNavigationController(rootViewController: menuController)
        menuLeftNavigationController.leftSide = true
        SideMenuManager.menuLeftNavigationController = menuLeftNavigationController
        
        formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        setupBarButtons()
        
        
    }
    
    func setupMap() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 10
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude, longitude: defaultLocation.coordinate.longitude, zoom: zoomLevel)
        self.containerViewA.mapView = GMSMapView.map(withFrame: self.containerViewA.bounds, camera: camera)
        self.containerViewA.mapView.delegate = self

        self.containerViewA.mapView.settings.myLocationButton = true
        self.containerViewA.mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.containerViewA.mapView.isMyLocationEnabled = true
        self.containerViewA.addSubview(self.containerViewA.mapView)
    }
    
    
    
    func changeContainerView(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 1:
                self.view = containerViewB
                setupCollectionView(setupView: "global")
                updateCollectionView(setupView: "global")
                getPosts(setupView: "global")
            case 2:
                self.view = containerViewC
//                setupCollectionView(setupView: "personal")
//                updateCollectionView(setupView: "personal")
//                getPosts(setupView: "personal")
            default:
                self.view = containerViewA
        }
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.view.isKind(of: RequestsView.self) {
            self.containerViewB.collectionView.frame = view.bounds
//            self.containerViewC.isHidden = true
        }
//        else if self.view.isKind(of: UserView.self) {
//            self.containerViewB.isHidden = true
//            self.containerViewC.collectionView.frame = view.bounds
//        }
    }
    
    func setupCollectionView(setupView: String) {
        if setupView == "global" {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.itemSize = CGSize(width: self.containerViewB.frame.width - collectionViewCellMargin * 2, height: 128.0)
            layout.minimumLineSpacing = collectionViewCellSpacing
            layout.sectionInset.top = collectionViewCellMargin
            layout.sectionInset.bottom = collectionViewCellMargin * 2
            
            self.containerViewB.collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
            self.containerViewB.collectionView.dataSource = self
            self.containerViewB.collectionView.delegate = self
            self.containerViewB.collectionView.backgroundColor = .collectionViewBackground
            self.containerViewB.collectionView.register(PostCell.self, forCellWithReuseIdentifier: "PostCellContainerB")
            self.containerViewB.collectionView.isScrollEnabled = true
            self.containerViewB.collectionView.alwaysBounceVertical = true
            self.containerViewB.addSubview(self.containerViewB.collectionView)
            
            let loadingView = DGElasticPullToRefreshLoadingViewCircle()
            loadingView.tintColor = .white
            self.containerViewB.collectionView.dg_addPullToRefreshWithActionHandler({
                self.getPosts(setupView: "global")
            }, loadingView: loadingView)
            self.containerViewB.collectionView.dg_setPullToRefreshFillColor(.blogBlue)
            self.containerViewB.collectionView.dg_setPullToRefreshBackgroundColor(self.containerViewB.collectionView.backgroundColor!)
            
            self.containerViewB.emptyLabel = UILabel()
           self.containerViewB.emptyLabel.font = UIFont(name: "Avenir-Medium", size: 24.0)
            self.containerViewB.emptyLabel.textColor = .lightGray
            self.containerViewB.emptyLabel.text = "No Requests Yet!"
            self.containerViewB.emptyLabel.sizeToFit()
            self.containerViewB.emptyLabel.center = CGPoint(x: self.containerViewB.center.x, y: self.containerViewB.center.y - (navigationController?.navigationBar.frame.maxY ?? 0.0))
            self.containerViewB.addSubview(self.containerViewB.emptyLabel)
        }
        else { // personal requests and tasks completed
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.itemSize = CGSize(width: self.containerViewC.frame.width - collectionViewCellMargin * 2, height: 128.0)
            layout.minimumLineSpacing = collectionViewCellSpacing
            layout.sectionInset.top = collectionViewCellMargin
            layout.sectionInset.bottom = collectionViewCellMargin * 2
            
            self.containerViewC.collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
            self.containerViewC.collectionView.dataSource = self
            self.containerViewC.collectionView.delegate = self
            self.containerViewC.collectionView.backgroundColor = .collectionViewBackground
            self.containerViewC.collectionView.register(PostCell.self, forCellWithReuseIdentifier: "PostCellContainerC")
            self.containerViewC.collectionView.isScrollEnabled = true
            self.containerViewC.collectionView.alwaysBounceVertical = true
            self.containerViewC.addSubview(self.containerViewB.collectionView)
            
            let loadingView = DGElasticPullToRefreshLoadingViewCircle()
            loadingView.tintColor = .white
            self.containerViewC.collectionView.dg_addPullToRefreshWithActionHandler({
                self.getPosts(setupView: "personal")
            }, loadingView: loadingView)
            self.containerViewC.collectionView.dg_setPullToRefreshFillColor(.blogBlue)
            self.containerViewC.collectionView.dg_setPullToRefreshBackgroundColor(self.containerViewC.collectionView.backgroundColor!)
            
            self.containerViewC.emptyLabel = UILabel()
            self.containerViewC.emptyLabel.font = UIFont(name: "Avenir-Medium", size: 24.0)
            self.containerViewC.emptyLabel.textColor = .lightGray
            self.containerViewC.emptyLabel.text = "No Requests Made or Completed Yet!"
            self.containerViewC.emptyLabel.sizeToFit()
            self.containerViewC.emptyLabel.center = CGPoint(x: self.containerViewC.center.x, y: self.containerViewC.center.y - (navigationController?.navigationBar.frame.maxY ?? 0.0))
            self.containerViewC.addSubview(self.containerViewC.emptyLabel)
        }
    }
    

    func getPosts(setupView: String) {
        if setupView == "global" {
            NetworkManager.getPosts(completion: { (posts: ([Post]?)) in
                if let posts = posts {
                    self.containerViewB.posts = posts
                    self.updateCollectionView(setupView: "global")
                }
            })
        }
        else {
            
        }
    }

    
    func setupBarButtons() {
        
        let menuButton = UIBarButtonItem(image: UIImage(named: "menu"), style: .done, target: self, action: #selector(menuButtonPressed))
        navigationItem.leftBarButtonItem = menuButton
        
        let requestButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(requestButtonPressed))
        navigationItem.rightBarButtonItem = requestButton
    }
    
    func menuButtonPressed() {
        SideMenuManager.menuLeftNavigationController?.navigationBar.barStyle = .black
        SideMenuManager.menuLeftNavigationController?.navigationBar.shadowImage = UIImage()
        SideMenuManager.menuLeftNavigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        SideMenuManager.menuLeftNavigationController?.navigationBar.barTintColor = .blogBlue
        SideMenuManager.menuLeftNavigationController?.navigationBar.tintColor = .white
        SideMenuManager.menuLeftNavigationController?.navigationBar.isTranslucent = false

        present(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
    }
    
    
    func handleDataCollection(state: String) -> [String : [String : String]]? {
        if state == "init" {
            return recorderLocationTracking(isRecording: true)
        }
        else if state == "fin" {
            return recorderLocationTracking(isRecording: false)
        }
        return nil
        
    }
    
    func recorderLocationTracking(isRecording: Bool) -> [String:[String:String]]? {
        if isRecording {
            containerViewA.locations = [:]
            let coordinates = ["latitude": "\((locationManager.location?.coordinate.latitude)!)", "longitude": "\((locationManager.location?.coordinate.longitude)!)"]
            self.containerViewA.locations[formatter.string(from: (locationManager.location?.timestamp)!)] = coordinates
            print ("Location Array Initialized!")
            
        }
        else {
            locationManager.stopUpdatingLocation()
            return containerViewA.locations
        }
        return nil
    }
    
    func requestButtonPressed() {
        let addPostNavigationController = UINavigationController(rootViewController: AddPostViewController())
        addPostNavigationController.navigationBar.barStyle = .black
        addPostNavigationController.navigationBar.barTintColor = .blogBlue
        addPostNavigationController.navigationBar.isTranslucent = false
        present(addPostNavigationController, animated: true, completion: nil)
    }
    
   

}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func updateCollectionView(setupView:String) {
        if setupView == "global" {
            DispatchQueue.main.async {
                self.containerViewB.posts.sort(by: {$0.date.timeIntervalSince1970 > $1.date.timeIntervalSince1970 })
                self.containerViewB.collectionView.reloadData()
                self.containerViewB.emptyLabel.isHidden = !self.containerViewB.posts.isEmpty
                self.containerViewB.collectionView.dg_stopLoading()
            }
        }
        else {
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let postDetailViewController = PostDetailViewController(post: self.containerViewB.posts[indexPath.item])
        navigationController?.pushViewController(postDetailViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.containerViewB.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.containerViewB.collectionView.dequeueReusableCell(withReuseIdentifier: "PostCellContainerB", for: indexPath) as! PostCell
        let post = self.containerViewB.posts[indexPath.item]
        
        cell.handle(post: post)
        
        return cell
    }
    
}

extension HomeViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D){
//        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
//        self.containerViewA.mapView.clear() // clearing Pin before adding new
//        let marker = GMSMarker(position: coordinate)
//        marker.map = self.containerViewA.mapView
//
        let pois = ["Sage Hall":"silence", "Duffield Hall":"chatter", "Bill and Melinda Gates Hall":"silence", "Cornell Law School":"chatter", "Statler Hall and Auditorium":"silence", "Cornell University - College of Human Ecology":"chatter", "Arts Quad":"silence"]

        let center = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
        let northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001)
        let southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        let placePicker = GMSPlacePicker(config: config)
        placePicker.pickPlace(callback: { (place, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            guard let place = place else {
                print("No place selected")
                return
            }
            let marker = GMSMarker(position: place.coordinate)
            marker.title = place.name
            if pois.keys.contains(place.name) {
                marker.snippet = "Last Heard: \(pois[place.name]!)"
            }
            else {
                marker.snippet = "Noise Status: TBD"
            }
            marker.map = self.containerViewA.mapView
            print("Place name \(place.name)")
            print("Place address \(place.formattedAddress)")
            print("Place attributions \(place.attributions)")
        })
        
    }
}
extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            print("Location: \(location)")
            if (self.containerViewA.locations) != nil {
                let coordinates = ["latitude": "\(location.coordinate.latitude)", "longitude": "\(location.coordinate.longitude)"]
                print("Latitude: \(coordinates["latitude"]!), Longitude: \(coordinates["longitude"]!)")
                self.containerViewA.locations[formatter.string(from: (location.timestamp))] = coordinates
            }
        }
        let camera = GMSMutableCameraPosition.camera(withLatitude: (locations.last?.coordinate.latitude)!, longitude: (locations.last?.coordinate.longitude)!, zoom: zoomLevel)
        
        if self.containerViewA.mapView.isHidden {
            self.containerViewA.mapView.isHidden = false
            self.containerViewA.mapView.camera = camera
        }
        else {
            self.containerViewA.mapView.animate(to: camera)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print ("Location acccess was restricted.")
        case .denied:
            print ("User denied access to location")
            self.containerViewA.mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways:
            fallthrough
        case .authorizedWhenInUse:
            print ("Location status is OK.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}
