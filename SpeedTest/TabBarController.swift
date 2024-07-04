//
//  TabBarController.swift
//  SpeedTest
//
//  Created by admin on 6/19/24.
//

import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        for item in tabBar.items! {
            item.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12, weight: .bold)], for: .normal)
        }
        tabBar.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 1)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
