//
//  ViewController.swift
//  RxLearnDemo
//
//  Created by song on 2018/9/19.
//  Copyright © 2018年 song. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    
    let items = Observable.just([
        "RxTableView",
        "RxCollectionView",
        "RxAlamofire",
        "文本标签的用法",
        ])

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.bindUI()
        self.bindData()
    }

}

extension ViewController {
    private func bindUI() {
        tableView = UITableView(frame: self.view.frame, style: .plain)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        view.addSubview(tableView)
        
    }
    
    private func bindData() {
        items.bind(to: tableView.rx.items) { (tableView, row, element) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = "\(row)：\(element)"
            return cell
        }
        .disposed(by: disposeBag)
        
        //获取选中项的索引
        tableView.rx.itemSelected.subscribe(onNext: { indexPath in
            print("选中项的indexPath为：\(indexPath)")
        }).disposed(by: disposeBag)
        
        //获取选中项的内容
        tableView.rx.modelSelected(String.self).subscribe(onNext: { item in
            self.selectedItem(item: item)
            print("选中项的标题为：\(item)")
        }).disposed(by: disposeBag)
    }
    
    private func selectedItem(item: String) {
        switch item {
        case "RxTableView":
            self.navigationController?.pushViewController(RxTableViewController(), animated: true)
        case "RxCollectionView":
            self.navigationController?.pushViewController(RxCollectionViewController(), animated: true)
        case "RxAlamofire":
            self.navigationController?.pushViewController(RxAlamofireViewController(), animated: true)
        default:
            print("vcName:\(item)")
        }
    }
}

