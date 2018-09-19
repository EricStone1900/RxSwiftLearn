//
//  RxTableCustomViewController.swift
//  RxLearnDemo
//
//  Created by song on 2018/9/19.
//  Copyright © 2018年 song. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class RxTableCustomViewController: UIViewController {
    
    var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    
    var dataSource: RxTableViewSectionedReloadDataSource<CustomSection>?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
        self.bindUI()
        self.bindData()
    }

}

extension RxTableCustomViewController {
    private func bindUI() {
        tableView = UITableView(frame: self.view.frame, style: .plain)
        tableView.register(UINib(nibName: "ImgViewCell", bundle: nil), forCellReuseIdentifier: "ImgViewCell")
        tableView.register(UINib(nibName: "SwitchViewCell", bundle: nil), forCellReuseIdentifier: "SwitchViewCell")
        view.addSubview(tableView)
    }
    
    private func bindData() {
        //初始化数据
        let sections = Observable.just([
            CustomSection(header: "我是第一个分区", items: [
                .TitleImageSectionItem(title: "图片数据1", image: UIImage(named: "Image1")!),
                .TitleImageSectionItem(title: "图片数据2", image: UIImage(named: "Image2")!),
                .TitleSwitchSectionItem(title: "开关数据1", enabled: true)
                ]),
            CustomSection(header: "我是第二个分区", items: [
                .TitleSwitchSectionItem(title: "开关数据2", enabled: false),
                .TitleSwitchSectionItem(title: "开关数据3", enabled: false),
                .TitleImageSectionItem(title: "图片数据3", image: UIImage(named: "Image2")!)
                ])
            ])
        
        //创建数据源
        dataSource = RxTableViewSectionedReloadDataSource<CustomSection>(
            //设置单元格
            configureCell: { dataSource, tableView, indexPath, item in
                switch dataSource[indexPath] {
                case let .TitleImageSectionItem(title, image):
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ImgViewCell", for: indexPath) as! ImgViewCell
                    cell.titleLabel.text = title
                    cell.theImgView.image = image
                    return cell
                case let .TitleSwitchSectionItem(title, enabled):
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchViewCell", for: indexPath) as! SwitchViewCell
                    cell.titleLabel.text = title
                    cell.swichBtn.isOn = enabled
                    return cell
                }
        },
            //设置分区头标题
            titleForHeaderInSection: { ds, index in
                return ds.sectionModels[index].header
        }
        )
        
        //绑定单元格数据
        sections
            .bind(to: tableView.rx.items(dataSource: dataSource!))
            .disposed(by: disposeBag)
        
        //设置代理
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
}

extension RxTableCustomViewController: UITableViewDelegate {
    //设置单元格高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath)
        -> CGFloat {
            guard let _ = dataSource?[indexPath],
                let _ = dataSource?[indexPath.section]
                else {
                    return 0.0
            }
            
            return 60
    }
    
    //返回分区头部视图
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int)
        -> UIView? {
            let headerView = UIView()
            headerView.backgroundColor = UIColor.black
            let titleLabel = UILabel()
            titleLabel.text = self.dataSource?[section].header
            titleLabel.textColor = UIColor.white
            titleLabel.sizeToFit()
            titleLabel.center = CGPoint(x: self.view.frame.width/2, y: 20)
            headerView.addSubview(titleLabel)
            return headerView
    }
    //返回分区底部部视图
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.lightGray
        let titleLabel = UILabel()
        titleLabel.text = "共有\(String(describing: self.dataSource![section].items.count))条数据"
        titleLabel.textColor = UIColor.yellow
        titleLabel.sizeToFit()
        titleLabel.center = CGPoint(x: self.view.frame.width/2, y: 10)
        footerView.addSubview(titleLabel)
        return footerView
    }
    
    
    //返回分区头部高度
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int)
        -> CGFloat {
            return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 25
    }
}

//单元格类型
enum SectionItem {
    case TitleImageSectionItem(title: String, image: UIImage)
    case TitleSwitchSectionItem(title: String, enabled: Bool)
}

//自定义Section
struct CustomSection {
    var header: String
    var items: [SectionItem]
}

extension CustomSection : SectionModelType {
    typealias Item = SectionItem
    
    init(original: CustomSection, items: [Item]) {
        self = original
        self.items = items
    }
}
