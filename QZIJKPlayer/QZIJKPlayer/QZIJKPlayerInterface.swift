//
//  QZIJKPlayerInterface.swift
//  QZIJKPlayer
//
//  Created by iOS on 2018/11/26.
//  Copyright © 2018 曲终叶落. All rights reserved.
//

import Foundation

protocol QZIJKPlayerInterface: class {
    func fullScreen(bool: Bool)
    func updatePlayerUI()
    func playBackStateDidChange()
    func fullScreen()
    func originalScreen()
    func preparedToPlay()
    func play(playModel: QZIJKPlayerPlayModel)
    func updateUI()
    func updateUIIfOnlyData()
    func isHiddenToolBar(isHidden: Bool)
}
