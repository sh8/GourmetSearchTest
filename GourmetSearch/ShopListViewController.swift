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
        
//        var qc = QueryCondition()
//        qc.query = "ハンバーガー"
//        yls = YahooLocalSearch(condition: qc)
        
        loadDataObserver = NSNotificationCenter.defaultCenter().addObserverForName(
            yls.YLSLoadCompleteNotification,
            object: nil,
            queue: nil,
            usingBlock: {
                (notification) in
                
                if self.yls.condition.gid != nil {
                    self.yls.sortByGid()
                }
                
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
 
        if yls.shops.count == 0 {
            if self.navigationController is FavoriteNavigationController {
                loadFavorites()
                // ナビゲーションタイトル設定
                self.navigationItem.title = "お気に入り"
            } else {
                // 検索: 設定された検索条件から検索
                yls.loadData(reset: true)
                // ナビゲーションバータイトル設定
                self.navigationItem.title = "店舗一覧"
            }
        }

    }
    
    override func viewWillDisappear(animated: Bool) {
        // 通知の待受を終了
        NSNotificationCenter.defaultCenter().removeObserver(self.loadDataObserver!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        // お気に入りでなければ編集ボタンを削除
        if !(self.navigationController is FavoriteNavigationController){
            self.navigationItem.rightBarButtonItem = nil
        }
        
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // セルの選択状態を解除する
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        // Segueを実行する
        performSegueWithIdentifier("PushShopDetail", sender: indexPath)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // お気に入りなら削除可能
        return self.navigationController is FavoriteNavigationController
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // 削除の場合
        if editingStyle == .Delete {
            // User Defaultに反映する
            Favorite.remove(yls.shops[indexPath.row].gid)
            // yls.shopsに反映する
            yls.shops.removeAtIndex(indexPath.row)
            // UITableView上の見た目に反映する
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // お気に入りなら順番変更可能
        return self.navigationController is FavoriteNavigationController
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        // 移動元と移動先が同じなら何もしない
        if sourceIndexPath == destinationIndexPath {return}
        
        // yls.shopsに反映する
        let source = yls.shops[sourceIndexPath.row]
        yls.shops.removeAtIndex(sourceIndexPath.row)
        yls.shops.insert(source, atIndex: destinationIndexPath.row)
        // User Defaultsに反映する
        Favorite.move(sourceIndexPath.row, destinationIndexPath.row)
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
    
    func loadFavorites(){
        // お気に入りをUser Defaultから読み込む
        Favorite.load()
        // お気に入りがあれば店舗ID一覧を作成して検索を実行する
        if Favorite.favorites.count > 0 {
            // お気に入り一覧を表現する検索条件オブジェクト
            var condition = QueryCondition()
            // favoritesプロパティの中身を「,」で結合して文字列にする
            condition.gid = join(",", Favorite.favorites)
            yls.condition = condition
            yls.loadData(reset: true)
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(
                yls.YLSLoadCompleteNotification,
                object: nil
            )
        }
    }
    
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
        if self.navigationController is FavoriteNavigationController {
          loadFavorites()
        } else {
          // そのまま再取得する
          yls.loadData(reset: true)
        }
    }
    
    // MARK: - IBAction
    @IBAction func editButtonTapped(sender: UIBarButtonItem) {
        if tableView.editing {
            tableView.setEditing(false, animated: true)
            sender.title = "編集"
        } else {
            tableView.setEditing(true, animated: true)
            sender.title = "完了"
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushShopDetail" {
            let vc = segue.destinationViewController as! ShopDetailViewController
            if let indexPath = sender as? NSIndexPath {
                vc.shop = yls.shops[indexPath.row]
            }
        }
    }
}

