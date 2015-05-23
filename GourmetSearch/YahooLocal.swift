//
//  YahooLocal.swift
//  GourmetSearch
//
//  Created by 岩瀬　駿 on 2015/05/23.
//  Copyright (c) 2015年 岩瀬　駿. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON

public struct Shop: Printable {
    public var gid: String? = nil
    public var name: String? = nil
    public var photoUrl: String? = nil
    public var yomi: String? = nil
    public var tel: String? = nil
    public var address: String? = nil
    public var lat: Double? = nil
    public var lon: Double? = nil
    public var catchCopy: String? = nil
    public var hasCoupon = false
    public var station: String? = nil
    
    public var description: String {
        get{
            var string = "\nGid: \(gid)\n"
            string += "Name: \(name)\n"
            string += "PhotoUrl: \(photoUrl)\n"
            string += "Yomi: \(yomi)\n"
            string += "Tel: \(tel)\n"
            string += "Address: \(address)\n"
            string += "lat: \(lat)\n"
            string += "lon: \(lon)\n"
            string += "CatchCopy: \(catchCopy)\n"
            string += "hasCoupon: \(hasCoupon)\n"
            string += "Station: \(station)\n"
            return string
        }
    }
}

public struct QueryCondition {
    // キーワード
    public var query: String? = nil
    // 店舗ID
    public var gid: String? = nil
    // ソート順
    public enum Sort : String {
        case Score = "score"
        case Geo = "geo"
    }
    public var sort: Sort = .Score
    // 緯度
    public var lat : Double? = nil
    // 経度
    public var lon : Double? = nil
    // 距離
    public var dist : Double? = nil
    
    // 検索パラメタディクショナリ
    public var queryParams: [String: String] {
        get {
            var params = [String: String]()
            
            // キーワード
            if let unwrapped = query {
                params["query"] = unwrapped
            }
            
            // 店舗ID
            if let unwrapped = gid {
                params["gid"] = unwrapped
            }
            
            // ソート順
            switch sort {
            case .Score:
                params["sort"] = "score"
            case .Geo:
                params["sort"] = "geo"
            }
            
            // 緯度
            if let unwrapped = lat {
                params["lat"] = "\(unwrapped)"
            }
            
            // 経度
            if let unwrapped = lon {
                params["lon"] = "\(unwrapped)"
            }
            
            // 距離
            if let unwrapped = dist {
                params["dist"] = "\(unwrapped)"
            }
            
            // デヴァイス: mobile固定
            params["device"] = "mobile"
            
            // グルーピング: gid固定
            params["group"] = "gid"
            
            // 画像があるデータのみ検索する" true固定
            params["image"] = "true"
            
            // 業種コード: 01(グルメ)固定
            params["gc"] = "01"
            
            return params
        }
    }
}