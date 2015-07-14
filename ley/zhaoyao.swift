//
//  zhaoyao.swift
//  ley
//
//  Created by admin on 15/7/14.
//  Copyright (c) 2015年 ley. All rights reserved.
//

import UIKit

class zhaoyao: UIViewController {
    
    
    
    @IBOutlet weak var menu: UIView!
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