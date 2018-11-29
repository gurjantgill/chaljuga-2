//
//  mapViewController.swift
//  chaljuga
//
//  Created by Mac on 26/10/18.
//  Copyright © 2018 Gurjant Gill. All rights reserved.
//

import Foundation
import GoogleMaps

class mapViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
   
    
    var libraries: [String] = []
    
   
    let cellReuseIdentifier = "cell"

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var library: UITableView!
   
    override func viewDidLoad() {
        
        guard let fromlat = UserDefaults.standard.string(forKey: "fromlat") else { return }
        guard let tolat =  UserDefaults.standard.string(forKey: "tolat") else { return }
        guard  let fromlong = UserDefaults.standard.string(forKey: "fromlong") else { return }
        guard  let tolong = UserDefaults.standard.string(forKey: "tolong")else { return }

        
        
        let camera = GMSCameraPosition.camera(withLatitude:CLLocationDegrees(fromlat)!, longitude: CLLocationDegrees(fromlong)!, zoom: 10.0)

        self.mapView.camera = camera
        

        let path = GMSMutablePath()
        path.add(CLLocationCoordinate2D(latitude: CLLocationDegrees(fromlat)!, longitude:CLLocationDegrees(fromlong)!))
        path.add(CLLocationCoordinate2D(latitude: CLLocationDegrees(tolat)!, longitude: CLLocationDegrees(tolong)!))

        let polyline = GMSPolyline(path: path)
        polyline.map = self.mapView
      
      

        getAddress(address:"",lat:Double(fromlat)!, long:Double(fromlong)!)
        library.dataSource = self
       library.delegate = self

    }
    
    func getAddress(address:String,lat:Double, long:Double){
        
        var request: NSMutableURLRequest? = nil
        var url: URL!

       url = URL(string:"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat),\(long)&radius=10000&types=library&key=AIzaSyBf-9s95GSRHN_G7i6qnfOQ57HYz9ffskI")
//        url = URL(string: "https://maps.google.com/maps/api/geocode/json?sensor=false&key=AIzaSyBf-9s95GSRHN_G7i6qnfOQ57HYz9ffskI&address=\(txtAppend!)")
        
        
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
                        let name = locationDictionary["name"]
 
                        let lat = location["lat"]
                        let long = location["lng"]
                        
                        

                        print("Results: \(name ?? "")")
                        libraries.append(name as! String);

                    }
                }
                library.reloadData()

            }
            
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return libraries.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        }
        if  libraries.count > 0 {
            cell?.textLabel!.text = libraries[indexPath.row]
        }
        cell?.textLabel?.numberOfLines = 0
        
        return cell!
    }
    

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
}
