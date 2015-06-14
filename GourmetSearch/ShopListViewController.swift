//
//  ViewController.swift
//  GourmetSearch
//
//  Created by 岩瀬　駿 on 2015/05/23.
//  Copyright (c) 2015年 岩瀬　駿. All rights reserved.
//

import UIKit

class ShopListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var yls : YahooLocalSearch = YahooLocalSearch()
    var loadDataObserver : NSObjectProtocol?
    var refreshObserver : NSObjectProtocol?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var qc = QueryCondition()
        qc.query = "ハンバーガー"
        yls = YahooLocalSearch(condition: qc)
        
        loadDataObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            yls.YLSLoadCompleteNotification,
            object: nil,
            queue: nil,
            usingBlock: {
                (notification) in
                
                self.tableView.reloadData()

                // エラーがあればダイアログを開く
                if notification.userInfo != nil {
                    if let userInfo = notification.userInfo as? [String: String!] {
                        if userInfo["error"] != nil {
                            let alertView = UIAlertController(
                                title: "通信エラー",
                                message: "通信エラーが発生しました",
                                preferredStyle: .Alert)
                            alertView.addAction(UIAlertAction(
                                title: "OK",
                                style: .Default){
                                    action in return
                                }
                            )
                            self.presentViewController(alertView, animated: true, completion: nil)
                        }
                    }
                }
            }
        )
 
        yls.loadData(reset: true)

    }
    
    override func viewWillDisappear(animated: Bool) {
        // 通知の待受を終了
        NSNotificationCenter.defaultCenter().removeObserver(self.loadDataObserver!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        // Pull to Refreshコントロール初期化
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(
            self,
            action: "onRefresh:",
            forControlEvents: .ValueChanged
        )
        self.tableView.addSubview(refreshControl)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    // MARK: - UITableViewDateSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            // セルの数は店舗数
            return yls.shops.count
        }
        // 通常はここに到達しない
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       if indexPath.section == 0 {
            if indexPath.row < yls.shops.count {
                let cell = tableView.dequeueReusableCellWithIdentifier("ShopListItem") as! ShopListItemTableViewCell
                cell.shop = yls.shops[indexPath.row]
                
                if yls.shops.count < yls.total {
                    if yls.shops.count - indexPath.row <= 4 {
                        yls.loadData()
                    }
                }
                
                return cell
            }
        }
        // 通常はここに到達しない。
        return UITableViewCell()
    }
    
    // MARK: - アプリケーションロジック
    
    func onRefresh(refreshControl: UIRefreshControl){
        // UIRefreshControlを読込中状態にする
        refreshControl.beginRefreshing()
        // 終了通知を受信したらUIRefreshControlを停止する
        refreshObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            yls.YLSLoadCompleteNotification,
            object: nil,
            queue: nil,
            usingBlock: {
                notification in
                // 通知の待受を終了
                NSNotificationCenter.defaultCenter().removeObserver(self.refreshObserver!)
                // UIRefreshControlを停止する
                refreshControl.endRefreshing()
            }
        )
        // 再取得
        yls.loadData(reset: true)
    }

}

