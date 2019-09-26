//
//  IGProfilePageViewController.swift
//  iGap
//
//  Created by MacBook Pro on 7/3/1398 AP.
//  Copyright © 1398 AP Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit

class IGProfileSharedMediaPageViewController: UIPageViewController,UIPageViewControllerDelegate,UIPageViewControllerDataSource {

    

    lazy var subSharedMediaViewControllers = {
        return [
            UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "IGChannelAndGroupSharedMediaAudioAndLinkTableViewController") as! IGChannelAndGroupSharedMediaAudioAndLinkTableViewController ,
            UIStoryboard(name: "Main",bundle: nil).instantiateViewController(withIdentifier: "IGChannelAndGroupSharedMediaImagesAndVideosCollectionViewController") as! IGChannelAndGroupSharedMediaImagesAndVideosCollectionViewController

        ]
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        setViewControllers([subSharedMediaViewControllers[0]], direction: .forward, animated: true, completion: nil)
        // Do any additional setup after loading the view.
    }
    required init?(coder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return subSharedMediaViewControllers.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex : Int = subSharedMediaViewControllers.index(of:viewController) ?? 0
        if currentIndex <= 0 {
            return nil
        }
        return subSharedMediaViewControllers[currentIndex-1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex : Int = subSharedMediaViewControllers.index(of:viewController) ?? 0
        if currentIndex <= (subSharedMediaViewControllers.count -1) {
            return nil
        }
        return subSharedMediaViewControllers[currentIndex+1]

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
