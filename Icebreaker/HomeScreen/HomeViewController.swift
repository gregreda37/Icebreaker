//
//  HomeViewController.swift
//  Icebreaker
//
//  Created by Gregory Reda on 1/31/20.
//  Copyright © 2020 Gregory Reda. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class HomeViewController: UICollectionViewController,LoginViewControllerDelegate,UICollectionViewDelegateFlowLayout,CLLocationManagerDelegate,MyCardViewControllerDelegate,HomeViewControllerHeaderDelegate{

    let cellId = "cellIds"
    let locationManager = CLLocationManager()
    
    var locations = [String]()
    var longitude: Double?
    var latitude: Double?
    
    var user: User?
    
    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        collectionView?.register(HomeViewControllerHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId")

        collectionView?.register(UserProfileCell.self, forCellWithReuseIdentifier: cellId)
        
        setupNavigationBarItems()
        locationServices()
        fetchCurrentUser()
        
        

    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if Auth.auth().currentUser == nil {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! HomeViewControllerHeader
            print("non logged in")
            header.delegate = self
            return header
        } else {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! HomeViewControllerHeader
            print("logged in")
            header.delegate = self
            header.searchBar.text = ""
            return header
        }
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }


    fileprivate func fetchCurrentUser(){
        //fetch current user
        let uid = Auth.auth().currentUser?.uid ?? ""
        
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
                if let err = err {
                    print(err)
                    return
                }
                guard let dictionary = snapshot?.data() else { return }
                self.user = User(dictionary: dictionary)
                
            }
    }
    
  
    var users = [User]()
  
    var filteredUsers = [User]()
    
    func searchDidChange(string: String) {
        self.isSearching = true
        filteredUsers = self.users.filter { (user) -> Bool in
            return user.name.contains(string)
        }
        self.collectionView?.reloadData()
        print(string)
    }

    @objc func locationServices(){
        self.locationManager.requestAlwaysAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            // Your coordinates go here (lat, lon)
            let geofenceRegionCenter = CLLocationCoordinate2D(
                latitude: latitude ?? 1,
                longitude: longitude ?? 1
            )

            let geofenceRegion = CLCircularRegion(
                center: geofenceRegionCenter,
                radius: 1,
                identifier: "UniqueIdentifier"
            )

            self.locationManager.startMonitoring(for: geofenceRegion)

            self.fetchLocalProfiles()
        }

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 1000
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate

        print("THESE ARE MY COORDINATES")
        latitude = locValue.latitude
        longitude = locValue.longitude
        let uid = Auth.auth().currentUser?.uid ?? ""
        Firestore.firestore().collection("users").document(uid).setData(["coordinates":[locValue.latitude,locValue.longitude]], merge: true) { (err) in
            if let err = err {
                print(err)
                return
            }
            print("Uploaded")
        }
        print(locValue.latitude)
        print(locValue.longitude)
        

    }
    
    fileprivate func fetchLocalProfiles(){
        let query = Firestore.firestore().collection("users")
            
            query.getDocuments { (snapshot, err) in
                if let err = err {
                    print("failed to fetch users", err)
                    return
                }
                
                snapshot?.documents.forEach({ (DocumentSnapshot) in
                let userDictionary = DocumentSnapshot.data()

                    let coordinates = userDictionary["coordinates"] as! [Any]
                    let latitudeMerchant = coordinates[0] as? Double ?? -122.29924209
                    let longitudeMerchant = coordinates[1] as? Double ?? 37.479283

                    let coordinate0 = CLLocation(latitude: self.latitude ?? 1, longitude: self.longitude ?? 1)
                    let coordinate1 = CLLocation(latitude: latitudeMerchant, longitude: longitudeMerchant)
                    let distanceInMeters = coordinate0.distance(from: coordinate1) // result is in meters
                    //distance in meters
        
                    let convertedMeters = (10*1609)
                    
                    if(Int(distanceInMeters) <= convertedMeters) {
                        let uid = userDictionary["uid"] as? String
                        self.locations.append(uid!)
                        print("added to array")
                    } else {
                        print("Over Requested Radius: Not Saving to Array")
                        
                    }
                })
            }
        
        //fetchUsers()
    }

    fileprivate func fetchUsers(){
        self.users.removeAll()
        let collection = Firestore.firestore().collection("users")
        
        collection.getDocuments { (snapshot, err) in
            if let err = err {
            print("failed to fetch users", err)
            return
        }
            snapshot?.documents.forEach({ (DocumentSnapshot) in
                let userDictionary = DocumentSnapshot.data()
                
                let user = User(dictionary: userDictionary)
                
                if user.uid == Auth.auth().currentUser?.uid ?? "" {
                    
                } else if self.locations.contains(user.uid ?? "") {
                    self.users.append(user)
                    
                }
            })
            self.collectionView?.refreshControl?.endRefreshing()
            self.collectionView?.reloadData()
        }
        
    }


    func setupNavigationBarItems(){
        setupLeftNavItem()
        setupRightNavItems()
    }

    
    private func setupLeftNavItem(){
        let shareButton = UIButton(type: .system)
        shareButton.setImage(#imageLiteral(resourceName: "shareButton").withRenderingMode(.alwaysOriginal), for: .normal)
        shareButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        shareButton.addTarget(self, action: #selector(postViewController), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: shareButton)
    }
    
    func pushSettingsController(){
        let settingsViewController = UserProfileViewController()
        settingsViewController.userId = user
        navigationController?.pushViewController(settingsViewController, animated: true)
        
    }
    
    @objc fileprivate func postViewController(){
        let registrationController = RegisterEventViewController()
        present(registrationController, animated: true)
        
    }

    @objc fileprivate func logout(){
        try? Auth.auth().signOut()
        print("User Signed Out")
        let vc = LoginViewController()
        vc.delegate = self
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
        
    }

    
    private func setupRightNavItems() {
        let postButton = UIButton(type: .system)
        postButton.setImage(#imageLiteral(resourceName: "qrTopRightCorner").withRenderingMode(.alwaysOriginal), for: .normal)
        postButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        postButton.addTarget(self, action: #selector(cardViewController), for: .touchUpInside)
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: postButton)]
        navigationItem.title = "Local Users"
    }
    
    @objc fileprivate func cardViewController(){
        let myCardViewController = MyCardViewController()
        let image = generateQRCode(from: user?.uid ?? "")
        myCardViewController.qrCodeView.image = image
        myCardViewController.loadImage(imageUrl1: user?.imageUrl1 ?? "")
        myCardViewController.usernameTextField.text = user?.name ?? ""
        myCardViewController.delegate = self
        myCardViewController.modalPresentationStyle = .fullScreen
        present(myCardViewController, animated: true)
    }
    
    @objc fileprivate func handleRefresh(){
        print("Refreshing")
        self.fetchUsers()
        self.isSearching = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("HomeController did appear")
        // you want to kick the user out when they log out
        if Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            vc.delegate = self
             //or .overFullScreen for transparency
            let navController = UINavigationController(rootViewController: vc)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
        } else {
            fetchUsers()
            self.isSearching = false
            self.collectionView?.reloadData()
            
            
        }

    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearching == true {
            return filteredUsers.count
        } else {
            return users.count
        }
    }
    

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfileCell
        if isSearching == true {
            
            cell.users = filteredUsers[indexPath.item]

            return cell
        } else {
            cell.backgroundColor = UIColor.rgb(red: 248, green: 141, blue: 19)
            if indexPath.item < users.count {
                cell.users = users[indexPath.item]
            }
            return cell
            
        }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }

    override func collectionView(_ collectionView:UICollectionView, didSelectItemAt indexPath: IndexPath){
        if isSearching == true {
            let user = filteredUsers[indexPath.item]

            let userProfileController = UserProfileViewController()
            userProfileController.userId = user
            navigationController?.pushViewController(userProfileController, animated: true)
            
        } else {
            let user = users[indexPath.item]

            let userProfileController = UserProfileViewController()
            userProfileController.userId = user
            navigationController?.pushViewController(userProfileController, animated: true)
        }

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width-2) / 3
        return CGSize(width: width, height: width)
    }
    
    func didFinishLoggingIn() {
        
    }
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

