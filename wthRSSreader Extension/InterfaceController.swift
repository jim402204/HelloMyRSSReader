//
//  InterfaceController.swift
//  wthRSSreader Extension
//
//  Created by Jim on 2018/7/31.
//  Copyright © 2018年 Jim. All rights reserved.
//

import WatchKit
import Foundation

//View Control的精簡版
class InterfaceController: WKInterfaceController {
    
    @IBOutlet var newListTable: WKInterfaceTable!
    
    
    var items = [NewsItem]()
    
    func downloadNewsList() {
        
        
        let urlString = "https://udn.com/rssfeed/news/2/6638?ch=news"
        
        guard let url = URL(string: urlString) else {
            return assertionFailure("Invalid URl string.")
        }
        
        let downloader = RSSDownloader(rssURL: url)
        downloader.download { (error, newsItems) in
            
            if let error = error {
                print("Error:\(error)")
                return
            }//Show alert to user.
            
            if let items = newsItems {
                self.items = items
                print("items: \(items)")
//                self.tableView.reloadData()
                self.refreshTableContent()
            }else{
                //Show alert to user.
            }
        }//download
        
    }//downloadNewsList
    
    
    func refreshTableContent(){// 像拿cell
        
        newListTable.setNumberOfRows(items.count, withRowType: "NewsItemRow")
        
        for i in 0..<items.count{
            
            guard let row = newListTable.rowController(at: i) as? NewsRowControler else{
                assertionFailure("Fail to get row controler.")
                continue
            }
            let item = items[i]
            row.titleLabel.setText(item.title)
            row.data.setText(item.pubData)
        }
        
    }
    
    //傳回        我想要丟去給detail 救return過去
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        
        return items[rowIndex]
    }
    
    
    // viewdidload  <=>  onCreate   但意義不一樣
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        downloadNewsList()
        // Configure interface objects here.
    }
    
    // 呈現畫面
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
