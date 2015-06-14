//
//  ShopDetailViewController.swift
//  GourmetSearch
//
//  Created by 岩瀬　駿 on 2015/06/14.
//  Copyright (c) 2015年 岩瀬　駿. All rights reserved.
//

import UIKit
import MapKit

class ShopDetailViewController: UIViewController {

    @IBOutlet weak var scrollView: UIView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var tel: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var favoriteIcon: UIImageView!
    @IBOutlet weak var favoriteLabel: UILabel!

    @IBOutlet weak var nameHeight: NSLayoutConstraint!
    @IBOutlet weak var addressContainerHeight: NSLayoutConstraint!
    
    var shop = Shop()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 写真
        if let url = shop.photoUrl {
            photo.sd_setImageWithURL(
                NSURL(string: url),
                placeholderImage: UIImage(named: "loading"),
                options: nil
            )
        } else {
            photo.image = UIImage(named: "loading")
        }
        
        // 店舗名
        name.text = shop.name
        
        // 電話番号
        tel.text = shop.address
        
        // 住所
        address.text = shop.address
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        let nameFrame = name.sizeThatFits(
            CGSizeMake(name.frame.size.width, CGFloat.max))
        nameHeight.constant = nameFrame.height
        
        let addressFrame = address.sizeThatFits(
            CGSizeMake(address.frame.size.width, CGFloat.max))
        addressContainerHeight.constant = addressFrame.height
        view.layoutIfNeeded()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func telTapped(sender: UIButton) {
        println("telTapped")
    }
    
    @IBAction func addressTapped(sender: UIButton) {
        println("addressTapped")
    }

    @IBAction func favoriteTapped(sender: UIButton) {
        println("favoriteTapped")
    }

}
