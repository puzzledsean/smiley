//
//  ViewController.swift
//  smiley
//
//  Created by Sean on 10/22/17.
//  Copyright © 2017 Sean. All rights reserved.
//

import UIKit

class VideoSelectionController: UIViewController {
    let dogspottingID = "10487409466"
    let catspottingID = "1520135944942471"
    var facebookPageID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onDogVideoClick(_ sender: Any) {
        facebookPageID = dogspottingID
    }
    
    
    @IBAction func onCatVideoClick(_ sender: Any) {
        facebookPageID = catspottingID
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // get a reference to the second view controller
        let mainViewController = segue.destination as! MainViewController
        
        // set a variable in the second view controller with the String to pass
        mainViewController.facebookPageID = self.facebookPageID
    }

    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        // Hide the navigation bar for current view controller
//        self.navigationController?.isNavigationBarHidden = true;
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        // Show the navigation bar on other view controllers
//        self.navigationController?.isNavigationBarHidden = false;
//    }

}

