//
//  UILabel+RxBind.swift
//  RxLearnDemo
//
//  Created by song on 2018/9/21.
//  Copyright © 2018年 song. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UILabel {
    //让验证结果（ValidationResult类型）可以绑定到label上
    var validationResult: Binder<ValidationResult> {
        return Binder(base) { label, result in
            label.textColor = result.textColor
            label.text = result.description
        }
    }
}
