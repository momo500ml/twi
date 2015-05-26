//
//  ViewController.swift
//  Twitter
//
//  Created by Motoharu Kojima on 2015/05/04.
//  Copyright (c) 2015年 Motoharu Kojima. All rights reserved.
//

import UIKit
import Social
import Accounts
import Twitter


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let SCREEN = UIScreen.mainScreen().bounds.size//画面サイズ
    
    //変数
    @IBOutlet weak var _tableview: UITableView!
    
    var _accountStore:ACAccountStore?
    var _account: ACAccount?
    var _items = [Status]()
    var selectedRow: Int = 0
    var buttonNumber: Int = 0
    
    //UI========================
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UI
        self.title = "Twitterクライアント"
        //self._scrollview.addSubview(self._tableview)
        //アカウントの取得
        initTwitterAccount()
        
    }
    
    
    
    //ツールバーのボタンクリック時に呼ばれる
    @IBAction func onClick(sender: UIBarButtonItem) {
        if _account == nil {
            initTwitterAccount()
            return
        }
        if sender.tag == 0 {
            timeline()
        } else if sender.tag == 1 {
            twit()
        }
    }
    //返信ボタンクリック時に呼ばれる
    @IBAction func reply(sender: UIButton) {
        let twitterCtl = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        let status = _items[selectedRow]
        
        let title: String = "@" + status.name + " "
        twitterCtl.setInitialText(title)
        self.presentViewController(twitterCtl, animated: true, completion: nil)
        
    }
    
    //ボタンの作成
    func makeButton(fram: CGRect, image: UIImage) -> UIButton {
        let button = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        button.frame = fram
        button.setImage(image, forState: UIControlState.Normal)
        button.addTarget(self, action: "reply:", forControlEvents: UIControlEvents.TouchUpInside)
        return button
    }
    
    //ラベルの生成
    func makeLabel(frame: CGRect,text: NSString, font: UIFont) -> UILabel {
        let label = UILabel()
        label.frame = frame
        label.text = text as String
        label.font = font
        label.textColor = UIColor.blackColor()
        label.backgroundColor = UIColor.clearColor()
        label.textAlignment = NSTextAlignment.Left
        label.lineBreakMode = NSLineBreakMode.ByCharWrapping
        label.numberOfLines = 0
        return label
    }
    
    //イメージビューの生成
    func makeImageView(frame: CGRect, image: UIImage?) -> UIImageView {
        let imageView = UIImageView()
        imageView.frame = frame
        imageView.image = image
        return imageView
    }
    
    //アラートの表示
    func showAlert(title: NSString?, text: NSString?) {
        let alert = UIAlertController(title: title as? String, message: text as? String, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //インジケーターの指定
    func setIndicator(indicator: Bool) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = indicator
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //セルの数取得時に呼ばれる
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        buttonNumber = _items.count
        return _items.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // 選択されたセルの行数を記録
        self.selectedRow = indexPath.row
    }
    
    //セルの取得時に呼ばれる
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //テーブルのセルの生成
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("table_cell") as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "table_cell")
            
            self._tableview?.rowHeight = 60
            self._tableview?.scrollEnabled = true
            //アイコンの追加
            let imgIcon = makeImageView(CGRectMake(10, 0, 40, 40 ), image: nil)
            imgIcon.tag = 1
            cell!.contentView.addSubview(imgIcon)
            
            //名前の追加
            let lblName = makeLabel(CGRectMake(60, 0, 250, 16), text: "", font: UIFont.boldSystemFontOfSize(12))
            lblName.tag = 2
            cell!.contentView.addSubview(lblName)
            
            //スクリーンネームの追加
            let lblScreenName = makeLabel(CGRectMake(250, 0, 250, 16), text: "", font: UIFont.boldSystemFontOfSize(10))
            lblScreenName.tag = 4
            cell!.contentView.addSubview(lblScreenName)
            
            
            //テキストの追加
            let lblText = makeLabel(CGRectMake(60, 10, 320, 2024), text: "", font: UIFont.systemFontOfSize(10))
            lblText.tag = 3
            cell!.contentView.addSubview(lblText)
            
            //返信ボタンの追加
            let buttonimage: UIImage? = UIImage(named: "reply.jpg")
            let repButton = makeButton(CGRectMake(UIScreen.mainScreen().bounds.size.width - 20, 0, 20, 20), image: buttonimage!)
            repButton.tag = 5
            
            cell!.contentView.addSubview(repButton)
            
        }
        if _items.count <= indexPath.row {return cell!}
        
        //ステータスの取得
        let status = _items[indexPath.row]
        
        //アイコンの指定
        let imgIcon = cell!.contentView.viewWithTag(1) as! UIImageView
        imgIcon.image = status.icon
        
        //名前の指定
        let lblName = cell!.contentView.viewWithTag(2) as! UILabel
        lblName.text = status.name
        
        //スクリーンネームの指定
        let lblScreenName = cell!.contentView.viewWithTag(4) as! UILabel
        lblScreenName.text = status.screenname
        
        //テキストの追加
        let lblText = cell!.contentView.viewWithTag(3) as! UILabel
        lblText.text = status.text
        lblText.frame = CGRectMake(60, 15, SCREEN.width-70, 1024)
        lblText.sizeToFit()
        
        //返信ボタンの指定
        let button = cell!.contentView.viewWithTag(5) as! UIButton
        
        return cell!
        
    }
    
    
    
    //twitterのアカウント情報の取得
    func initTwitterAccount(){
        _account = nil
        _accountStore = ACAccountStore()
        let twitterType = _accountStore?.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        _accountStore?.requestAccessToAccountsWithType(twitterType, options: nil) {(granted,error) in
            if granted {
                let accounts = self._accountStore?.accountsWithAccountType(twitterType)
                if accounts!.count > 0 {
                    self._account = accounts![0] as? ACAccount
                    self.timeline()
                    return
                }
            }
            dispatch_async(dispatch_get_main_queue(), {self.showAlert(nil,text: "Twitterアカウントが登録されていません")
            })
        }
    }
    
    //アイコンの読み込み
    func loadIcon(status: Status) {
        //通信によるアイコンの読み込み
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let request = NSURLRequest(URL: NSURL(string: status.iconURL)!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 30.0)
            let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: nil, error: nil)
            
            //テーブル更新
            dispatch_async(dispatch_get_main_queue()) {
                status.icon = UIImage(data: data!)
                self._tableview?.reloadData()
            }
        }
    }
    
    
    
    
    //タイムラインの取得
    func timeline() {
        //インジケータ表示
        self.setIndicator(true)
        
        //タイムラインの読み込み(2)
        let url = NSURL(string:
            "https://api.twitter.com/1.1/statuses/home_timeline.json")!
        let params: Dictionary<NSObject, AnyObject!> = ["count": "20"]
        let timeline = SLRequest(forServiceType: SLServiceTypeTwitter,
            requestMethod: SLRequestMethod.GET, URL: url, parameters: params)
        timeline.account = self._account
        timeline.performRequestWithHandler(){(responseData: NSData!,
            urlResponse: NSHTTPURLResponse!, error: NSError!) in
            //JSONのパース(3)
            var jsonError: NSError? = nil
            let obj : AnyObject? = NSJSONSerialization.JSONObjectWithData(
                responseData, options: nil, error: &jsonError)
            
            //エラー表示
            if error != nil {
                self.showAlert(nil, text: "通信失敗しました")
            } else if obj == nil || jsonError != nil {
                self.showAlert(nil, text: "パースに失敗しました")
            } else if !obj!.isKindOfClass(NSArray) {
                self.showAlert(nil, text: "パースに失敗しました")
            } else {
                //JSONをパースしたデータをStatusクラスの配列に変換(4)
                self._items.removeAll()
                let statuses = obj as! NSArray
                for var i = 0; i < statuses.count; i++ {
                    let item = Status()
                    let status = statuses[i] as! NSDictionary
                    let user  = status["user"] as! NSDictionary
                    item.text = status["text"] as! String
                    item.name  = user["screen_name"] as! String
                    item.iconURL = user["profile_image_url"] as! String
                    item.screenname = user["name"] as! String
                    self.loadIcon(item)
                    self._items.append(item)
                }
            }
            //テーブルの更新
            dispatch_async(dispatch_get_main_queue(), {
                let tableView = self._tableview
                tableView?.reloadData()
            })
            
            //インジケータの非表示
            self.setIndicator(false)
        }
        
    }
    
    //つぶやきの送信
    func twit() {
        let twitterCtl = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        self.presentViewController(twitterCtl, animated: true, completion: nil)
    }
    
    //バイト配列を文字列に変換
    func data2str(data: NSData) -> NSString {
        return NSString(data: data, encoding: NSUTF8StringEncoding)!
    }
    
    
    
}







