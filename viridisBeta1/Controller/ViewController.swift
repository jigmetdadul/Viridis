//
//  ViewController.swift
//  viridisBeta1
//
//  Created by Jigmet Stanzin Dadul on 20/02/23.
//

import UIKit
import FirebaseDatabase
class ViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    //firedatabase
    var ref = DatabaseReference.init()
    @IBOutlet weak var oldUserGreenIdField: UITextField!
    @IBOutlet weak var oldUserPasswordField: UITextField!
    var enteredId:String = ""
    var enteredPassword:String = ""
    var userPasswordIs:Bool = false
    var checkUserExist:Bool = false
    var count:Int = 0
    var userInfoArr = [userModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        oldUserGreenIdField.delegate = self
        oldUserPasswordField.delegate = self
        
        //firedatabase
        self.ref = Database.database().reference()
        self.readUserDataAndAuthenticate(false)
        //To make text field go up, so that we can
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func userLoggedIn(_ sender: UIButton) {
        //let count = userInfoArr.count
        print("\(count) log in button")
        print(self.enteredId)
        print(userInfoArr[0].greenid == enteredId)
        print(userInfoArr[0].password, enteredPassword)
        print(userInfoArr[0].password == enteredPassword)
        //Note:- make the button go begind the keyboard
        
       // self.readUserDataAndAuthenticate(true)
        if checkUserExist {
            self.performSegue(withIdentifier: "mainLogIn", sender: self)
        }
        else{
            if !checkUserExist {
                oldUserPasswordField.text = ""
                oldUserPasswordField.placeholder = "Wrong Password"
                if !userPasswordIs {
                    oldUserGreenIdField.text = ""
                    oldUserGreenIdField.placeholder = "User does not exist"
                }
                userPasswordIs = false
            }
        }
    }
    @IBAction func accDoesNotExistButton(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "signUp", sender: self)
    }
    
    // make go button work
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != ""{
            return true
        }
        else{
            if textField == oldUserGreenIdField{
                textField.placeholder = "Enter a user name"
            }else if(textField == oldUserPasswordField){
                textField.placeholder = "Enter your password"
            }
            return false
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        switch textField{
        case oldUserGreenIdField:
            enteredId = textField.text ?? "error2"
            oldUserPasswordField.becomeFirstResponder()
            //print(textField.text!)
        default:
            enteredPassword = textField.text ?? "error3"
            print("textField:---- \(enteredPassword)")
            self.readUserDataAndAuthenticate(true)//calling
            textField.endEditing(true)
            break;
        }
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    func readUserDataAndAuthenticate(_ check: Bool){
        ref.child("User").queryOrderedByKey().observe(.value) { (snapshot) in
            self.userInfoArr.removeAll()
            if let snapShot = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapShot{
                    if let mainDict = snap.value as? [String: AnyObject]{
                        let nameFetched = mainDict["name"] as? String ?? "error"
                        let phoneNumberFetched = mainDict["phoneNumber"] as? String ?? "error"
                        let adharNumberFetched = mainDict["adharno"] as? String ?? "error"
                        let passwordFetched = mainDict["password"] as? String ?? "error"
                        let greenidFetched = mainDict["greenid"] as? String ?? "error"
                        self.userInfoArr.append(userModel(name: nameFetched, phoneNumber: phoneNumberFetched, adharNumber: adharNumberFetched, password: passwordFetched, greenid: greenidFetched))
                        if greenidFetched == self.enteredId {
                            self.userPasswordIs = true
                        }
                        print("For loop:-\(passwordFetched)\(self.enteredPassword)")
                        print("count:\(self.count)")
                        print("equal or not: \(passwordFetched == self.enteredPassword)")
//                        if(check && greenidFetched == self.enteredId && self.userInfoArr[self.userInfoArr.count-1].password == self.enteredPassword){
//                            self.checkUserExist = true
//                            break;
//                        }
                        if(check && greenidFetched == self.enteredId && passwordFetched == self.enteredPassword){
                            self.checkUserExist = true
                            break;
                        }
                    }
                }
    
                print("User exist: \(self.checkUserExist)")
            }
        }
    }
    
    
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if(segue.identifier == "signUp"){
    //            let destinationVC = segue.destination as! SignUpViewController
    //
    //        }
    //    }
}

