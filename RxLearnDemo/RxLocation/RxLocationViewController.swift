//
//  RxLocationViewController.swift
//  RxLearnDemo
//
//  Created by song on 2018/9/21.
//  Copyright © 2018年 song. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RxLocationViewController: UIViewController {
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var label: UILabel!
    
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //获取地理定位服务
        let geolocationService = GeolocationService.instance
        
        //定位权限绑定到按钮上(是否可见)
        geolocationService.authorized
            .drive(button.rx.isHidden)
            .disposed(by: disposeBag)
        
        //经纬度信息绑定到label上显示
        geolocationService.location
            .drive(label.rx.coordinates)
            .disposed(by: disposeBag)
        
        //按钮点击
        button.rx.tap
            .bind { [weak self] _ -> Void in
                self?.openAppPreferences()
            }
            .disposed(by: disposeBag)
    }
    
    //跳转到应有偏好的设置页面
    private func openAppPreferences() {
        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
    }

}
