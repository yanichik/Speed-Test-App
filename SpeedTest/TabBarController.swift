//
//  TabBarController.swift
//  SpeedTest
//
//  Created by admin on 6/19/24.
//

import UIKit

class TabBarController: UITabBarController {
    @IBOutlet weak var customTabBar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for item in customTabBar.items! {
//            item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.black], for: .normal)
            item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : Color.custom(hexString: "393939", alpha: 1).value], for: .normal)
        }

        // Do any additional setup after loading the view.
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
