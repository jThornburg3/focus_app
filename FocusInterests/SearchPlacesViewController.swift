//
//  search_place.swift
//  FocusInterests
//
//  Created by Andrew Simpson on 5/19/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import CoreLocation
import SwiftyJSON
import Crashlytics

class SearchPlacesViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var currentLocationSearchBar: UISearchBar!
    
    @IBOutlet weak var invitePopup: UIView!
    @IBOutlet weak var invitePopupBottomLayoutConstraint: NSLayoutConstraint!
    
    var places = [Place]()
    var all_places = [Place]()
    var followingPlaces = [Place]()
    var filtered = [Place]()
    
    var location: CLLocation?
    var showPopup = false
    var followingCount = 0
    var suggestionCount = 0
    
//    @IBOutlet weak var inviteBottomSpace: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.clipsToBounds = true
        
        let nib = UINib(nibName: "SearchPlaceCell", bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: "SearchPlaceCell")

        self.searchBar.delegate = self
        self.currentLocationSearchBar.delegate = self
        
//        search bar attributes
        let placeholderAttributes: [String : AnyObject] = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "Avenir Book", size: 15)!]
        let cancelButtonsInSearchBar: [String: AnyObject] = [NSFontAttributeName: UIFont(name: "Avenir-Black", size: 15)!]
        
//        MARK: Event Search Bar
        self.searchBar.isTranslucent = true
        self.searchBar.backgroundImage = UIImage()
        self.searchBar.tintColor = UIColor.white
        self.searchBar.barTintColor = UIColor.white
        
        self.searchBar.layer.cornerRadius = 6
        self.searchBar.clipsToBounds = true
        self.searchBar.layer.borderWidth = 0
        
        self.searchBar.setValue("Go", forKey:"_cancelButtonText")
        
        if let textFieldInsideSearchBar = self.searchBar.value(forKey: "_searchField") as? UITextField{
            
            let attributedPlaceholder: NSAttributedString = NSAttributedString(string: "Search", attributes: placeholderAttributes)
            
            textFieldInsideSearchBar.attributedPlaceholder = attributedPlaceholder
            textFieldInsideSearchBar.textColor = UIColor.white
            textFieldInsideSearchBar.backgroundColor = Constants.color.darkGray
            
            let glassIconView = textFieldInsideSearchBar.leftView as! UIImageView
            glassIconView.image = glassIconView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            glassIconView.tintColor = UIColor.white
            
            textFieldInsideSearchBar.clearButtonMode = .whileEditing
            let clearButton = textFieldInsideSearchBar.value(forKey: "clearButton") as! UIButton
            clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
            clearButton.tintColor = UIColor.white
        }
        
        //        MARK: Current Location Search Bar
        self.currentLocationSearchBar.isTranslucent = true
        self.currentLocationSearchBar.backgroundImage = UIImage()
        self.currentLocationSearchBar.tintColor = UIColor.white
        self.currentLocationSearchBar.barTintColor = UIColor.white
        
        self.currentLocationSearchBar.layer.cornerRadius = 6
        self.currentLocationSearchBar.clipsToBounds = true
        self.currentLocationSearchBar.layer.borderWidth = 0
        self.currentLocationSearchBar.layer.borderColor = UIColor(red: 119/255.0, green: 197/255.0, blue: 53/255.0, alpha: 1.0).cgColor
        
        
        if let currentLocationTextField = self.currentLocationSearchBar.value(forKey: "_searchField") as? UITextField{
            let currentLocationAttributePlaceHolder: NSAttributedString = NSAttributedString(string: "Current Location", attributes: placeholderAttributes)
            
            currentLocationTextField.attributedPlaceholder = currentLocationAttributePlaceHolder
            currentLocationTextField.textColor = UIColor.white
            currentLocationTextField.backgroundColor = Constants.color.darkGray
            
            let currentLocationIcon = currentLocationTextField.leftView as! UIImageView
            currentLocationIcon.image = UIImage(named: "self_location")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            currentLocationIcon.tintColor = UIColor.white
            currentLocationTextField.clearButtonMode = .whileEditing
            
            let currentLocationClearButton = currentLocationTextField.value(forKey: "clearButton") as! UIButton
            currentLocationClearButton.setImage(currentLocationClearButton.imageView?.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
            currentLocationClearButton.tintColor = UIColor.white
        }
        
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonsInSearchBar, for: .normal)
        
        let attrs = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Avenir-Black", size: 18)!
        ]
        
        navBar.titleTextAttributes = attrs
        hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Answers.logCustomEvent(withName: "Screen",
                               customAttributes: [
                                "Name": "Search Place"
            ])
        
        if showPopup{
            invitePopup.alpha = 1
            self.invitePopup.layer.cornerRadius = 10.0
            UIView.animate(withDuration: 1.0,delay: 0.0,options: .curveEaseInOut,animations: {
                self.invitePopupBottomLayoutConstraint.constant = 0
                self.invitePopup.center.y -= 119
            }, completion: nil)
            _ = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector:  #selector(SearchPlacesViewController.hidePopup), userInfo: nil, repeats: false)
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.all_places.removeAll()
        
        self.places.sort {
            return $0.distance < $1.distance
        }
        
        for place in self.followingPlaces{
            if let index = self.places.index(where: { $0.id == place.id }) {
                self.places.remove(at: index)
            }
        }

        
        self.all_places = self.followingPlaces + self.places
        self.filtered = self.all_places
        
        self.tableView.reloadData()
    
//        Constants.DB.user.child(AuthApi.getFirebaseUid()!).child("following/places").observeSingleEvent(of: .value, with: { (snapshot) in
//            let value = snapshot.value as? NSDictionary
//            
//            if let placeData = value{
//                self.followingCount = placeData.count
//                self.followingPlaces.removeAll()
//                for (_,place) in placeData
//                {
//                    let place_id = (place as? [String:Any])?["placeID"]
//                    getYelpByID(ID: place_id as! String, completion: {place in
//                        self.followingPlaces.append(place)
//                        
//                        
//                        if self.followingPlaces.count == self.followingCount{
//                            self.places = self.followingPlaces + self.places
//                            
//                            self.filtered = self.places
//                            self.tableView.reloadData()
//                        }
//                    })
//                
//                }
//                
//                
//            }
//        })
        
        
    }
    
    func hidePopup(){
//        invitePopup.alpha = 0
        UIView.animate(withDuration: 1.0,delay: 0.0,options: .curveEaseInOut, animations: {
            self.invitePopupBottomLayoutConstraint.constant = -119
            self.invitePopup.center.y += 119
        }, completion: nil)
        self.showPopup = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:SearchPlaceCell = self.tableView.dequeueReusableCell(withIdentifier: "SearchPlaceCell") as! SearchPlaceCell!
        cell.parentVC = self
        
        let place = filtered[indexPath.row]
        cell.placeNameLabel.text = place.name
        cell.place = place
        if place.address.count > 0{
            if place.address.count == 1{
                cell.addressTextView.text = "\(place.address[0])"
            }
            else{
                cell.addressTextView.text = "\(place.address[0])\n\(place.address[1])"
            }
        }
        let place_location = CLLocation(latitude: place.latitude, longitude: place.longitude)
        cell.distanceLabel.text = getDistance(fromLocation: place_location, toLocation: AuthApi.getLocation()!)
        cell.placeID = place.id
        print("place.id: \(place.id)")
        cell.ratingLabel.text = "\(place.rating) (\(place.reviewCount) ratings)"
        if place.categories.count > 0{
            
            addGreenDot(label: cell.categoryLabel, content: getInterest(yelpCategory: place.categories[0].alias))
//            cell.categoryLabel.text =
        }
        
        cell.parentVC = self
        cell.checkForFollow()
        _ = UIImage(named: "empty_event")
        
        SDWebImageManager.shared().downloadImage(with: URL(string :place.image_url), options: .highPriority, progress: {
            (receivedSize :Int, ExpectedSize :Int) in
            
        }, completed: {
            (image : UIImage?, error : Error?, cacheType : SDImageCacheType, finished : Bool, url : URL?) in
            
            if error == nil{
                cell.placeImage.image = crop(image: image!, width: 50, height: 50)
            }
            
        })
        
        //cell.placeImage.sd_setImage(with: URL(string :place.image_url), placeholderImage: placeHolderImage)
        cell.checkForFollow()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = self.filtered[indexPath.row]
        let storyboard = UIStoryboard(name: "PlaceDetails", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "home") as! PlaceViewController
        controller.place = place
        self.present(controller, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if searchBar.tag == 0 {
            self.currentLocationSearchBar.setShowsCancelButton(false, animated: true)
            self.currentLocationSearchBar.endEditing(true)
            self.searchBar.setShowsCancelButton(true, animated: true)
        }else if searchBar.tag == 1{
            print("you have Editted Location Search Bar")
            self.searchBar.setShowsCancelButton(false, animated: true)
            self.searchBar.endEditing(true)
            self.currentLocationSearchBar.setShowsCancelButton(true, animated: true)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.tag == 0{
            self.searchBar.text = ""
            self.filtered = self.places
            self.tableView.reloadData()
            self.searchBar.text = ""
            self.searchBar.setShowsCancelButton(false, animated: true)
            self.searchBar.endEditing(true)
        }else if searchBar.tag == 1{
            print("you have canceled Location Search Bar")
            self.currentLocationSearchBar.text = ""
            self.currentLocationSearchBar.setShowsCancelButton(false, animated: true)
            self.currentLocationSearchBar.endEditing(true)
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.tag == 0{
            self.searchBar.text = ""
            self.searchBar.setShowsCancelButton(false, animated: true)
            self.searchBar.endEditing(true)
        }else if searchBar.tag == 1{
            self.currentLocationSearchBar.text = ""
            self.currentLocationSearchBar.setShowsCancelButton(false, animated: true)
            self.currentLocationSearchBar.endEditing(true)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.tag == 0{
            var results = [String: [Place]]()
            if(searchText.characters.count > 0){
                
                let url = "https://api.yelp.com/v3/businesses/search"
                
                let headers: HTTPHeaders = [
                    "authorization": "Bearer \(AuthApi.getYelpToken()!)",
                    "cache-contro": "no-cache"
                ]
                
                
                let parameters = [
                    "term": searchText,
                    "latitude": location?.coordinate.latitude ?? 0,
                    "longitude": location?.coordinate.longitude ?? 0,
                    "radius": 32_186
                    ] as [String : Any]
                Alamofire.request(url, method: .get, parameters:parameters, headers: headers).responseJSON { response in
                    let json = JSON(data: response.data!)["businesses"]
                    
                    var result = [Place]()
                    
                    _ = self.places.count
                    for (_, business) in json.enumerated(){
                        let id = business.1["id"].stringValue
                        let name = business.1["name"].stringValue
                        let image_url = business.1["image_url"].stringValue
                        let isClosed = business.1["is_closed"].boolValue
                        let reviewCount = business.1["review_count"].intValue
                        let rating = business.1["rating"].floatValue
                        let latitude = business.1["coordinates"]["latitude"].doubleValue
                        let longitude = business.1["coordinates"]["longitude"].doubleValue
                        let price = business.1["price"].stringValue
                        let address_json = business.1["location"]["display_address"].arrayValue
                        let phone = business.1["display_phone"].stringValue
                        let distance = business.1["distance"].doubleValue
                        let categories_json = business.1["categories"].arrayValue
                        let url = business.1["url"].stringValue
                        let plain_phone = business.1["phone"].stringValue
                        let is_closed = business.1["is_closed"].boolValue
                        
                        var address = [String]()
                        for raw_address in address_json{
                            address.append(raw_address.stringValue)
                        }
                        
                        var categories = [Category]()
                        for raw_category in categories_json as [JSON]{
                            let category = Category(name: raw_category["title"].stringValue, alias: raw_category["alias"].stringValue)
                            categories.append(category)
                        }
                        
                        let place = Place(id: id, name: name, image_url: image_url, isClosed: isClosed, reviewCount: reviewCount, rating: rating, latitude: latitude, longitude: longitude, price: price, address: address, phone: phone, distance: distance, categories: categories, url: url, plainPhone: plain_phone)
                        
                        if !result.contains(place){
                            result.append(place)
                        }
                    }
                    results[searchText] = result
                    print("searching - \(searchText)")
                    
                    if self.searchBar.text == searchText{
                        print(results[searchText])
                        self.filtered = results[searchText]!
                        
                        //                    self.filtered.sort{ //sort(_:) in Swift 3
                        //                            if $0.name != $1.name {
                        //                                return $0.name < $1.name
                        //                            }
                        //
                        //                        else { // All other fields are tied, break ties by last name
                        //                            return $0.distance < $1.distance
                        //                        }
                        //                    }
                        
                        print("searching finally - \(searchText)")
                        //                    print(self.filtered[0].name)
                        self.tableView.reloadData()
                    }
                    
                }
            }
            else{
                self.filtered = self.places
                self.tableView.reloadData()
            }
        }else if searchBar.tag == 1{
            print("you have clicked Location Search Bar")
            self.searchBar.endEditing(true)
            self.searchBar.setShowsCancelButton(false, animated: true)
            self.currentLocationSearchBar.setShowsCancelButton(true, animated: true)
        }
    }
}
