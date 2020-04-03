//
//  HomeViewControllerHeader.swift
//  Icebreaker
//
//  Created by Gregory Reda on 4/3/20.
//  Copyright © 2020 Gregory Reda. All rights reserved.
//

import UIKit

protocol HomeViewControllerHeaderDelegate {
    func searchDidChange(string: String)
    
}

class HomeViewControllerHeader: UICollectionViewCell,UISearchBarDelegate {
    
    var delegate: HomeViewControllerHeaderDelegate?

    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Enter Username"
        sb.barTintColor = .white
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        sb.delegate = self
        return sb
    }()

//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText:String){
//        searchBar.text = searchText.lowercased()
//        //delegate?.searchDidChange(string: searchBar.text ?? "")
//    }
//
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
        delegate?.searchDidChange(string: searchBar.text ?? "")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(searchBar)
        searchBar.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("Init(coder:) has not been implemented")
    }
    


}
