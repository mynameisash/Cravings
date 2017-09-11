//
//  NearMeTVC.swift
//  Cravings
//
//  Created by Ashraf Wan on 5/4/17.
//  Copyright © 2017 Ashraf Wan. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import GooglePlacePicker

class NearMeTVC: UITableViewController, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
    
    var pic: [UIImage] = []
    var places: [GMSPlace] = []
    
    var image:UIImage! = UIImage(named: "no_image.png")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add Colors to the Navigation Bar
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor(red: 250.0/255.0, green: 37.0/255.0, blue: 0.0/255.0, alpha: 0.97)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        //Remove anything in the places Array
        places.removeAll()
        
        //Required to get Google Places Working
        //placesClient = GMSPlacesClient.shared()
        
        //Get the Location
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 25
        locationManager.delegate = self
        
        //Handling getting user location
        let status = CLLocationManager.authorizationStatus()
        switch status{
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
            case .notDetermined:
                //locationManager.requestWhenInUseAuthorization()
                locationManager.requestAlwaysAuthorization()
            case .restricted, .denied:
                let alert = UIAlertController(title: "Location Disabled", message: "Cravings need your location to display the restaurant around you", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let open = UIAlertAction(title: "Open Settings", style: .default, handler: {
                    (action) in if let url = NSURL(string: UIApplicationOpenSettingsURLString){
                        UIApplication.shared.openURL(url as URL)
                    }
                })
            alert.addAction(cancel)
            alert.addAction(open)
            self.present(alert, animated: true, completion: nil)
        }
        //Call allPlace to get the places
        allPlaces()
    }
    
    //Uses google places API to get the places near user location
    func allPlaces(){
        //empty array
        places.removeAll()
        //gets the places
        GMSPlacesClient.shared().currentPlace(callback: {(placeLikelihhoods, error) -> Void in
            if let error = error{
                print("Error CurrentPlace: \(error.localizedDescription)")
                return
            }
            if let likelihoodList = placeLikelihhoods{
                for likelihood in likelihoodList.likelihoods{
                    let place = likelihood.place
                    let types = place.types
                    for type in types{
                        //looking at specific type of places (food, bar, restaurant, cafe)
                        if type == "food" || type == "bar" || type == "restaurant" || type == "cafe"{
                            //add places to the array
                            self.places.append(place)
                            break
                        }
                    }
                }
            }
            else{
                print("none")
            }
            //refresh the data on table view to display new data
            self.tableView.reloadData()
        })
    }

    //load the first picture of the place
    func loadFirstPhotoForPlace(placeID: String) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error LoadFirstPhotoForPlace: \(error.localizedDescription)")
            } else {
                //empty pic array
                self.pic.removeAll()
                //get first pic
                if let firstPhoto = photos?.results.first {
                    //call for the metadata for picture
                    self.loadImageForMetadata(photoMetadata: firstPhoto)
                }
                else{
                    self.image = UIImage(named: "no_image.png")
                }
            }
        }
    }
    
    //getting metadata of images
    func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
            (photo, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error LoadIMageForMetaData: \(error.localizedDescription)")
            } else {
                //get photo into array
                self.image = photo!
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath)
        // Configure the cell...
        if places.count == 0 {
            cell.textLabel?.text = "There are no restaurants around you"
        }
        else{
            let place = places[indexPath.row]
            cell.textLabel?.text = place.name
            cell.detailTextLabel?.text = "Ratings: \(place.rating)"
        }
        return cell
    }
    
    //prepare the segue for each place
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = tableView.indexPathForSelectedRow
        let place = places[indexPath!.row]
        let nearMeDetailVC = segue.destination as! NearMeDetailVC
        
        //load the images
        loadFirstPhotoForPlace(placeID: place.placeID)
        
        // Pass the selected object to nearmedetailvc
        nearMeDetailVC.placeName = place.name
        nearMeDetailVC.placeOpen = place.openNowStatus
        nearMeDetailVC.placeRate = place.rating
        nearMeDetailVC.placePrice = place.priceLevel
        nearMeDetailVC.placeCoor = place.coordinate
        nearMeDetailVC.placeWeb = place.website
        nearMeDetailVC.placeAddress = place.formattedAddress!
        nearMeDetailVC.placeImage = image
        if place.phoneNumber == nil{
            nearMeDetailVC.placePhone = "No Phone Number"
        }
        else{
            nearMeDetailVC.placePhone = place.phoneNumber!
        }
        nearMeDetailVC.placeId = place.placeID
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
