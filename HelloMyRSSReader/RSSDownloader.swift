//
//  RSSDownloader.swift
//  HelloMyRSSReader
//
//  Created by Jim on 2018/6/13.
//  Copyright © 2018年 Jim. All rights reserved.
//



import Foundation

struct NewsItem {
    //... 新聞內容
    
    var title:String?
    var link:String?
    var pubData:String?
    var description:String?

}
//也可用dictionry  會用在欄位不固定的時候 比較麻煩用

typealias RSSDownloadHandler = (Error? , [NewsItem]?) -> Void
//alias 暱稱


class RSSParserDelegat: NSObject, XMLParserDelegate {
    
    //常用就３個 或４
    
    private let itemTag = "item"
    private let titleTag = "title"
    private let linkTag = "link"
    private let pubDataTag = "pubDate"
    private let descriptionTag = "description"
    
    private var currentItem: NewsItem? //新聞資料
    private var currentVale: String?    // 暫存黨
    private(set) var reselts = [NewsItem]()  //存起來載一次拿出去
    //等同於 唯讀（讀取的話 任何人都可以拿）
    
    //Element 在xml 是指 一組為整<頭> <尾>的Element  <裡面是Element name> 這邊才是Element Vale <>
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        //只要讀取碰到 開始標籤時就會執行
        
        
        if elementName == itemTag {
            
            currentItem = NewsItem()
            
        } else if elementName == titleTag ||
            elementName == linkTag ||
            elementName == pubDataTag ||
            elementName == descriptionTag  {
            
            currentVale = nil
            
        }
        
    }
    //讀到標籤以外的 所以字元就會執行 （大概就是內文 （包含換行碼））
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        if currentVale == nil{
            currentVale = string
        }else{
            currentVale! += string  //會斷在內文中 會分兩次 需要串接
        }
        
    }
    
    //讀到結束標籤
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
       
        
        if elementName == itemTag, let item = currentItem {
            reselts.append(item)
            currentItem = nil  //避免意外 又塞東西進去 串接資料的保險？
            
        }else if elementName == titleTag {
            
            currentItem?.title = currentVale
            
        }else if elementName == linkTag{
            
            currentItem?.link = currentVale
            
        }else if elementName == pubDataTag{
            
            currentItem?.pubData = currentVale

        }else if elementName == descriptionTag{
            
            currentItem?.description = currentVale
            
        }
        
        currentVale = nil //Important   （清空buffer）    清除不要的資訊 可能是換行碼
        
        //大概讀取所有的格式 都要格式多段切割 切割後 在清空buff 只讀取要的部分
        
//        switch elementName { //Hardcdoe 盡量不用 就是“jim” 最好是用 變數或常數
//        case itemTag:
//            break
//        case titleTag:
//            break
//        case linkTag:
//            break
//        case pubDataTag:
//            break
//
//        default:
//            break
//        }
        
    }
    
}

class RSSDownloader {
    
    
    
    //大小寫。拼法錯誤 都無法解析 規範定好了
    
    let targetURL:URL
    
    init(rssURL:URL) {
        targetURL = rssURL
    } //類別內 常數可以延後給初始化。fun裡面用法不一樣
    
//    func () -> [xxx] {
//
//    }  函數是非同步的執行  等執行完 回傳 數 fun已經結束了
    
    //              帶入的參數        這是closure
    
    
    
    func download (doneHandler: @escaping RSSDownloadHandler ) {
        //這是model 就算是錯誤訊息也該回傳給 control 來顯示
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: targetURL) { (data, respone, error) in
            
            if let error = error {
                print("Download Fail:\(error)")
                DispatchQueue.main.async { //確保後面的人下載不會用問題
                    doneHandler(error,nil)// 有任何變數從參數傳進來 會先丟進stack
                }
                return
            }
            
            guard let data = data else {
                print("Data is nil")
                
                let error = NSError(domain: "Data is nil", code: -1, userInfo: nil)//錯誤代碼多為負的
                                                    //userInfo: nil後面也可在夾帶資訊
                DispatchQueue.main.async {
                    doneHandler(error,nil)
                }
                return
                
            }

            //parser XML from data
            let parser = XMLParser(data: data) //要找用NS ＸＭＬ Parser
            let parserDelegate = RSSParserDelegat()
            parser.delegate = parserDelegate
            
            if parser.parse(){
                //Parse OK
                DispatchQueue.main.async {
                    doneHandler(nil,parserDelegate.reselts)
                }
                
            }else{
                //Parse Fail
                let error = NSError(domain: "Parse XML Fail", code: -1, userInfo: nil)
                
                DispatchQueue.main.async {
                    doneHandler(error,nil)
                }
                
                
            }
            
        }
        task.resume()
        
    
        
        
    }
    //手勢 一直加會會很延遲   ios中有add 的方法 都會有多開的風險 記得
    
}
