//
//  MoyaServiceViewController.swift
//  RxLearnDemo
//
//  Created by song on 2018/9/20.
//  Copyright © 2018年 song. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya

class MoyaServiceViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        //获取数据
        DouBanProvider.rx.request(.channels)
            .subscribe(onSuccess: { response in
                //数据处理
                let str = String(data: response.data, encoding: String.Encoding.utf8)
                print("返回的数据是：", str ?? "")
            },onError: { error in
                print("数据请求失败!错误原因：", error)
            }).disposed(by: disposeBag)
        

    }
}
