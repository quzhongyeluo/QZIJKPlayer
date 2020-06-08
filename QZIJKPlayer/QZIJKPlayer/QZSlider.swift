//
//  QZSlider.swift
//  QZIJKPlayer
//
//  Created by 曲终叶落 on 2018/11/27.
//  Copyright © 2018 曲终叶落. All rights reserved.
//

import UIKit

class QZSlider: UISlider {

    override func awakeFromNib() {
        super.awakeFromNib()
        setThumbImage(QZPlayerResource.roundImage(), for: .normal)
        setThumbImage(QZPlayerResource.roundBigImage(), for: .highlighted)
    }
}
