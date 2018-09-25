//
//  RefreshViewModel.swift
//  RxLearnDemo
//
//  Created by song on 2018/9/21.
//  Copyright © 2018年 song. All rights reserved.
//

import RxSwift
import RxCocoa

class RefreshViewModel {
    //input
    struct Input {
        let headerRefresh: Driver<Void>
    }
    //output
    struct Output {
        let tableData:Driver<[String]>
        let endHeaderRefreshing: Driver<Bool>
    }
    
    private var refreshService: RefreshServiceTest
    
    init() {
        self.refreshService = RefreshServiceTest()
    }
    
    func transform(input: Input) -> Output {
        let tableData = input.headerRefresh
            .startWith(())//初始化完毕时会自动加载一次数据
            .flatMapLatest { _ in
                self.refreshService.getRandomResult()
            }
        
        let endHeaderRefreshing = tableData.map { _ in true}
        return Output(tableData: tableData,
                      endHeaderRefreshing: endHeaderRefreshing)
    }
}
