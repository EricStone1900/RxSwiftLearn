//
//  GitHubNetworkService.swift
//  RxLearnDemo
//
//  Created by song on 2018/9/20.
//  Copyright © 2018年 song. All rights reserved.
//

import RxSwift
import RxCocoa
import ObjectMapper

class GitHubNetworkService {
    
    
    //搜索资源数据
    func searchRepositories(query:String) -> Driver<GitHubRepositories> {
        return GitHubProvider.rx.request(.repositories(query))
            .filterSuccessfulStatusCodes()
            .mapObject(GitHubRepositories.self)
            .asDriver(onErrorDriveWith: Driver.empty())
    }
    
    //验证用户是否存在
    func usernameAvailable(_ username: String) -> Observable<Bool>{
        return GitHubProvider.rx.request(.usernameexist(username))
//            .filterSuccessfulStatusCodes()
            .map { response in
                print("请求返回response:",response.statusCode)
                if response.statusCode == 404 {//用户不存在
                   return false
                } else {//用户存在
                    return true
                }                
            }
            .asObservable()
    }
    
}
