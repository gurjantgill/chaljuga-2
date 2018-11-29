//
//  profileViewController.swift
//  chaljuga
//
//  Created by Gurjant Gill on 2018-09-24.
//  Copyright © 2018 Gurjant Gill. All rights reserved.
//

import UIKit
import SQLite3
class profileViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    var imagePicker = UIImagePickerController()
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var editBtn: UIButton!
   
    @IBOutlet weak var firstNametxt: UITextField!
    @IBOutlet weak var lastNametxt: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
//    @IBAction func saveBtnAction(_ sender: Any) {
//    }
    var db: OpaquePointer?
  //  var heroList = [Hero]()
    var i=1;
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("HeroDatabase.sqlite")
        
        if sqlite3_open(fileUrl.path, &db) != SQLITE_OK {
            print("Error opening database")
            return
        }
//        let deleteTableQuery = "DROP TABLE profile"
//
//        if sqlite3_exec(db, deleteTableQuery, nil, nil, nil) != SQLITE_OK{
//            print("Error delete table")
////            return
//        }

        let createTableQuery = "CREATE TABLE IF NOT EXISTS profile (id INTEGER PRIMARY KEY AUTOINCREMENT, firstName TEXT, lastName TEXT,userImage TEXT)"
        
        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK{
            print(" creating table")
            return
        }
        print("Everything is fine")
        readValuesToshow();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func editBtnAction(_ sender: Any) {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
       
        
        self.present(alert, animated: true, completion: nil)
    }
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary()
    {
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let img = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
       
        selectedImage.image = img
    
    }
    @IBAction func saveBtnAction(_ sender: Any) {
        if(firstNametxt .isEqual("") )
        {
            return
        }
        if(lastNametxt .isEqual("") )
        {
            return
        }
        if((selectedImage.image == nil))
        {
            return
        }
         let fileName = String.random()
        do {
           
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("\(fileName).png")
            if let pngImageData = UIImagePNGRepresentation(selectedImage.image!) {
                try pngImageData.write(to: fileURL, options: .atomic)
            }
        } catch { }
        var stmt: OpaquePointer?
        let firstName : NSString? = firstNametxt.text?.trimmingCharacters(in: .whitespacesAndNewlines) as NSString?
        let lastName : NSString? = lastNametxt.text?.trimmingCharacters(in: .whitespacesAndNewlines) as NSString?
        let userImage = fileName
        //the insert query'
       
        print("heroData: \(String(describing: firstName))")
        
        print("heroData: \(String(describing: lastName))")
      //  print("heroData: \(String(describing: fileName))")

        
        let queryString = "INSERT INTO profile (firstName, lastName, userImage) VALUES (?,?,?)"

        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return ;
        }
        
        //binding the parameters.ut
        if sqlite3_bind_text(stmt, 1, firstName?.utf8String, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return ;
        }
        
        if sqlite3_bind_text(stmt, 2, lastName?.utf8String, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return ;
        }
        if sqlite3_bind_text(stmt, 3, userImage, -1, nil) != SQLITE_OK{
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
      
        
        readValues()
        
        //displaying a success message
        print("Herro saved successfully")
    }
    func readValues(){
        
        let queryString = "SELECT * FROM profile"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
         
            let firstName = String(cString: sqlite3_column_text(stmt, 1))
            let lastName = String(cString: sqlite3_column_text(stmt, 2))
            let userImage = String(cString: sqlite3_column_text(stmt, 3))

          
            print("heroData: \(firstName)")
            print("heroData: \(lastName)")
            print("heroData: \(userImage)")
          
          
        }
        
    }
    

    func readValuesToshow(){
        
        let queryString = "SELECT * FROM profile"
        
        var stmt:OpaquePointer? 
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("show error: \(errmsg)")
            return
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            
            let firstName = String(cString: sqlite3_column_text(stmt, 1))
            let lastName = String(cString: sqlite3_column_text(stmt, 2))
            let userImage = String(cString: sqlite3_column_text(stmt, 3))
            
            
            print("heroData: \(firstName)")
            print("heroData: \(lastName)")
            print("heroData: \(userImage)")
            firstNametxt.text=firstName
            lastNametxt.text=lastName
            
            
        }
        
    }
    


}
extension String {
    
    static func random(length: Int = 20) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        return randomString
    }
}
