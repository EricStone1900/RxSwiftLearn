//
//  RxAlamofireViewController.swift
//  RxLearnDemo
//
//  Created by song on 2018/9/19.
//  Copyright © 2018年 song. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import RxAlamofire

class RxAlamofireViewController: UIViewController {
    
    //“发起请求”按钮
    lazy var startBtn: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect(x: 40, y: 80, width: 60, height: 30)
        btn.setTitle("开始", for: .normal)
        btn.backgroundColor = UIColor.blue
        return btn
    }()
    
    //“取消请求”按钮
    lazy var cancelBtn: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect(x: 40, y: 140, width: 60, height: 30)
        btn.setTitle("结束", for: .normal)
        btn.backgroundColor = UIColor.blue
        return btn
    }()
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        bindUI()
        //创建URL对象
        let urlString = "https://www.douban.com/j/app/radio/channels"
        let url = URL(string:urlString)!
        
        //发起请求按钮点击
        startBtn.rx.tap.asObservable()
            .flatMap {_ in
                request(.get, url).responseString()
                    .takeUntil(self.cancelBtn.rx.tap) //如果“取消按钮”点击则停止请求
            }
            .subscribe(onNext: {
                response, data in
                print("请求成功！返回的数据是：", data)
            }, onError: { error in
                print("请求失败！错误原因：", error)
            }).disposed(by: disposeBag)
//        startBtn.rx.tap.asObservable()
//            .flatMap {_ in
//                request(.get, method: url).responseString()
//                    .takeUntil(self.cancelBtn.rx.tap) //如果“取消按钮”点击则停止请求
//            }
//            .subscribe(onNext: {
//                response, data in
//                print("请求成功！返回的数据是：", data)
//            }, onError: { error in
//                print("请求失败！错误原因：", error)
//            }).disposed(by: disposeBag)
    }

}

extension RxAlamofireViewController {
    private func bindUI() {
        self.view.addSubview(startBtn)
        self.view.addSubview(cancelBtn)
    }
}
