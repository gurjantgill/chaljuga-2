//
//  ridedetailViewController.swift
//  chaljuga
//
//  Created by Gurjant Gill on 2018-10-06.
//  Copyright © 2018 Gurjant Gill. All rights reserved.
//

import UIKit
import Foundation
class ridedetailViewController: UIViewController {

    @IBOutlet weak var destination: UITextField!
    @IBOutlet weak var distance: UITextField!
    @IBOutlet weak var price: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let dest =  UserDefaults.standard.string(forKey: "formatted_address")
destination.text = dest     // Do any additional setup after loading the view.
        let dist =  UserDefaults.standard.float(forKey: "distance")
        let dist1=dist/1000
        print (dist1)
        distance.text =  "\(String(Int(dist1.rounded()))) km"
        price.text = "\(String(Int(dist1.rounded())*1)) $"
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
