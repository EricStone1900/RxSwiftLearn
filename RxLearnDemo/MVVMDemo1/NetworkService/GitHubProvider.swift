//
//  GitHubProvider.swift
//  RxLearnDemo
//
//  Created by song on 2018/9/20.
//  Copyright © 2018年 song. All rights reserved.
//

import Foundation
import Moya

let GitHubProvider = MoyaProvider<GitHubAPI>()

public enum GitHubAPI {
    case repositories(String)  //查询资源库
    case usernameexist(String)
    case placeholder
}

extension GitHubAPI: TargetType {
    //服务器地址
    public var baseURL: URL {
        switch self {
        case .repositories:
            return URL(string: "https://api.github.com")!
        case .usernameexist:
            return URL(string: "https://github.com")!
        case .placeholder:
            return URL(string: "https://api.github.com")!
        }
        
    }
    
    //各个请求的具体路径
    public var path: String {
        switch self {
        case .repositories:
            return "/search/repositories"
        case .usernameexist(let username):
            return "/\(username)"
        case .placeholder:
            return ""
        }
    }
    
    //请求类型
    public var method: Moya.Method {
        switch self {
        case .repositories:
            return .get
        case .usernameexist:
            return .get
        case .placeholder:
            return .post
        }
    }
    
    //请求任务事件（这里附带上参数）
    public var task: Task {
        print("发起请求。")
        switch self {
        case .repositories(let query):
            var params: [String: Any] = [:]
            params["q"] = query
            params["sort"] = "stars"
            params["order"] = "desc"
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        case .usernameexist:
            return .requestPlain
        default:
            return .requestPlain
        }
    }
    
    //是否执行Alamofire验证
    public var validate: Bool {
        return false
    }
    
    //这个就是做单元测试模拟的数据，只会在单元测试文件中有作用
    public var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
    
    //请求头
    public var headers: [String: String]? {
        return nil
    }
}
