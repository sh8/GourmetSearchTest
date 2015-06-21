//
//  ShopPhoto.swift
//  GourmetSearch
//
//  Created by 岩瀬　駿 on 2015/06/21.
//  Copyright (c) 2015年 岩瀬　駿. All rights reserved.
//

import Foundation

public class ShopPhoto {
    var photos = [String: [String]]()
    var names = [String: String]()
    var gids = [String]()
    let path: String
    
    // シングルトン実装
    public class var sharedInstance: ShopPhoto? {
        struct Static {
            static let instance = ShopPhoto()
        }
        return Static.instance
    }
    
    private init?(){
        // データ保存先パスを取得
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        // 基本的には成功するが念のため要素数をチェックして使う
        if paths.count > 0 {
            path = paths[0] as! String
        } else {
            path = ""
            return nil
        }
        
        load()
    }
    
    private func load(){
        photos.removeAll()
        names.removeAll()
        gids.removeAll()
        
        let ud = NSUserDefaults.standardUserDefaults()
        ud.registerDefaults(
            [
                "photos": [String: [String]](),
                "names": [String: String](),
                "gids": [String]()
            ]
        )
        
        ud.synchronize()
        if let photos = ud.objectForKey("photos") as? [String: [String]] {
            self.photos = photos
        }
        
        if let names = ud.objectForKey("names") as? [String: String] {
            self.names = names
        }
        
        if let gids = ud.objectForKey("gids") as? [String] {
            self.gids = gids
        }
    }
    
    private func save(){
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setObject(photos, forKey: "photos")
        ud.setObject(names, forKey: "names")
        ud.setObject(gids, forKey: "gids")
        ud.synchronize()
    }
    
    public func append(#shop: Shop, image: UIImage){
        if shop.gid == nil {return}
        if shop.name == nil {return}
        
        let filename = NSUUID().UUIDString + ".jpg"
        let fullpath = path.stringByAppendingPathComponent(filename)
        
        let data = UIImageJPEGRepresentation(image, 0.8)
        if data.writeToFile(fullpath, atomically: true){
            if photos[shop.gid!] == nil {
                // 初めての店舗なら準備する
                photos[shop.gid!] = [String]()
            } else {
                // 初めての店舗でなければ順番だけ変更する
                gids = gids.filter { $0 != shop.gid! }
            }
            
            gids.append(shop.gid!)
            photos[shop.gid!]?.append(filename)
            names[shop.gid!] = shop.name
            save()
        }
    }
    // 指定された店舗・インデックスの写真を返す
    public func image(gid: String, index: Int) -> UIImage {
        if photos[gid] ==  nil { return UIImage() }
        if index >= photos[gid]?.count { return UIImage() }
        
        if let filename = photos[gid]?[index] {
            let fullpath = path.stringByAppendingPathComponent(filename)
            
            if let image = UIImage(contentsOfFile: fullpath) {
                return image
            }
        }
        return UIImage()
    }
    
    // 店舗IDで指定された店舗の写真枚数を返す
    public func count(gid: String) -> Int {
        if photos[gid] == nil {return 0}
        return photos[gid]!.count
    }
    
    // インデックスで指定された店舗の写真枚数を返す
    public func numberOfPhotosInIndex(index: Int) -> Int {
        if index >= gids.count { return 0 }
        if let photos = photos[gids[index]] {
            return photos.count
        }
        return 0
    }
}