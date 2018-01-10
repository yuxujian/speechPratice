//
//  ViewController.swift
//  JustTest
//
//  Created by Ada on 1/3/18.
//  Copyright © 2018 yuxujian. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var mylabel: UILabel!
    @IBOutlet weak var t1: UITextField!
    
    @IBAction func b1(_ sender: UIButton) {
        mylabel.text = "fuck you "
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

