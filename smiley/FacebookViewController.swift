//
//  FacebookViewController.swift
//  smiley
//
//  Created by Sean on 11/5/17.
//  Copyright © 2017 Sean. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class FacebookViewController: UIViewController, FBSDKLoginButtonDelegate{
    override func viewDidLoad() {
        super.viewDidLoad()
        if let _ = FBSDKAccessToken.current() {
            // User is logged in, use 'accessToken' here.
            print("already logged in")
            DispatchQueue.main.async() {
                [unowned self] in
                self.performSegue(withIdentifier: "signedInSegue", sender: self)
            }
        }
        
        let loginButton = FBSDKLoginButton()
        loginButton.center = view.center
        view.addSubview(loginButton)
        
        loginButton.delegate = self
        loginButton.readPermissions = ["public_profile"]
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("logged out of app")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil{
            print(error)
            return
        }
        
        print("successfully logged in with Facebook")
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name"]).start {
            (connection, result, err) in
            
            if err != nil{
                print("Failed to grab user data:", err)
                return
            }
            
            print(result)
            print(FBSDKAccessToken.current().tokenString)
            self.performSegue(withIdentifier: "signedInSegue", sender: nil)

        }
    }
}

