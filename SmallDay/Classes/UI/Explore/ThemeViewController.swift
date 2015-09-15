//
//  ThemeViewController.swift
//  SmallDay
//
//  Created by MacBook on 15/8/22.
//  Copyright (c) 2015年 维尼的小熊. All rights reserved.
//  ThemeCell点击出来的ViewController

import UIKit

class ThemeViewController: UIViewController, UIWebViewDelegate {
    
    private lazy var backView: UIView! = {
        let backView = UIView(frame: UIScreen.mainScreen().bounds)
        backView.backgroundColor = theme.SDBackgroundColor
        return backView
        }()
    
    private lazy var moreTableView: UITableView! = {
        let tableView = UITableView(frame: UIScreen.mainScreen().bounds, style: .Plain)
        tableView.backgroundColor = theme.SDBackgroundColor
        tableView.separatorStyle = .None
        tableView.rowHeight = DetailCellHeight
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: NavigationH, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "DetailCell", bundle: nil), forCellReuseIdentifier: "DetailCell")
        return tableView
        }()
    
    private lazy var shareView: ShareView? = {
        let shareView = ShareView.shareViewFromXib()
        return shareView
        }()
    
    private lazy var webView: UIWebView? = {
        let web = UIWebView(frame: UIScreen.mainScreen().bounds)
        web.backgroundColor = theme.SDBackgroundColor
        web.delegate = self
        return web
        }()
    
    var themeModel: ThemeModel? {
        didSet {
            if themeModel?.hasweb == 1 {
                self.webView?.loadRequest(NSURLRequest(URL: NSURL(string: themeModel!.themeurl!)!))
                shareView?.shareModel = ShareModel(shareTitle: themeModel?.title, shareURL: themeModel?.themeurl, image: nil, shareDetail: themeModel?.text)
            }
        }
    }
    
    private var modalBtn: UIButton! = UIButton()
    var more: DetailModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 初始化UI
        setUpUI()
        // 加载更多数据
        loadMore()
        // 添加modalBtn
        addModalBtn()
    }
    
    private func setUpUI() {
        view.backgroundColor = UIColor.whiteColor()
        view.addSubview(backView)
        backView.addSubview(moreTableView)
        backView.addSubview(webView!)
        navigationItem.rightBarButtonItem = UIBarButtonItem(imageName: "share_1", highlImageName: "share_2", targer: self, action: "shareClick")
    }
    
    private func loadMore() {
        weak var tmpSelf = self
        DetailModel.loadMore { (data, error) -> () in
            if error != nil {
                SVProgressHUD.showErrorWithStatus("网络不给力")
                return
            }
            
            tmpSelf!.more = data!
            tmpSelf!.moreTableView.reloadData()
        }
    }
    
    private func addModalBtn() {
        let modalWH: CGFloat = NavigationH
        modalBtn.frame = CGRectMake(10, AppHeight - modalWH - 10 - NavigationH, modalWH, modalWH)
        modalBtn.setImage(UIImage(named: "themelist"), forState: .Normal)
        modalBtn.setImage(UIImage(named: "themeweb"), forState: .Selected)
        modalBtn.addTarget(self, action: "modalClick:", forControlEvents: .TouchUpInside)
        view.addSubview(modalBtn)
    }
    
    ///MARK: - ButtonAction
    func shareClick() {
        view.addSubview(shareView!)
        shareView!.showShareView(CGRectMake(0, AppHeight - 215 - 64, AppWidth, 215))
        shareView!.shareVC = self
    }
    
    func modalClick(sender: UIButton) {
        sender.selected = !sender.selected
        if sender.selected {
            UIView.transitionFromView(webView!, toView: moreTableView, duration: 1.0, options: UIViewAnimationOptions.TransitionFlipFromLeft, completion:nil)
        } else {
            UIView.transitionFromView(moreTableView, toView: webView!, duration: 1.0, options: UIViewAnimationOptions.TransitionFlipFromRight, completion: nil)
        }
    }
    
    /// WebViewDelegate
    func webViewDidFinishLoad(webView: UIWebView) {
        self.webView!.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 64, right: 0)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        modalBtn.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        modalBtn.hidden = false
    }
}

// MARK TableView的代理方法
extension ThemeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return more?.list?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DetailCell") as! DetailCell
        let everyModel = more!.list![indexPath.row]
        cell.model = everyModel
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let model = more!.list![indexPath.row]
        let eventVC = EventViewController()
        eventVC.model = model
        navigationController!.pushViewController(eventVC, animated: true)
    }
}




