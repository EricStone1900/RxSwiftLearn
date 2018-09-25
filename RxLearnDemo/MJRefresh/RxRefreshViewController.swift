//
//  RxRefreshViewController.swift
//  RxLearnDemo
//
//  Created by song on 2018/9/21.
//  Copyright © 2018年 song. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RxRefreshViewController: UIViewController {
    var tableView:UITableView!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        //创建表格视图
        self.tableView = UITableView(frame: self.view.frame, style:.plain)
        //创建一个重用的单元格
        self.tableView!.register(UITableViewCell.self,
                                 forCellReuseIdentifier: "Cell")
        self.view.addSubview(self.tableView!)
        
//        //设置头部刷新控件
//        self.tableView.mj_header = MJRefreshNormalHeader()
    }
}
