//
//  NavigationController.swift
//  QZIJKPlayer
//
//  Created by iOS on 2018/11/25.
//  Copyright © 2018 曲终叶落. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override var childForHomeIndicatorAutoHidden: UIViewController? {
        if self.viewControllers.last?.children.first is QZIJKPlayerViewController {
            return self.viewControllers.last?.children.first
        }
        return nil
    }

//    override var prefersHomeIndicatorAutoHidden: Bool {
//        return true
//    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
