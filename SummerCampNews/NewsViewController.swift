//
//  NewsViewController.swift
//  SummerCampNews
//
//  Created by 田内　翔太郎 on 2019/08/11.
//  Copyright © 2019 田内　翔太郎. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import WebKit

class NewsViewController: UIViewController, IndicatorInfoProvider, UITableViewDelegate, UITableViewDataSource, WKNavigationDelegate, XMLParserDelegate {
    
    // ツールバー
    @IBOutlet weak var toolBar: UIToolbar!
    // ウェブキット
    @IBOutlet weak var webKit: WKWebView!
    
    // urlを受け取る
    var url: String = ""
    // itemInfoを受け取る
    var itemInfo: IndicatorInfo = ""
    
    // tableViewのインスタンス
    var tableView: UITableView = UITableView()
    // xmlパースのインスタンス
    var parser: XMLParser = XMLParser()
    // UIRefreshControl型の変数
    var refreshControl: UIRefreshControl!
    // 取得するニュースを格納する配列
    var articles: [Any] = []
    
    // XMLファイルに解析をかけた情報
    var elements = NSMutableDictionary()
    // XMLファイルのタグ情報
    var element: String = ""
    // XMLファイルのタイトル情報
    var titleString: String = ""
    // XMLファイルのリンク情報
    var linkString: String = ""
    // XMLファイルの画像情報
    var imageString: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // UIRefreshControlのインスタンスを生成
        refreshControl = UIRefreshControl()
        // 画面を引っ張った時の処理
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        // ツールバーとウェブキットを隠す
        toolBar.isHidden = true
        webKit.isHidden = true
        
        // delegateの設定
        tableView.delegate = self
        tableView.dataSource = self
        webKit.navigationDelegate = self
        // tabelViewの配置 (左上からx=0,y=50の場所から横に画面幅分、縦に画面幅　ー　ツールバー分の高さで表示する)
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: view.frame.height - 50.0)
        
        // URLをパースする
        parseURL()
        // tableViewの表示
        self.view.addSubview(tableView)
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return itemInfo
    }
    
    // セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    // セルの数を指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    // セルのカスタマイズ
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        
        // セルの背景色を決める
        cell.backgroundColor = #colorLiteral(red: 0.2084727883, green: 1, blue: 0.8079068065, alpha: 1)
        
        // セルに画像をセット
        if let stringURL = (articles[indexPath.row] as AnyObject).value(forKey: "image") as? String  {
            cell.imageView?.image = getImageByURL(url: stringURL)
        }
        
        // 記事タイトル
        cell.textLabel?.text = (articles[indexPath.row] as AnyObject).value(forKey: "title") as? String
        // セルのタイトルのフォント
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        // セルのタイトルの色
        cell.textLabel?.textColor = UIColor.black
        
        // 記事URL
        cell.detailTextLabel?.text = (articles[indexPath.row] as AnyObject).value(forKey: "link") as? String
        // セルのURLのフォント
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13.0)
        // セルのURLの色
        cell.detailTextLabel?.textColor = UIColor.gray
        
        return cell
    }
    
    // セルのタップアクション
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // webKitを表示させる
        let linkURL = ((articles[indexPath.row] as AnyObject).value(forKey: "link") as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let urlStr = (linkURL?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))!
        guard let url = URL(string: urlStr) else { return }
        let urlRequest = NSURLRequest(url: url)
        webKit.load(urlRequest as URLRequest)
    }
    
    // ページの読み込みが終了した時の処理
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // ページの読み込みが終わったタイミングでtableViewを隠し,toolBarとwebKitを表示させる
        tableView.isHidden = true
        toolBar.isHidden = false
        webKit.isHidden = false
    }
    
    // XMLをパースする
    func parseURL() {
        // 遷移元から受け取ったString型のURLをURL型にキャストして格納
        let urlToSend: URL = URL(string: url)! // url: 遷移元から受け取るurl
        // パースの対象を入れる
        parser = XMLParser(contentsOf: urlToSend)!
        // 記事情報の初期化
        articles = []
        // parserのdelegateを設定
        parser.delegate = self
        // 解析開始
        parser.parse()
        // tabeleViewのリロード
        tableView.reloadData()
    }
    
    // 開始タグを見つけた時に呼ばれる処理 (elementNameにはタグ情報が入っている)
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        element = elementName
        
        // タグにitemが入っている時
        if element == "item" {
            
            // 初期化
            elements = [:]
            titleString = ""
            linkString = ""
            imageString = ""
        }
        
        // タグ名がenclosureの時の処理
        if element == "enclosure" {
            guard let string = attributeDict["url"] else { return }
            imageString.append(string)
        }
    }
    
    // 開始タグと終了タグでくくられたデータがあったときに実行されるメソッド
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if element == "title" {
            // stringにタイトルが入っているので、appendする
            titleString.append(string)
        } else if element == "link" {
            linkString.append(string)
        }
    }
    
    // 解析中に要素の終了タグがあったときに実行されるメソッド
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        // アイテムという要素内にあるなら
        if elementName == "item" {
            // titleStringの中身が空でないなら
            if titleString != "" {
                // elementsに"title"というキーを付与しながらtitleStringをセット
                elements.setObject(titleString, forKey: "title" as NSCopying)
            }
            // linkStringの中身が空でないなら
            if linkString != "" {
                // elementsに"link"というキーを付与しながらlinkStringをセット
                elements.setObject(linkString, forKey: "link" as NSCopying)
            }
            if imageString != "" {
                // elementsに"image"というキーを付与しながらimageStringをセット
                elements.setObject(imageString, forKey: "image" as NSCopying)
            }
            // articlesの中にelementsを入れる
            articles.append(elements)
        }
    }
    
    // XMLファイルの画像情報(String型)からUIImage型にして返す関数
    func getImageByURL(url: String) -> UIImage? {
        // リサイズされた画像
        var resizedImage: UIImage!
        // URL型でurlを取得
        guard let url: URL = URL(string: url) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            // urlから画像を取得
            if let image = UIImage(data: data) {
                // 画像をリサイズ
                resizedImage = resize(image: image, width: 75)
            }
            return resizedImage
        } catch let err {
            print("Error: \(err.localizedDescription)")
        }
        return nil
    }
    
    // 画像のサイズを変更する関数
    func resize(image: UIImage, width: Double) -> UIImage {
        
        // オリジナル画像のサイズからアスペクト比を計算
        let aspectScale = image.size.height / image.size.width
        
        // widthからアスペクト比を元にリサイズ後のサイズを取得
        let resizedSize = CGSize(width: width, height: width * Double(aspectScale))
        
        // リサイズ後のUIImageを生成して返却
        UIGraphicsBeginImageContext(resizedSize)
        image.draw(in: CGRect(x: 0, y: 0, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage!
    }

    // refreshの処理
    @objc func refresh() {
        // 2秒後にdelay()を呼ぶ
        perform(#selector(delay), with: nil, afterDelay: 2.0)
    }
    
    // delayの処理
    @objc func delay() {
        parseURL()
        // インジケータの終了
        refreshControl.endRefreshing()
    }
    
    // ツールバーのアクション
    // キャンセル
    @IBAction func cancel(_ sender: Any) {
        tableView.isHidden = false
        toolBar.isHidden = true
        webKit.isHidden = true
    }
    
    // 前に戻る
    @IBAction func backPage(_ sender: Any) {
        webKit.goBack()
    }
    
    // 次に進む
    @IBAction func nextPage(_ sender: Any) {
        webKit.goForward()
    }
    
    // 再読み込み
    @IBAction func refreshPage(_ sender: Any) {
        webKit.reload()
    }
    
}
