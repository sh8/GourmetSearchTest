//
//  SearchTopTableViewController.swift
//  GourmetSearch
//
//  Created by 岩瀬　駿 on 2015/06/14.
//  Copyright (c) 2015年 岩瀬　駿. All rights reserved.
//

import UIKit

class SearchTopTableViewController: UITableViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    var freeword: UITextField? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }

    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        default:
            return 0
        }
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("Freeword", forIndexPath: indexPath) as! FreewordTableViewCell
                self.freeword = cell.freeword
                cell.freeword.delegate = self
                cell.selectionStyle = .None
                return cell
            case 1:
                let cell = UITableViewCell()
                cell.textLabel?.text = "現在地から検索"
                cell.accessoryType = .DisclosureIndicator
                return cell
            default:
                return UITableViewCell()
            }
        }
        return UITableViewCell()
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        performSegueWithIdentifier("PushShopList", sender: self)

        
        return true
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushShopList" {
            let vc = segue.destinationViewController as! ShopListViewController
            vc.yls.condition.query = freeword?.text
        }
    }
    
    // MARK: - IBAction
    @IBAction func onTap(sender: UITapGestureRecognizer) {
        freeword?.resignFirstResponder()
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        gestureRecognizer.delegate = self

        if let ifr = freeword?.isFirstResponder() {
            return ifr
        }
        
        return false
    }
    

}
