//
//  MasterViewController.swift
//  HelloMyRSSReader
//
//  Created by Jim on 2018/6/8.
//  Copyright © 2018年 Jim. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    
    var objects = [NewsItem]()//

    var serverReach:Reachability?   // 寫obj-c  匯入#import "Reachability.h"
    //匯入obj-c的套件
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreahBtn = UIBarButtonItem(barButtonSystemItem: .refresh //系統內建樣式
            , target: self, action: #selector(refreahBtnPressed))
        
//        navigationItem.rightBarButtonItem = refreahBtn  //貼在右上角 （這邊是放一個的）
        navigationItem.rightBarButtonItems = [refreahBtn]  //貼上多個按鈕  （插在 加s 並用array）
        
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }   //從splitViewController中取得DetailViewController
        
        //Prepare serverReach.
//        serverReach = Reachability(hostName: "udn.com") // 主機是不用加上http x http：//udn.com (是錯誤的)
        //ipv6 apple 不支援寫死的ip   //主機都用domain name  會省很多事情 不用固定ip
        serverReach = Reachability.forInternetConnection()
        
        NotificationCenter.default.addObserver(self, selector: #selector(networkSateusChaged), name:
            .reachabilityChanged, object: nil)
        //reachbiliyChanged
        
        serverReach?.startNotifier()//主動回報
    }
    
    @objc
    func refreahBtnPressed() {
//        let urlString = "https://udn.com/rssfeed/news/2/7227?ch=news"
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
                self.objects = items
                self.tableView.reloadData()
            }else{
                //Show alert to user.
            }
        }
        
       
        
        
    }//芝料來源
    
    @objc
    func networkSateusChaged() {
        guard let status = serverReach?.currentReachabilityStatus() else {
            assertionFailure("Fail ti get status of Reachability.")
            return
        }
        
        print("networkStatusChange")
        
        if status == NotReachable{
            print("NO internet connction")
        }else{
//            typedef enum : NSInteger {判斷
//                NotReachable = 0,
//                ReachableViaWiFi,
//                ReachableViaWWAN
//            } NetworkStatus;
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc
    func insertNewObject(_ sender: Any) {
//        objects.insert(NSDate(), at: 0)
//        let indexPath = IndexPath(row: 0, section: 0)
//        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                
                let item = objects[indexPath.row]
                
                //topViewController 是最上面的那層ctrl
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                
                controller.detailItem = item
                
                //splitViewController 要用的 轉換 ipad
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                // 有返回紐 又加入按鈕 就要true    不然新增的會被返回鈕返回吃掉
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let item = objects[indexPath.row]
        cell.textLabel!.text = item.title
        cell.detailTextLabel!.text = item.pubData
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

