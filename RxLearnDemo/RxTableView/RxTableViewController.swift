//
//  RxTableViewController.swift
//  RxLearnDemo
//
//  Created by song on 2018/9/19.
//  Copyright © 2018年 song. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RxTableViewController: UIViewController {

    var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    
    let items = Observable.just([
        "RxTableView-基本用法",
        "RxTableView-DataSource-single",
        "RxTableView-DataSource-multi",
        "RxTableView-DataSource-editable",
        "RxTableView-DataSource-custom",
        ])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.bindUI()
        self.bindData()
    }
}

extension RxTableViewController {
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
        tableView.rx.modelSelected(String.self).subscribe(onNext: { [weak self] item in
            self?.selectedItem(item: item)
            print("选中项的标题为：\(item)")
        }).disposed(by: disposeBag)
        
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(String.self))
            .bind { indexPath, item in
                print("选中项的indexPath为：\(indexPath)")
                print("选中项的标题为：\(item)")
            }
            .disposed(by: disposeBag)
        
        //获取删除项的索引
        tableView.rx.itemDeleted.subscribe(onNext: { [weak self] indexPath in
            self?.showlog(msg: "删除项的indexPath为：\(indexPath)")
        }).disposed(by: disposeBag)
        
        //获取删除项的内容
        tableView.rx.modelDeleted(String.self).subscribe(onNext: {[weak self] item in
            self?.showlog(msg: "删除项的的标题为：\(item)")
        }).disposed(by: disposeBag)
        
        //获取移动项的索引
        tableView.rx.itemMoved.subscribe(onNext: { [weak self]
            sourceIndexPath, destinationIndexPath in
            self?.showlog(msg: "移动项原来的indexPath为：\(sourceIndexPath)")
            self?.showlog(msg: "移动项现在的indexPath为：\(destinationIndexPath)")
        }).disposed(by: disposeBag)
    }
    
    private func selectedItem(item: String) {
        print("vcName:\(item)")
        switch item {
        case "RxTableView-DataSource-single":
            self.navigationController?.pushViewController(RxTabeDataSourceViewController(type: .SingleSection), animated: true)
        case "RxTableView-DataSource-multi":
            self.navigationController?.pushViewController(RxTabeDataSourceViewController(type: .MultiSection), animated: true)
        case "RxTableView-DataSource-editable":
            self.navigationController?.pushViewController(RxTabeEditableViewController(), animated: true)
        case "RxTableView-DataSource-custom":
            self.navigationController?.pushViewController(RxTableCustomViewController(), animated: true)
        default:
            print("vcName:\(item)")
        }
    }
    
    private func showlog(msg: String) {
        print("msg:\(msg)")
    }
}
