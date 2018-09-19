//
//  RxTabeDataSourceViewController.swift
//  RxLearnDemo
//
//  Created by song on 2018/9/19.
//  Copyright © 2018年 song. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

enum RxTabeDataSourceType {
    case SingleSection
    case MultiSection
}

class RxTabeDataSourceViewController: UIViewController {
//    let refreshButton = { () -> UIBarButtonItem in
//        let btn = UIBarButtonItem(barButtonSystemItem: .refresh, target: nil, action: nil)
//        return btn
//    }
    private lazy var refreshButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(barButtonSystemItem: .refresh, target: nil, action: nil)
        return btn
    }()
    
//    let stopButton = { () -> UIBarButtonItem in
//        let btn = UIBarButtonItem(barButtonSystemItem: .stop, target: nil, action: nil)
//        return btn
//    }
    
    /// 这里我们在前面样例的基础上增加了个“停止”按钮。当发起请求且数据还未返回时（2 秒内），按下该按钮后便会停止对结果的接收处理，即表格不加载显示这次的请求数据。
    private lazy var stopButton : UIBarButtonItem = {
        let btn = UIBarButtonItem(barButtonSystemItem: .stop, target: nil, action: nil)
        return btn
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 56))
        return searchBar
    }()
    
    var tableViewType: RxTabeDataSourceType!
    var tableView: UITableView!
    
    var sections: Observable<[MySection]>?
    
    let disposeBag = DisposeBag()
    
    init(type: RxTabeDataSourceType) {
        super.init(nibName: nil, bundle: nil)
        self.tableViewType = type
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindUI()
        self.bindRandomData()
//        switch tableViewType {
//        case .SingleSection:
//            view.backgroundColor = UIColor.yellow
////            self.bindSingData()
//        case .MultiSection:
//            view.backgroundColor = UIColor.red
////            self.bindMutiData()
//        default:
//            view.backgroundColor = UIColor.white
//        }
    }

}

extension RxTabeDataSourceViewController {
    private func bindUI() {
        tableView = UITableView(frame: self.view.frame, style: .plain)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        view.addSubview(tableView)
        
//        self.navigationItem.rightBarButtonItem = refreshButton()
        self.navigationItem.rightBarButtonItems = [refreshButton,stopButton]
        
        tableView.tableHeaderView = searchBar
    }
    
    private func bindRandomData() {
        //随机的表格数据
//        sections = refreshButton.rx.tap.asObservable()
//            .throttle(1, scheduler: MainScheduler.instance) //在主线程中操作，1秒内值若多次改变，取最后一次
//            .startWith(()) //加这个为了让一开始就能自动请求一次数据
//            .flatMapLatest(getRandomResult)
//            .share(replay: 1)
        sections = refreshButton.rx.tap.asObservable()
            .throttle(1, scheduler: MainScheduler.instance) //在主线程中操作，1秒内值若多次改变，取最后一次
            .startWith(()) //加这个为了让一开始就能自动请求一次数据
            .flatMapLatest {_ in
                self.getRandomResult().takeUntil(self.stopButton.rx.tap)
            }
            .flatMap(filterResult)
            .share(replay: 1)
        
        self.bindCommonData()
    }
    
    private func bindSingData() {
        //初始化数据
        sections = Observable.just([
            MySection(header: "", items: [
                "UILable的用法",
                "UIText的用法",
                "UIButton的用法"
                ])
            ])
        self.bindCommonData()

    }
    
    private func bindMutiData() {
        //初始化数据
        sections = Observable.just([
            MySection(header: "基本控件", items: [
                "UILable的用法",
                "UIText的用法",
                "UIButton的用法"
                ]),
            MySection(header: "高级控件", items: [
                "UITableView的用法",
                "UICollectionViews的用法"
                ])
            ])
        self.bindCommonData()
    }
    
    private func bindCommonData() {
        //创建数据源
        let dataSource = RxTableViewSectionedAnimatedDataSource<MySection>(
            //设置单元格
            configureCell: { ds, tv, ip, item in
                let cell = tv.dequeueReusableCell(withIdentifier: "Cell")
                    ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
                cell.textLabel?.text = "\(ip.row)：\(item)"
                return cell
        },
            //设置分区头标题
            titleForHeaderInSection: { ds, index in
                return ds.sectionModels[index].header
        }
        )

        
        //绑定单元格数据
        sections?
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        //获取选中项的索引
        tableView.rx.itemSelected.subscribe(onNext: { indexPath in
            print("选中项的indexPath为：\(indexPath)")
        }).disposed(by: disposeBag)
        
        //获取选中项的内容
        tableView.rx.modelSelected(String.self).subscribe(onNext: { item in
            print("选中项的标题为：\(item)")
        }).disposed(by: disposeBag)
    }
    
    //获取随机数据
    private func getRandomResult() -> Observable<[MySection]> {
        print("正在请求数据......")//可以加个交互loading
        let items = (0 ..< 5).map {_ in
            String(arc4random())
        }
        let itemsOne = (0 ..< 5).map {_ in
            String(arc4random())
        }
        let itemsTwo = (0 ..< 5).map {_ in
            String(arc4random())
        }
        var observable: Observable<[MySection]>?
        switch tableViewType {
        case .SingleSection:
            observable = Observable.just([MySection(header: "", items: items)])
        case .MultiSection:
            let mySections = [
                MySection(header: "item1", items: itemsOne),
                MySection(header: "item2", items: itemsTwo)
            ]
            observable = Observable.just(mySections)
        default:
            view.backgroundColor = UIColor.white
        }
        
        return observable!.delay(2, scheduler: MainScheduler.instance)
    }
    
    //过滤数据
    private func filterResult(data:[MySection]) -> Observable<[MySection]> {
        return self.searchBar.rx.text.orEmpty
            .debounce(0.5, scheduler: MainScheduler.instance) //只有间隔超过0.5秒才发送
            .flatMapLatest {
                query -> Observable<[MySection]> in
                print("正在筛选数据（条件为：\(query)）")
                //输入条件为空，则直接返回原始数据
                if query.isEmpty {
                    return Observable.just(data)
                } else {
                    //输入条件为不空，则只返回包含有该文字的数据
                    var newData:[MySection] = []
                    for sectionModel in data {
                        let items = sectionModel.items.filter{"\($0)".contains(query)}
                        newData.append(MySection(header: sectionModel.header, items: items))
                    }
                    return Observable.just(newData)
                }
        }
    }
}

//自定义Section
struct MySection {
    var header: String
    var items: [Item]
}

extension MySection : AnimatableSectionModelType {
    typealias Item = String
    
    var identity: String {
        return header
    }
    
    init(original: MySection, items: [Item]) {
        self = original
        self.items = items
    }
}
