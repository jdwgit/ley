//
//  zhaoyao.swift
//  ley
//
//  Created by admin on 15/7/14.
//  Copyright (c) 2015年 ley. All rights reserved.
//

import UIKit

class zhaoyao: UIViewController {
    
    let ypfl = ["hxdyy","xnxg","nkyy","fkyy","wgyy","zbby","pfyy","fsgs","cwyy","gdyy","sjxt","zlyy","nfmyy"]
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var menu: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "asd:")
        menu.addGestureRecognizer(gestureRecognizer)
        let ypflview = UITapGestureRecognizer(target: self, action: "ypflfun:")
        collectionView.addGestureRecognizer(ypflview)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func asd(recognizer: UITapGestureRecognizer) {
        self.findHamburguerViewController()?.showMenuViewController()
    }
    
    func ypflfun(recognizer: UITapGestureRecognizer){
    }
}
/**class zhaoyao: UICollectionViewController {
    
    //课程名称和图片，每一门课程用字典来表示
    let courses = ["hxdyy","xnxg","nkyy","fkyy","wgyy","zbby","pfyy","fsgs","cwyy","gdyy","sjxt","zlyy","nfmyy"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 已经在界面上设计了Cell并定义了identity，不需要注册CollectionViewCell
        //self.collectionView.registerClass(UICollectionViewCell.self,
        //  forCellWithReuseIdentifier: "ViewCell")
        //默认背景是黑色和label一致
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // CollectionView行数
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int)
        -> Int {
            return courses.count;
    }
    
    // 获取单元格
    override func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            // storyboard里设计的单元格
            let identify:String = "DesignViewCell"
            // 获取设计的单元格，不需要再动态添加界面元素
            let cell = self.collectionView?.dequeueReusableCellWithReuseIdentifier(
                identify, forIndexPath: indexPath) as UICollectionViewCell
            // 从界面查找到控件元素并设置属性
            (cell.contentView.viewWithTag(1) as! UIImageView).image =
                UIImage(named: courses[indexPath.row]!)
            (cell.contentView.viewWithTag(2) as! UILabel).text = courses[indexPath.row]
            return cell
    }
}*/