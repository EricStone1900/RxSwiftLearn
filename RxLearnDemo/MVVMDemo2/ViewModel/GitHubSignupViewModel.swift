//
//  GitHubSignupViewModel.swift
//  RxLearnDemo
//
//  Created by song on 2018/9/21.
//  Copyright © 2018年 song. All rights reserved.
//

import RxSwift
import RxCocoa

class GitHubSignupViewModel {
    //input
    struct Input {
        let username: Driver<String>
        let password: Driver<String>
        let repeatedPassword: Driver<String>
        let loginTaps: Signal<Void>
    }
    
    //output
    struct Output {
        //用户名验证结果
        let validatedUsername: Driver<ValidationResult>
        
        //密码验证结果
        let validatedPassword: Driver<ValidationResult>
        
        //再次输入密码验证结果
        let validatedPasswordRepeated: Driver<ValidationResult>
        
        //注册按钮是否可用
        let signupEnabled: Driver<Bool>
        
        //注册结果
        let signupResult: Driver<Bool>
        
        //点击注册按钮-》正在注册中
        let signingIn: Driver<Bool>

    }
    
//    private let networkService: GitHubNetworkService
    private let signupService: GitHubSignupService
    
    init() {
//        self.networkService = GitHubNetworkService()
        self.signupService = GitHubSignupService()
    }
    
    func transform(input: Input) -> Output {
        //用户名验证
        let validatedUsername = input.username
            .flatMapLatest { userName in
                return self.signupService.validateUsername(userName)
                    .asDriver(onErrorJustReturn: .failed(message: "服务器发生错误!"))
        }
        //用户密码验证
        let validatedPassword = input.password
            .map { password in
                return self.signupService.validatePassword(password)
        }
        
        //重复输入密码验证
        let validatedPasswordRepeated = Driver.combineLatest(
            input.password,
            input.repeatedPassword,
            resultSelector: self.signupService.validateRepeatedPassword)
        
        //注册按钮是否可用
        let signupEnabled = Driver.combineLatest(
            validatedUsername,
            validatedPassword,
            validatedPasswordRepeated
        ) { username, password, repeatPassword in
            username.isValid && password.isValid && repeatPassword.isValid
        }
        .distinctUntilChanged()
        
        //获取最新的用户名和密码
        let usernameAndPassword = Driver.combineLatest(input.username, input.password) {
            (username: $0, password: $1)
        }
        
        //用于检测是否正在请求数据
        let activityIndicator = ActivityIndicator()
        let signingIn = activityIndicator.asDriver()
        
        //注册按钮点击结果
        let signupResult = input.loginTaps.withLatestFrom(usernameAndPassword)
            .flatMapLatest { pair in
                return self.signupService.signup(pair.username, password: pair.password)
                    .trackActivity(activityIndicator)
                    .asDriver(onErrorJustReturn: false)
        }
        
        return Output(validatedUsername: validatedUsername,
                      validatedPassword: validatedPassword,
                      validatedPasswordRepeated: validatedPasswordRepeated,
                      signupEnabled: signupEnabled,
                      signupResult: signupResult,
                      signingIn: signingIn
        )
    }
}
