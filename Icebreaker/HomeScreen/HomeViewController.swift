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

class HomeViewController: UICollectionViewController,LoginViewControllerDelegate,UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellIds"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        

        collectionView?.register(UserProfileCell.self, forCellWithReuseIdentifier: cellId)
        
        setupNavigationBarItems()

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate

        print("THESE ARE MY COORDINATES")
        latitude = locValue.latitude
        longitude = locValue.longitude

        print(locValue.latitude)
        print(locValue.longitude)
        self.fetchLocalProfiles()

    }
    
    var locations = [String]()
    var longitude: Double?
    var latitude: Double?
    
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
        
        fetchUsers()
    }
    
    var users = [User]()
    
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
                
                if user.uid == Auth.auth().currentUser?.uid ?? ""  {
                    
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
        shareButton.addTarget(self, action: #selector(presentInvitesViewController), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: shareButton)
    }
    
    @objc fileprivate func pushSettingsController(){
        let settingsViewController = SettingsViewController()
        navigationController?.pushViewController(settingsViewController, animated: true)
        
    }
    
    @objc fileprivate func presentInvitesViewController(){
        let profileController = SettingsViewController()
        self.present(UINavigationController(rootViewController: profileController), animated: true, completion: nil)

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
        postButton.setImage(#imageLiteral(resourceName: "newPostButton").withRenderingMode(.alwaysOriginal), for: .normal)
        postButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        postButton.addTarget(self, action: #selector(scannerViewController), for: .touchUpInside)
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: postButton)]
        navigationItem.title = "Local Users"
    }
    
    @objc fileprivate func scannerViewController(){
        let registrationController = ScannerViewController()
        present(registrationController, animated: true)
        
    }
    
    @objc fileprivate func handleRefresh(){
        print("Refreshing")
        self.fetchUsers()
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
            
        }

    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
        
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfileCell
        cell.backgroundColor = UIColor.rgb(red: 248, green: 141, blue: 19)
        if indexPath.item < users.count {
            cell.users = users[indexPath.item]
        }
        return cell
    }

    override func collectionView(_ collectionView:UICollectionView, didSelectItemAt indexPath: IndexPath){
        let user = users[indexPath.item]
        let uid = user.uid ?? ""
        let popViewController = ContactCardViewController()
        popViewController.titleLabel.text = user.username ?? ""
        
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

        let image = generateQRCode(from: uid)

        popViewController.profileImageView.image = image
        self.view.addSubview(popViewController)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width-2
        return CGSize(width: width, height: width/4)
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

