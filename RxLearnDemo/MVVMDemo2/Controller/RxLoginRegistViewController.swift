//
//  RxLoginRegistViewController.swift
//  RxLearnDemo
//
//  Created by song on 2018/9/20.
//  Copyright © 2018年 song. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya

class RxLoginRegistViewController: UIViewController {
    //用户名输入框、以及验证结果显示标签
    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var usernameValidationOutlet: UILabel!
    
    //密码输入框、以及验证结果显示标签
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var passwordValidationOutlet: UILabel!
    
    //重复密码输入框、以及验证结果显示标签
    @IBOutlet weak var repeatedPasswordOutlet: UITextField!
    @IBOutlet weak var repeatedPasswordValidationOutlet: UILabel!
    
    //注册按钮
    @IBOutlet weak var signupOutlet: UIButton!
    
    @IBOutlet weak var signInActivityIndicator: UIActivityIndicatorView!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        
        super.viewDidLoad()
//        GitHubProvider.rx.request(.usernameexist("fdsfr12"))
//            .subscribe(onSuccess: { response in
//                //数据处理
//                let str = String(data: response.data, encoding: String.Encoding.utf8)
//                print("返回的数据是：", str ?? "")
//                print("返回代码是：",response.statusCode)
//            },onError: { error in
//                print("数据请求失败!错误原因：", error)
//            }).disposed(by: disposeBag)
//        // Do any additional setup after loading the view.
        
//        let testx = GitHubNetworkService().usernameAvailable("fdsfr12")
//        
//        
//        testx.subscribe(onNext: { element in
//            print(element)
//        })
//        testx.map { (value) -> Bool in
//            if value {
//                print("存在该用户")
//                return true
//            } else {
//                print("不存在该用户")
//                return false
//            }
//        }
//        testx.drive(signupOutlet.rx.isEnabled)
//        .disposed(by: disposeBag)
        
        //初始化ViewModel
        let viewModel = GitHubSignupViewModel()
        let input = GitHubSignupViewModel.Input(username: usernameOutlet.rx.text.orEmpty.asDriver(),
                                                password: passwordOutlet.rx.text.orEmpty.asDriver(),
                                                repeatedPassword: repeatedPasswordOutlet.rx.text.orEmpty.asDriver(),
                                                loginTaps: signupOutlet.rx.tap.asSignal())
        let output = viewModel.transform(input: input)
        
        //绑定数据
        output.validatedUsername
            .drive(usernameValidationOutlet.rx.validationResult)
            .disposed(by: disposeBag)
        
        output.validatedPassword
            .drive(passwordValidationOutlet.rx.validationResult)
            .disposed(by: disposeBag)
        
        output.validatedPasswordRepeated
            .drive(repeatedPasswordValidationOutlet.rx.validationResult)
            .disposed(by: disposeBag)
        
        output.signupEnabled
            .drive(onNext: { [weak self] valid in
                self?.signupOutlet.isEnabled = valid
                self?.signupOutlet.alpha = valid ? 1.0 : 0.3
            })
            .disposed(by: disposeBag)
        
        output.signupResult
            .drive(onNext: { [unowned self] result in
                self.showMessage("注册" + (result ? "成功" : "失败") + "!")
            })
            .disposed(by: disposeBag)
        
//        output.signingIn
//            .drive(UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
//            .disposed(by: disposeBag)
        output.signingIn
            .drive(signInActivityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        

    }
    
    //详细提示框
    func showMessage(_ message: String) {
        let alertController = UIAlertController(title: nil,
                                                message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

}
