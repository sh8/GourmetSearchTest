//
//  ShopDetailViewController.swift
//  GourmetSearch
//
//  Created by 岩瀬　駿 on 2015/06/14.
//  Copyright (c) 2015年 岩瀬　駿. All rights reserved.
//

import UIKit
import MapKit

class ShopDetailViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var tel: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var favoriteIcon: UIImageView!
    @IBOutlet weak var favoriteLabel: UILabel!
    
    @IBOutlet weak var addressContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var nameHeight: NSLayoutConstraint!
    
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
        
        // 地図
        if let lat = shop.lat {
            if let lon = shop.lon {
                // 地図の表示範囲を指定
                let cllc = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                let mkcr = MKCoordinateRegionMakeWithDistance(cllc, 200, 200)
                map.setRegion(mkcr, animated: false)
                
                // ピンを設定
                let pin = MKPointAnnotation()
                pin.coordinate = cllc
                map.addAnnotation(pin)
            }
        }
        
        // 店舗名
        name.text = shop.name
        
        // 電話番号
        tel.text = shop.tel
        
        // 住所
        address.text = shop.address
        
        updateFavoriteButton()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.scrollView.delegate = self
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.scrollView.delegate = nil
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let scrollOffset = scrollView.contentOffset.y + scrollView.contentInset.top
        if scrollOffset <= 0 {
            photo.frame.origin.y = scrollOffset
            photo.frame.size.height = 200 - scrollOffset
        }
    }
    
    // MARK: - アプリケーションロジック
    func updateFavoriteButton(){
        if Favorite.inFavorites(shop.gid){
            // お気に入りに入っている
            favoriteIcon.image = UIImage(named: "star-on")
            favoriteLabel.text = "お気に入りから外す"
        } else {
            // お気に入りに入っていない
            favoriteIcon.image = UIImage(named: "star-off")
            favoriteLabel.text = "お気に入りに入れる"
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushMapDetail" {
            let vc = segue.destinationViewController as! ShopMapDetailViewController
            vc.shop = shop
        }
    }

    // MARK: - IBAction
    @IBAction func telTapped(sender: UIButton) {
        println("telTapped")
    }
 
    @IBAction func addressTapped(sender: UIButton) {
        performSegueWithIdentifier("PushMapDetail", sender: nil)
    }
    
    @IBAction func favoriteTapped(sender: UIButton) {
        Favorite.toggle(shop.gid)
        updateFavoriteButton()
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
