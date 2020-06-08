//
//  QZPlayerResource.swift
//  QZIJKPlayer
//
//  Created by 曲终叶落 on 2018/11/27.
//  Copyright © 2018 曲终叶落. All rights reserved.
//

import Foundation
import UIKit

class QZPlayerResource {
    static func backImage() -> UIImage {
        return getImage(name: "QZBack")
    }
    
    static func exitFullScreenImage() -> UIImage {
        return getImage(name: "QZExitFullScreen")
    }
    
    static func fullScreenImage() -> UIImage {
        return getImage(name: "QZFullScreen")
    }
    
    static func pauseImage() -> UIImage {
        return getImage(name: "QZPause")
    }
    
    static func playImage() -> UIImage {
        return getImage(name: "QZPlay")
    }
    
    static func roundImage() -> UIImage {
        return getImage(name: "QZRound")
    }
    
    static func roundBigImage() -> UIImage {
        return getImage(name: "QZRound_big")
    }
    
    static private func getImage(name: String) -> UIImage {
        let bundle = Bundle.main.path(forResource: "QZPlayerResource", ofType: "bundle")
        var path = bundle! + "/" + name
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            path = path + "@3x.png"
        }else{
            if UIScreen.main.scale == 2 {
                path = path + "@2x.png"
            }else{
                path = path + "@3x.png"
            }
        }
        return UIImage(contentsOfFile: path)!
    }
}
