//
//  ViewController.swift
//  SummerCampNews
//
//  Created by 田内　翔太郎 on 2019/08/11.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class MainViewController: ButtonBarPagerTabStripViewController {
    
    // 表示するニュースのurlのリスト
    let urlList: [String] = ["https://news.yahoo.co.jp/pickup/domestic/rss.xml",
                             "https://www.nhk.or.jp/rss/news/cat0.xml",
                             "http://shukan.bunshun.jp/list/feed/rss"]
    
    // タブに表示される名前
    var itemInfo: [IndicatorInfo] = ["Yahoo!", "NHK", "週間文春"]

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // 管理されるviewControllerを返す処理
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        // 返すviewControllerの配列を作成
        var childViewControllers: [UIViewController] = []
        
        // それぞれのVCに異なるurlとitemInfoを入れる
        for i in 0..<urlList.count {
            let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "News") as! NewsViewController
            // urlListのURLを１つずつVCにあるurlに入れる
            VC.url = urlList[i]
            VC.itemInfo = itemInfo[i]
            childViewControllers.append(VC)
        }
        // VCを返す
        return childViewControllers
    }


}

