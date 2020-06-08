//
//  ViewController.swift
//  QZIJKPlayer
//
//  Created by 曲终叶落 on 2018/11/21.
//  Copyright © 2018 曲终叶落. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var playView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setPlayer()
    }
    
    private func setPlayer() {
        let player = QZIJKPlayerViewController()
        player.view.frame = playView.bounds
        playView.addSubview(player.view)
        self.addChild(player)
        let playModel_first = QZIJKPlayerPlayModel(title: "Test_1", url: "http://vfx.mtime.cn/Video/2019/03/21/mp4/190321153853126488.mp4", name: "高清")
        let playModel_second = QZIJKPlayerPlayModel(title: "Test_2", url: "http://vfx.mtime.cn/Video/2019/03/21/mp4/190321153853126488.mp4", name: "超清")
        player.setPlayData(playModels: [playModel_first, playModel_second])
        player.delegate = self
        player.isHiddenBottomProgressView = true
    }
}

extension ViewController: QZIJKPlayerDelegate {
    func playeFinish() {
        print("已播放完")
    }
    
    func backClick() {
        navigationController?.popViewController(animated: true)
    }
}

