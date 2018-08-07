//
//  DetailViewController.swift
//  HelloMyRSSReader
//
//  Created by Jim on 2018/6/8.
//  Copyright © 2018年 Jim. All rights reserved.
//

import UIKit
import WebKit
class DetailViewController: UIViewController {


    @IBOutlet weak var mainWebView: WKWebView!
    
    //setter/getter.
    var detailItem: NewsItem? { //每當內頁資料被更新 便開始更新configureView()
        didSet {
            // Update the view.
            print("\(oldValue) become \(detailItem)") //如果想比較新舊職
            configureView()
        }
    }
    
    func configureView() {
       
        guard let item = detailItem,let webView = mainWebView else {
            return
        }
        
        self.title = item.title                      //透過資料更新 該項目的標題
        
        guard let urlString = item.link else {
            return assertionFailure("Invalid News Link is nil.")
        }
        
        guard let url = URL(string: urlString) else {
            return assertionFailure("Invalid News Link URl.")
        }
        let request = URLRequest(url: url)
        webView.load(request)                       //使用得到link url載入 webView
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

