//
//  NearMeDetailVC.swift
//  Cravings
//
//  Created by Ashraf Wan on 5/4/17.
//  Copyright © 2017 Ashraf Wan. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import GooglePlacePicker
import MapKit
import AddressBook
import Contacts

class NearMeDetailVC: UIViewController{
    
    var placeName = ""
    var placeOpen:GMSPlacesOpenNowStatus = GMSPlacesOpenNowStatus.unknown
    var placeRate:Float = 0.0
    var placePrice:GMSPlacesPriceLevel = GMSPlacesPriceLevel(rawValue: 0)!
    var placePhone = ""
    var placeId = ""
    var placeWeb:URL!
    var placeCoor:CLLocationCoordinate2D!
    var placeImage:UIImage!
    var placeAddress = ""
    
    var placesClient:GMSPlacesClient?
    var placesPicker:GMSPlacePicker?
    
    //IBOutlets for Labels
    @IBOutlet weak var openStatus:UILabel!
    @IBOutlet weak var rating:UILabel!
    @IBOutlet weak var phone:UILabel!
    @IBOutlet weak var pricing:UILabel!
    @IBOutlet weak var website:UILabel!
    @IBOutlet weak var picture:UIImageView!
    @IBOutlet weak var name:UILabel!
    @IBOutlet weak var address:UILabel!

    //IBActin for getting directions to place
    @IBAction func getDirections(_ sender: UIButton) {
        let launchOption = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        mapItem().openInMaps(launchOptions: launchOption)
    }
    
    //getting map item for maps
    func mapItem() -> MKMapItem{
        let addressDict = [String(describing: CNPostalAddress.self): placeAddress]
        let placemark = MKPlacemark(coordinate: placeCoor, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = placeName
        return mapItem
    }
    
    func openUrl(urlString:String!){
        let url = URL(string: urlString)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    func onClicLabel(sender:UITapGestureRecognizer) {
        let temp = "\(placeWeb)"
        openUrl(urlString: temp)
    }
    
    //Get Place Name
    func getName() -> String{
        var temp = ""
        if placeName == "" {
            temp = "No Name"
        }
        else{
            temp = placeName
        }
        return temp
    }
    
    //Get Place Open Status
    func getStatus() -> String{
        var temp = ""
        if placeOpen.rawValue == 2 {
            temp = "Open Now"
        }
        else if placeOpen.rawValue == 1 {
            temp = "Closed"
        }
        else{
            temp = "Unknown at this time"
        }
        return temp
    }
    
    //Get Place Phone #
    func getPhone() -> String{
        var temp = ""
        if placePhone == ""{
            temp = "No phone number"
        }
        else{
            temp = placePhone
        }
        return temp
    }
    
    //Get Place Rating
    func getRating() -> Float{
        var temp = 0.0
        if placeRate == 0.0 {
            temp = 0
        }
        else{
            temp = Double(placeRate)
        }
        return Float(temp)
    }
    
    //get Place Price Range
    func getPrice() -> String{
        var temp = ""
        if placePrice.rawValue == 0 {
            temp = "Free"
        }
        else if placePrice.rawValue == 1 {
            temp = "$"
        }
        else if placePrice.rawValue == 2 {
            temp = "$$"
        }
        else if placePrice.rawValue == 3 {
            temp = "$$$"
        }
        else if placePrice.rawValue == 4 {
            temp = "$$$$"
        }
        else {
            temp = "Unknown Price Range"
        }
        return temp
    }
    
    //get Place Website Link
    func getWebsite() -> String{
        var temp = ""
        if placeWeb == nil {
            temp = "No Website Link"
        }
        else{
            temp = "\(placeWeb.host ?? "")"
        }
        return temp
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        openStatus.text = "\(getStatus())"
        phone.text = "\(getPhone())"
        rating.text = "\(getRating())"
        pricing.text = "\(getPrice())"
        website.text = "\(getWebsite())"
        picture.image = placeImage
        name.text = getName()
        address.text = placeAddress
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.onClicLabel(sender:)))
        website.isUserInteractionEnabled = true
        website.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
