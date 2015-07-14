//
//  index.swift
//  lyy
//
//  Created by admin on 15/7/7.
//  Copyright (c) 2015年 lyy. All rights reserved.
//

import UIKit

class shouye: DLHamburguerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func awakeFromNib() {
        self.contentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("main") as! UIViewController
        self.menuViewController = self.storyboard?.instantiateViewControllerWithIdentifier("DLDemoMenuViewController") as! UIViewController
    }
    
}
