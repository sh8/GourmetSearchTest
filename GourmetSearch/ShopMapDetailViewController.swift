//
//  ShopMapDetailViewController.swift
//  GourmetSearch
//
//  Created by 岩瀬　駿 on 2015/06/20.
//  Copyright (c) 2015年 岩瀬　駿. All rights reserved.
//

import UIKit
import MapKit

class ShopMapDetailViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var showHereButton: UIBarButtonItem!
    
    var shop: Shop = Shop()
    let ls = LocationService()
    let nc = NSNotificationCenter.defaultCenter()
    var observers = [NSObjectProtocol]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 店舗所在地を地図に反映
        if let lat = shop.lat {
            if let lon = shop.lon {
                // 地図の表示範囲を指定
                let cllc = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                let mkcr = MKCoordinateRegionMakeWithDistance(cllc, 500, 500)
                map.setRegion(mkcr, animated: false)
                
                // ピンを設定
                let pin = MKPointAnnotation()
                pin.coordinate = cllc
                pin.title = shop.name
                map.addAnnotation(pin)
            }
        }
        
        self.navigationItem.title = shop.name

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        // 位置情報取得を禁止している場合
        observers.append(
            nc.addObserverForName(
                ls.LSAuthDeniedNotification,
                object: nil,
                queue: nil,
                usingBlock: {
                notification in
                    //位置情報がONになっていないダイアログ表示
                    self.presentViewController(self.ls.locationServiceDisabledAlert, animated: true, completion: nil)
                    // 現在地表示ボタンを非アクティブにする
                    self.showHereButton.enabled = false
                }
            )
        )

        // 位置情報取得を制限している場合
        observers.append(
            nc.addObserverForName(
                ls.LSAuthDeniedNotification,
                object: nil,
                queue: nil,
                usingBlock: {
                    notification in
                    //位置情報が制限されているダイアログ表示
                    self.presentViewController(self.ls.locationServiceRestrictedAlert, animated: true, completion: nil)
                    // 現在地表示ボタンを非アクティブにする
                    self.showHereButton.enabled = false
                }
            )
        )
        
        // 位置情報取得に失敗した場合
        observers.append(
            nc.addObserverForName(
                ls.LSAuthDeniedNotification,
                object: nil,
                queue: nil,
                usingBlock: {
                    notification in
                    //位置情報取得に失敗したダイアログ
                    self.presentViewController(self.ls.locationServiceDidFailAlert, animated: true, completion: nil)
                    // 現在地表示ボタンを非アクティブにする
                    self.showHereButton.enabled = false
                }
            )
        )
        
        // 位置情報を取得した場合
        observers.append(
            nc.addObserverForName(
                ls.LSDidUpdateLocationNotification,
                object: nil,
                queue: nil,
                usingBlock: {
                    notification in
                    if let userInfo = notification.userInfo as? [String: CLLocation] {
                        if let clloc = userInfo["location"] {
                            if let lat = self.shop.lat {
                                if let lon = self.shop.lon {
                                    let center = CLLocationCoordinate2D(
                                        latitude: (lat + clloc.coordinate.latitude) / 2,
                                        longitude: (lon + clloc.coordinate.longitude) / 2
                                    )
                                    
                                    let diff = (
                                        lat: abs(clloc.coordinate.latitude - lat),
                                        lon: abs(clloc.coordinate.longitude - lon)
                                    )
                                    
                                    let mkcs = MKCoordinateSpanMake(diff.lat * 1.4, diff.lon * 1.4)
                                    let mkcr = MKCoordinateRegionMake(center, mkcs)
                                    self.map.setRegion(mkcr, animated: true)
                                }
                            }
                        }
                    }
                    self.showHereButton.enabled = true
                }
            )
        )
        
        // 位置情報が利用可能になったとき
        observers.append(
            nc.addObserverForName(
                ls.LSAuthorizedNotification,
                object: nil,
                queue: nil,
                usingBlock: {
                    notification in
                    // 現在地表示ボタンをアクティブにする
                    self.showHereButton.enabled = true
                }
            )
        )
    }
    
    override func viewWillDisappear(animated: Bool) {
        for observer in observers {
            nc.removeObserver(observer)
        }
        
        observers = []
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func showHereButtonTapped(sender: UIBarButtonItem) {
        ls.startUpdatingLocation()
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
