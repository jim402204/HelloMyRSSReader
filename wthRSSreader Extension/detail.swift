//
//  detail.swift
//  wthRSSreader Extension
//
//  Created by Jim on 2018/7/31.
//  Copyright © 2018年 Jim. All rights reserved.
//

import WatchKit
import Foundation


class detail: WKInterfaceController {
    
    
    @IBOutlet var desriptionLabel: WKInterfaceLabel!
    
    
    override func awake(withContext context: Any?) {//收到回傳
        super.awake(withContext: context)
        
        //Cogfigure interface objects here
        guard let item = context as? NewsItem else {
            assertionFailure("Fail to get the item.")
            return  }
        
        print("\(item)")
        desriptionLabel.setText(item.description)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
