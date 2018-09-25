//
//  UILabel+Rx.swift
//  RxLearnDemo
//
//  Created by song on 2018/9/21.
//  Copyright © 2018年 song. All rights reserved.
//

import RxSwift
import RxCocoa
import CoreLocation

//UILabel的Rx扩展
extension Reactive where Base: UILabel {
    //实现CLLocationCoordinate2D经纬度信息的绑定显示
    var coordinates: Binder<CLLocationCoordinate2D> {
        return Binder(base) { label, location in
            label.text = "经度: \(location.longitude)\n纬度: \(location.latitude)"
        }
    }
}
