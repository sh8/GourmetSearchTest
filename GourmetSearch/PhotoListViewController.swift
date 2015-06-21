//
//  PhotoListViewController.swift
//  GourmetSearch
//
//  Created by 岩瀬　駿 on 2015/06/21.
//  Copyright (c) 2015年 岩瀬　駿. All rights reserved.
//

import UIKit

class PhotoListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        collectionView.reloadData()
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    // セルのサイズを調整する
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let size = self.view.frame.width / 3
        return CGSize(width: size, height: size)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // セクションの数 = 店舗数 を返す
        if let count = ShopPhoto.sharedInstance?.gids.count {
            return count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // セルの数 = 店舗が持つ写真数を返す
        if let count = ShopPhoto.sharedInstance?.numberOfPhotosInIndex(section) {
            return count
        }

        return 0
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // StoryBoardで設定したセルを取得する
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoListItem", forIndexPath: indexPath) as! PhotoListItemCollectionViewCell
        
        // 指定されたインデックスの店舗を取得する
        if let gid = ShopPhoto.sharedInstance?.gids[indexPath.section] {
            // 店舗IDとインデックスを指定して写真を取得し、セルに設定する
            cell.photo.image = ShopPhoto.sharedInstance?.image(gid, index: indexPath.row)
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        // ヘッダの場合のみ削除する
        if kind == UICollectionElementKindSectionHeader {
            // StoryBoardで設定したヘッダを取得する
            let header = collectionView.dequeueReusableSupplementaryViewOfKind(
                UICollectionElementKindSectionHeader,
                withReuseIdentifier: "PhotoListHeader",
                forIndexPath: indexPath
            ) as! PhotoListItemCollectionViewHeader
            
            // 指定されたインデックスの店舗IDを取得する
            if let gid = ShopPhoto.sharedInstance?.gids[indexPath.section] {
                // 店舗名を取得する
                if let name = ShopPhoto.sharedInstance?.names[gid] {
                    // ヘッダに店舗名を設定する
                    header.title.text = name
                }
            }
            return header
        }
        
        return UICollectionReusableView()
    }


    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("PushPhotoDetail", sender: indexPath)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushPhotoDetail" {
            let vc = segue.destinationViewController as! PhotoDetailViewController
            if let indexPath = sender as? NSIndexPath {
                if let gid = ShopPhoto.sharedInstance?.gids[indexPath.section] {
                    if let image = ShopPhoto.sharedInstance?.image(gid, index: indexPath.row) {
                        vc.image = image
                    }
                }
            }
        }
    }

}