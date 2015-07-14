//
//  ViewController.swift
//  lyy
//
//  Created by admin on 15/7/6.
//  Copyright (c) 2015年 lyy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var menu: UIView!
/**    @IBAction func cehua(sender: AnyObject) {
        println("========开始=========")
        self.findHamburguerViewController()?.showMenuViewController()
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "asd:")
        menu.addGestureRecognizer(gestureRecognizer)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func asd(recognizer: UITapGestureRecognizer) {
        self.findHamburguerViewController()?.showMenuViewController()
    }
}

