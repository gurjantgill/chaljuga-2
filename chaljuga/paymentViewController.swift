//
//  paymentViewController.swift
//  chaljuga
//
//  Created by Gurjant Gill on 2018-09-24.
//  Copyright © 2018 Gurjant Gill. All rights reserved.
//

import UIKit
import SQLite3
class paymentViewController: UIViewController,UITextFieldDelegate {
    var db: OpaquePointer?
    
    @IBOutlet weak var cardNumber: UITextField!
   
    @IBOutlet weak var expiryDate: UITextField!
    
    @IBAction func buttonSave(_ sender: Any) {
        let number = cardNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let date = expiryDate.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if(number?.isEmpty)!{
            print("Card Number is emplty")
            return;
        }
        if(date?.isEmpty)!{
            print("date is empty")
            return;
        }
        if(number?.count != 19)
        {
            print("Not a valid card")
            return;
        }
        if(date?.count != 5)
        {
            print("Not a valid date")
            return;
        }
        var stmt: OpaquePointer?
        let insertQuery = "INSERT INTO payment (number, date) VALUES (?,?)"
        if sqlite3_prepare(db, insertQuery, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return ;
        }
        
        //binding the parameters
        if sqlite3_bind_text(stmt, 1, number, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return ;
        }
        if sqlite3_bind_text(stmt, 2, date, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return ;
        }
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            return
        }
        readValues()
        
        //displaying a success message
        print("Herro saved successfully")
        
     }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) else { return true }
        
        if textField == cardNumber {
            textField.text = currentText.grouping(every: 4, with: " ")
            return false
        }
        else { // Expiry Date Text Field
            textField.text = currentText.grouping(every: 2, with: "/")
            return false
        }
    }
    func readValues(){
        
        let queryString = "SELECT * FROM payment"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let number = String(cString: sqlite3_column_text(stmt, 1))
            let date = String(cString: sqlite3_column_text(stmt, 2))
            print("paymentDate: \(number)")
            print("paymentData: \(date)")
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardNumber.delegate=self
        expiryDate.delegate=self
       
        let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("HeroDatabase.sqlite")
        
        if sqlite3_open(fileUrl.path, &db) != SQLITE_OK {
            print("Error opening database")
            return
        }
        let deleteTableQuery = "DROP TABLE payment"
        
        if sqlite3_exec(db, deleteTableQuery, nil, nil, nil) != SQLITE_OK{
            print("Error creating table")
            return
        }
        let createTableQuery = "CREATE TABLE IF NOT EXISTS payment (id INTEGER PRIMARY KEY AUTOINCREMENT, number TEXT, date TEXT)"
        
        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK{
            print("Error creating table")
            return
        }
        print("Everything is fine")
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
extension String {
    func grouping(every groupSize: String.IndexDistance, with separator: Character) -> String {
        let cleanedUpCopy = replacingOccurrences(of: String(separator), with: "")
        return String(cleanedUpCopy.characters.enumerated().map() {
            $0.offset % groupSize == 0 ? [separator, $0.element] : [$0.element]
            }.joined().dropFirst())
    }
}
