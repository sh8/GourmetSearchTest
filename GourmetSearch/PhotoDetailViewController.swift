//
//  PhotoDetailViewController.swift
//  GourmetSearch
//
//  Created by 岩瀬　駿 on 2015/06/21.
//  Copyright (c) 2015年 岩瀬　駿. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var photo: UIImageView!

    var image: UIImage = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        photo.alpha = 0
        photo.image = image
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.contentInset.top = (scrollView.bounds.size.height - photo.bounds.size.height) / 2.0
        scrollView.contentInset.bottom = (scrollView.bounds.size.height - photo.bounds.size.height) / 2.0
        
        scrollView.setZoomScale(1, animated: false)
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(animated: Bool) {
        UIView.animateWithDuration(0.1, animations: {self.photo.alpha = 1})
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UIScrollViewDelegate
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return photo
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
