//
//  ReportUser.swift
//  Icebreaker
//
//  Created by Gregory Reda on 4/10/20.
//  Copyright © 2020 Gregory Reda. All rights reserved.
//

import Foundation
import Firebase

class ReportUser {
    
    func handleReport(uid: String){
        print("Reporting User")
        let userCollection = Firestore.firestore().collection("users").document(Auth.auth().currentUser?.uid ?? "")
        let reportCollection = Firestore.firestore().collection("reports").document(uid)
        
        reportCollection.getDocument { (document, error) in
              if let document = document {
                  if document.exists {
                      reportCollection.updateData([
                          "reports": FieldValue.arrayUnion([Auth.auth().currentUser?.uid ?? ""])
                      ])
                  } else {
                    print("Document does not exist")
                    let docData: [String : Any] = ["reports": [Auth.auth().currentUser?.uid ?? ""], "uid": uid]
                        reportCollection.setData(docData) { (err) in
                                if let err = err {
                                    print("Failed to save Data",err)
                                    return
                                }
                            
                            print("Reported user \(uid)")
                            
                            
                        }
                  }
            }
        }
        userCollection.getDocument { (snapshot, err) in
            if let err = err {
                    print(err)
                    return
            }
        userCollection.updateData([
            "blockedUsers": FieldValue.arrayUnion([uid])
        ])
        
        userCollection.updateData([
            "contacts": FieldValue.arrayRemove([uid])
        ])
            
        }
    }
}

