//
//  SecondViewController.swift
//  JustTest
//
//  Created by Ada on 1/9/18.
//  Copyright © 2018 yuxujian. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var t2: UITextField!
    @IBAction func b2(_ sender: Any) {
        navigationController?.popViewController(animated:true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
