//
//  RegistrationViewModel.swift
//  Icebreaker
//
//  Created by Gregory Reda on 1/31/20.
//  Copyright © 2020 Gregory Reda. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore

class RegistrationViewModel{
    var bindableIsRegistering = Bindable<Bool>()
    var bindableImage = Bindable<UIImage>()
    var bindableIsFormValid = Bindable<Bool>()
    
    var fullName: String? {
        didSet {
            checkFormValidity()
        }
    }

    var email: String?{ didSet{checkFormValidity()}}
    var confirmpassword: String? { didSet{checkFormValidity()}}
    var name: String?{ didSet{checkFormValidity()}}
    var profession: String?{ didSet{checkFormValidity()}}
    var phone: String?{ didSet{checkFormValidity()}}
    var password: String? { didSet{checkFormValidity()}}


    func performRegistration(completion: @escaping (Error?) -> ()){
        guard let email = email, let password = password else { return }
        bindableIsRegistering.value = true
        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
            
            if let err = err {
                completion(err)
                return
            }
            
            print("Successfully registered user:", res?.user.uid ?? "")
            self.saveInfoToFirestore(completion: completion)
        }
    }

    
//saves users registration to firestore with a unique uid.
    fileprivate func saveInfoToFirestore(completion: @escaping (Error?)-> ()){
        let uid = Auth.auth().currentUser?.uid ?? ""
        
        let docData: [String : Any] = [
            "uid": uid,
            "email": email!,
            "contacts": [],
            "username": name!,
            "profession": profession!,
            "phone": phone!
        ]

        Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
            self.bindableIsRegistering.value = false
            if let err = err {
                completion(err)
                return
            }
            completion(nil)
        }

    }
    

    fileprivate func checkFormValidity(){
        let isFormValid = email?.isEmpty == false && password?.isEmpty == false && password == confirmpassword && phone?.isEmpty == false && profession?.isEmpty == false && name?.isEmpty == false
        bindableIsFormValid.value = isFormValid

    }

}

