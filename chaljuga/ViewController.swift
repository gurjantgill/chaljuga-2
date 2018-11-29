//
//  ViewController.swift
//  chaljuga
//
//  Created by Gurjant Gill on 2018-09-19.
//  Copyright © 2018 Gurjant Gill. All rights reserved.
//

import UIKit
import SQLite3
import CoreLocation

class ViewController: UIViewController ,CLLocationManagerDelegate{
    var locationManager: CLLocationManager!

    var db: OpaquePointer?
   // var heroList = [Hero]()
    var longitudeData : Double = 0.0
    var latitudeData : Double = 0.0

    @IBOutlet weak var postalcode: UITextField!
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        button.isEnabled = false
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("HeroesDatabase.sqlite")
        // Do any additional setup after loading the view, typically from a nib.
       
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
       
        let deleteTableQuery = "DROP TABLE heroes"
        
        if sqlite3_exec(db, deleteTableQuery, nil, nil, nil) != SQLITE_OK{
            print("Error creating table")
            return
        }
        // what table to drop and recreate
        //creating table
       
        let createTableQuery = "CREATE TABLE IF NOT EXISTS heroes (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT,  longitude TEXT, latitude TEXT)"
        
        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK{
            print("Error creating table")
            return
        }
        postalcode.text="M1B 1C2"
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != .authorizedWhenInUse {return}
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
//     let locValue: CLLocationCoordinate2D = manager.location!.coordinate
//        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        longitudeData = locValue.longitude
        latitudeData =  locValue.latitude

    }
    override func didReceiveMemoryWarning() {
       super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
        
    @IBAction func postalcodechange(_ sender: UITextField) {
        print(sender.text!)
        if validate(text: sender.text!){
            button.isEnabled = true
            
        }
        else {
            button.isEnabled = false
        }
        
    }

    func getAddress(address:String){
      
        var request: NSMutableURLRequest? = nil
        var url: URL!
        let txtAppend = (address).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        url = URL(string: "https://maps.google.com/maps/api/geocode/json?sensor=false&key=AIzaSyBf-9s95GSRHN_G7i6qnfOQ57HYz9ffskI&address=\(txtAppend!)")
        
        
        request = NSMutableURLRequest(url: url!)

        request?.httpMethod = "POST"
        
        var err: Error?
        var response: URLResponse?
        var responseData: Data? = nil
        if let aRequest = request {
            responseData = try? NSURLConnection.sendSynchronousRequest(aRequest as URLRequest, returning: &response)
        }
        var resSrt: String? = nil
        if let aData = responseData {
            resSrt = String(data: aData, encoding: .ascii)
        }
        
        print("got response==\(resSrt ?? "")")
        let jsonObject = try? JSONSerialization.jsonObject(with: responseData! as Data, options: [])
        if let jsonArray = jsonObject as? [String: Any] {
            if let results = jsonArray["results"] as! [Any]?{
                for result in results {
                    if let locationDictionary = result as? [String : Any] {
                        let geometry = locationDictionary["geometry"]! as! [String : Any]
                        let location = geometry["location"]! as! [String : Any]
                        let lat = location["lat"]
                        let long = location["lng"]
                        
                        
                        let formatted_address = locationDictionary["formatted_address"]! as! String
//                        let location = geometry["location"]! as! [String : Any]
//                        let lat = location["lat"]
//                        let long = location["lng"]
                        print("Results: \(lat ?? "")")
                        print("Results: \(long ?? "")")
                        print("Results: \(formatted_address)")
                        UserDefaults.standard.set(formatted_address, forKey: "formatted_address") //Bool

                        getAddress(lat:lat as! CLLocationDegrees,long:long as! CLLocationDegrees )
//                        UserDefaults.standard.set(distanceInMeters, forKey: "distance") //Bool

//
                    }
                    
                }
                
            }
            
        }
//+43.80044100,-79.22343890
        //+37.78583400,-122.40641700
    }
    //RQ2G+5J Toronto, Ontario, Canada
    func getAddress(lat: CLLocationDegrees ,long: CLLocationDegrees){
        let coordinate0 = CLLocation(latitude: lat , longitude: long)
        let coordinate1 = CLLocation(latitude: latitudeData , longitude: longitudeData )
        let distanceInMeters = coordinate0.distance(from: coordinate1)
        print("Results: \(distanceInMeters )")
        UserDefaults.standard.set(distanceInMeters, forKey: "distance") //Bool
        UserDefaults.standard.set(lat, forKey: "fromlat") //Bool
        UserDefaults.standard.set(latitudeData, forKey: "tolat") //Bool
        UserDefaults.standard.set(long, forKey: "fromlong") //Bool
        UserDefaults.standard.set(longitudeData, forKey: "tolong")

    }
    @IBAction func buttonpressed(_ sender: Any) {
       //
        
        var stmt: OpaquePointer?
        let name: NSString? = postalcode.text! as NSString
        getAddress(address: name! as String)
        //the insert query'
        print("heroData: \(name ?? "test")")
        print("heroData: \(longitudeData)")
        print("heroData: \(latitudeData)")
//remove these and replace with longitudeData and latitudeData
        let longitude: NSString?=NSString(format:"%f", longitudeData);
        let latitude: NSString?=NSString(format:"%f", latitudeData);

        
        

        let queryString = "INSERT INTO heroes (name, longitude, latitude) VALUES (?,?,?)"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return ;
        }
        
        //binding the parameters
        if sqlite3_bind_text(stmt, 1, name?.utf8String, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return ;
        }
        
        if sqlite3_bind_text(stmt, 2, longitude?.utf8String, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return ;
        }
        if sqlite3_bind_text(stmt, 3, latitude?.utf8String, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return ;
        }
        
        
        //executing the query to insert values
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            return
        }
        
        //emptying the textfields
//        textFieldName.text=""
//        textFieldPowerRanking.text=""
        
        
        readValues()
        
        //displaying a success message
        print("Herro saved successfully")
    }
    func validate(text: String) ->Bool {
        //creating a statement
            let postalcodeRegex = "^[a-zA-Z][0-9][a-zA-Z][- ]*[0-9][a-zA-Z][0-9]$"
            let pinPredicate = NSPredicate(format: "SELF MATCHES %@", postalcodeRegex)
            let bool = pinPredicate.evaluate(with: text) as Bool
            return bool
       
    }
    func readValues(){
        
        let queryString = "SELECT * FROM heroes"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let name = String(cString: sqlite3_column_text(stmt, 1))
            let longitude = String(cString: sqlite3_column_text(stmt, 2))
             let latitude = String(cString: sqlite3_column_text(stmt, 3))
             print("result: \(id)")
              print("result: \(name)")
            print("result: \(longitude)")
            print("result: \(latitude)")
           
        }

    }
    
}






    
    


