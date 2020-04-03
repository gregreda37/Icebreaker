//
//  ContactsViewController.swift
//  Icebreaker
//
//  Created by Gregory Reda on 3/3/20.
//  Copyright © 2020 Gregory Reda. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ContactsViewController: UICollectionViewController,LoginViewControllerDelegate,UICollectionViewDelegateFlowLayout {

    let cellId = "cellIds"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        

        collectionView?.register(UserProfileCell.self, forCellWithReuseIdentifier: cellId)
        
        setupNavigationBarItems()
        fetchFriends()
        

    }
    
    var posts = [User]()
    var friends = [Any]()
    
    fileprivate func fetchFriends(){
        //fetch current user
        let uid = Auth.auth().currentUser?.uid ?? ""
        
        print(uid)
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print(err)
                return
            }
            guard let dictionary = snapshot?.data() else { return }
            let friend = dictionary["contacts"]! as! [Any]
            self.friends = friend
            //print(self.friends)
            self.fetchPosts()
            
        }
    }
    
    fileprivate func fetchPosts(){
        self.posts.removeAll()
        var count = 0
        print("Fetching Friends Profiles:::")
        
        while count < friends.count {
            let friendsUID = friends[count] as! String
            
            Firestore.firestore().collection("users").document(friendsUID).getDocument { (snapshot, err) in
                if let err = err {
                    print(err)
                    return
                }
                guard let dictionary = snapshot?.data() else { return }
                let post = User(dictionary: dictionary)
                
                if post.uid == Auth.auth().currentUser?.uid ?? "" {
                    
                } else {
                    self.posts.append(post)
                    //print(self.posts)
                    self.collectionView?.reloadData()
                }

            }
            
            count+=1
        }
        
        self.collectionView?.refreshControl?.endRefreshing()
        self.collectionView?.reloadData()
        
    }
    


    func setupNavigationBarItems(){
        setupLeftNavItem()
        setupRightNavItems()
    }

    
    private func setupLeftNavItem() {
        let shareButton = UIButton(type: .system)
        shareButton.setImage(#imageLiteral(resourceName: "shareButton").withRenderingMode(.alwaysOriginal), for: .normal)
        shareButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        shareButton.addTarget(self, action: #selector(postViewController), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: shareButton)
    }
    
    private func setupRightNavItems() {
        
        let postButton = UIButton(type: .system)
        postButton.setImage(#imageLiteral(resourceName: "newPostButton").withRenderingMode(.alwaysOriginal), for: .normal)
        postButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        postButton.addTarget(self, action: #selector(scannerViewController), for: .touchUpInside)
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: postButton)]
        navigationItem.title = "My Contacts"
    }
    
    @objc fileprivate func scannerViewController(){
        let registrationController = ScannerViewController()
        present(registrationController, animated: true)
        
    }
    
    @objc fileprivate func postViewController(){
        let registrationController = RegisterEventViewController()
        
        present(registrationController, animated: true)
        
    }
    
    @objc fileprivate func handleRefresh(){
        print("Refreshing")
        self.fetchFriends()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Contacts Controller did appear")
        // you want to kick the user out when they log out
        if Auth.auth().currentUser == nil {
            let vc = RegistrationViewController()
            vc.delegate = self
             //or .overFullScreen for transparency
            let navController = UINavigationController(rootViewController: vc)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
        } else {
            
        }

    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
        
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfileCell
        cell.backgroundColor = UIColor.rgb(red: 248, green: 141, blue: 19)
        if indexPath.item < posts.count {
            cell.users = posts[indexPath.item]
        }
        return cell
    }

//    override func collectionView(_ collectionView:UICollectionView, didSelectItemAt indexPath: IndexPath){
//        let user = posts[indexPath.item]
//        let uid = user.uid ?? ""
//        let popViewController = ContactCardViewController()
//
//        func generateQRCode(from string: String) -> UIImage? {
//            let data = string.data(using: String.Encoding.ascii)
//
//            if let filter = CIFilter(name: "CIQRCodeGenerator") {
//                filter.setValue(data, forKey: "inputMessage")
//                let transform = CGAffineTransform(scaleX: 3, y: 3)
//
//                if let output = filter.outputImage?.transformed(by: transform) {
//                    return UIImage(ciImage: output)
//                }
//            }
//
//            return nil
//        }
//
//        let image = generateQRCode(from: uid)
//        popViewController.profileImageView.image = image
//        self.view.addSubview(popViewController)
//    }

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

