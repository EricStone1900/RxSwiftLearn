//
//  RefreshService.swift
//  RxLearnDemo
//
//  Created by song on 2018/9/21.
//  Copyright © 2018年 song. All rights reserved.
//

import RxSwift
import RxCocoa

//网络请求服务
class RefreshServiceTest {
    //获取随机数据
    func getRandomResult() -> Driver<[String]> {
        print("正在请求数据......")
        let items = (0 ..< 15).map {_ in
            "随机数据\(Int(arc4random()))"
        }
        let observable = Observable.just(items)
        return observable
            .delay(1, scheduler: MainScheduler.instance)
            .asDriver(onErrorDriveWith: Driver.empty())
    }
}
