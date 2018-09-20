//
//  RxAlamofireViewController.swift
//  RxLearnDemo
//
//  Created by song on 2018/9/19.
//  Copyright © 2018年 song. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import RxAlamofire

class RxAlamofireViewController: UIViewController {
    
    //“发起请求”按钮
    lazy var startBtn: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect(x: 40, y: 80, width: 60, height: 30)
        btn.setTitle("开始", for: .normal)
        btn.backgroundColor = UIColor.blue
        return btn
    }()
    
    //“取消请求”按钮
    lazy var cancelBtn: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect(x: 40, y: 140, width: 60, height: 30)
        btn.setTitle("结束", for: .normal)
        btn.backgroundColor = UIColor.blue
        return btn
    }()
    
    //“上传请求”按钮
    lazy var uploadBtn: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect(x: 40, y: 200, width: 60, height: 30)
        btn.setTitle("上传", for: .normal)
        btn.backgroundColor = UIColor.blue
        return btn
    }()
    
    //“上传请求”loadingProgress按钮
    lazy var uploadProgressBtn: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect(x: 120, y: 200, width: 100, height: 30)
        btn.setTitle("上传loading", for: .normal)
        btn.backgroundColor = UIColor.blue
        return btn
    }()
    
    lazy var progressView: UIProgressView = {
        let progress = UIProgressView(frame: CGRect(x: 40, y: 240, width: 160, height: 8))
        return progress
    }()
    
    lazy var uploadMutiBtn: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect(x: 40, y: 270, width: 100, height: 30)
        btn.setTitle("上传Muti", for: .normal)
        btn.backgroundColor = UIColor.blue
        return btn
    }()
    
    //下载无进度按钮
    lazy var downLoadBtn: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect(x: 40, y: 330, width: 60, height: 30)
        btn.setTitle("下载", for: .normal)
        btn.backgroundColor = UIColor.blue
        return btn
    }()
    
    //下载有进度按钮
    lazy var downProgressBtn: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect(x: 120, y: 330, width: 100, height: 30)
        btn.setTitle("下载...", for: .normal)
        btn.backgroundColor = UIColor.blue
        return btn
    }()
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        bindUI()
        //创建URL对象
        let urlString = "https://www.douban.com/j/app/radio/channels"
        let url = URL(string:urlString)!
        
        //发起请求按钮点击
        startBtn.rx.tap.asObservable()
            .flatMap {_ in
                request(.get, url).responseString()
                    .takeUntil(self.cancelBtn.rx.tap) //如果“取消按钮”点击则停止请求
            }
            .subscribe(onNext: {
                response, data in
                print("请求成功！返回的数据是：", data)
            }, onError: { error in
                print("请求失败！错误原因：", error)
            }).disposed(by: disposeBag)
//        netWorkTest1()
        
        //上传无进度条
        uploadBtn.rx.tap.asObservable()
            .subscribe(onNext:{ [weak self] in
                self?.uploadTest1()
                }).disposed(by: disposeBag)
        //上传有进度条
        uploadProgressBtn.rx.tap.asObservable()
            .subscribe(onNext:{ [weak self] in
                self?.uploadTestProgress()
            }).disposed(by: disposeBag)
        
    }

}

extension RxAlamofireViewController {
    private func bindUI() {
        self.view.addSubview(startBtn)
        self.view.addSubview(cancelBtn)
        self.view.addSubview(uploadBtn)
        self.view.addSubview(uploadProgressBtn)
        self.view.addSubview(progressView)
        self.view.addSubview(uploadMutiBtn)
        self.view.addSubview(downLoadBtn)
        self.view.addSubview(downProgressBtn)
    }
    
    private func netWorkTest1() {
        let urlString = "https://www.douban.com/j/app/radio/channels"
        let url = URL(string:urlString)!
        let request = json(.get, url)
        // 监听网络
        request.asObservable().subscribe({ (event) in
            print("event is \(event)")
            switch event {
            case let .error(error):
                print(error)
            case .next, .completed:
                break
            }
            
        }).disposed(by: disposeBag)
    }
    
    private func uploadTest1() {
        //需要上传的文件路径
        let fileURL = Bundle.main.url(forResource: "new-followers", withExtension: "jpg")
        //服务器路径
        let uploadURL = URL(string: "http://www.hangge.com/upload.php")!
        
        //将文件上传到服务器
        RxAlamofire.upload(fileURL!, urlRequest: try! urlRequest(.post, uploadURL))
            .subscribe(onError: { error in
                print(error)
            },onCompleted:{
                print("上传结束")
            }, onDisposed: {
                print("Disposed")
            })
            .disposed(by: disposeBag)
    }
    
    
    private func uploadTestProgress() {
        //需要上传的文件路径
        let fileURL = Bundle.main.url(forResource: "new-followers", withExtension: "jpg")
        //服务器路径
        let uploadURL = URL(string: "http://www.hangge.com/upload.php")!
        //将文件上传到服务器
        upload(fileURL!, urlRequest: try! urlRequest(.post, uploadURL))
            .map{request in
                //返回一个关于进度的可观察序列
                Observable<Float>.create{observer in
                    request.uploadProgress(closure: { (progress) in
                        observer.onNext(Float(progress.fractionCompleted))
                        if progress.isFinished{
                            observer.onCompleted()
                        }
                    })
                    return Disposables.create()
                }
            }
            .flatMap{$0}
            .bind(to: progressView.rx.progress) //将进度绑定UIProgressView上
            .disposed(by: disposeBag)
    }
    
    private func uploadTestMulti() {
        //需要上传的文件
        let fileURL1 = Bundle.main.url(forResource: "new-followers", withExtension: "jpg")
        let fileURL2 = Bundle.main.url(forResource: "new-followers", withExtension: "jpg")
        
        //服务器路径
        let uploadURL = URL(string: "http://www.hangge.com/upload2.php")!
        
        //将文件上传到服务器
        upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(fileURL1!, withName: "file1")
                multipartFormData.append(fileURL2!, withName: "file2")
        },
            to: uploadURL,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
        })
    }
    
    private func downLoadTest() {
        //指定下载路径和保存文件名
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("file1/myLogo.png")
            //两个参数表示如果有同名文件则会覆盖，如果路径中文件夹不存在则会自动创建
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        //需要下载的文件
        let fileURL = URL(string: "http://www.hangge.com/blog/images/logo.png")!
        
        //开始下载
        download(URLRequest(url: fileURL), to: destination)
            .subscribe(onNext: { element in
                print("开始下载。")
            }, onError: { error in
                print("下载失败! 失败原因：\(error)")
            }, onCompleted: {
                print("下载完毕!")
            })
            .disposed(by: disposeBag)
    }
    
    private func downLoadProgress1() {
        //指定下载路径和保存文件名
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("file1/myLogo.png")
            //两个参数表示如果有同名文件则会覆盖，如果路径中文件夹不存在则会自动创建
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        //需要下载的文件
        let fileURL = URL(string: "http://www.hangge.com/blog/images/logo.png")!
        
        //开始下载
        download(URLRequest(url: fileURL), to: destination)
            .subscribe(onNext: { element in
                print("开始下载。")
                element.downloadProgress(closure: { progress in
                    print("当前进度: \(progress.fractionCompleted)")
                    print("  已下载：\(progress.completedUnitCount/1024)KB")
                    print("  总大小：\(progress.totalUnitCount/1024)KB")
                })
            }, onError: { error in
                print("下载失败! 失败原因：\(error)")
            }, onCompleted: {
                print("下载完毕!")
            }).disposed(by: disposeBag)
    }
    
    private func downLoadProgress2() {
        //指定下载路径和保存文件名
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("file1/myLogo.png")
            //两个参数表示如果有同名文件则会覆盖，如果路径中文件夹不存在则会自动创建
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        //需要下载的文件
        let fileURL = URL(string: "http://www.hangge.com/blog/images/logo.png")!
        //开始下载
        download(URLRequest(url: fileURL), to: destination)
            .map{request in
                //返回一个关于进度的可观察序列
                Observable<Float>.create{observer in
                    request.downloadProgress(closure: { (progress) in
                        observer.onNext(Float(progress.fractionCompleted))
                        if progress.isFinished{
                            observer.onCompleted()
                        }
                    })
                    return Disposables.create()
                }
            }
            .flatMap{$0}
            .bind(to: progressView.rx.progress) //将进度绑定UIProgressView上
            .disposed(by: disposeBag)
    }
}
