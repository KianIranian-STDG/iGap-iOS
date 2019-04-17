//
//  SMIntroViewController.swift
//  PayGear
//
//  Created by Amir Soltani on 4/8/18.
//  Copyright © 2018 Samsson. All rights reserved.
//

import UIKit

class SMIntroViewController: UIPageViewController,UIPageViewControllerDelegate,UIPageViewControllerDataSource {
 
 
    var mainButton:SMBottomButton?
    var pageControl:UIPageControl?
    var slides:[UIViewController] = []
    var leftButton:UIButton?
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 1...2{
            let vc = SMNavigationController.shared.findViewController(page: .IntroContentPage) as! SMIntroContentViewController
	
            if i == 1{
                vc.img = UIImage(named:"onboarding1")!
                vc.main = "onboarding1Title".localized
                vc.sub = "onboarding1Description".localized
                
            }else if i == 2{
                vc.img = UIImage(named:"onboarding2")!
                vc.main = "onboarding2Title".localized
                vc.sub = "onboarding2Description".localized
               
            }
            
            slides.append(vc)
        }
        
        
        self.dataSource = self
        self.delegate = self
        self.setViewControllers([self.slides[0]], direction: .reverse, animated: true, completion: nil)
        self.view.backgroundColor = UIColor.white
        
        self.addOverlayViews()

    }
    
    func addOverlayViews(){
        
        
        self.mainButton = SMBottomButton()
        self.mainButton!.translatesAutoresizingMaskIntoConstraints = false
        self.mainButton!.backgroundColor = UIColor(netHex: 0x1fa8f2)
        self.mainButton!.setTitle("next".localized, for: .normal)
        self.mainButton!.layer.cornerRadius = 28
        self.mainButton!.addTarget(self, action: #selector(self.goLastTapped(_:)),for: .touchUpInside)
        self.mainButton?.isEnabled = true
        self.mainButton?.colors = [UIColor(netHex: 0x1c90d4), UIColor(netHex: 0x1fa8f2)]
        self.view.addSubview(self.mainButton!)
        
        
        self.pageControl = UIPageControl()
        self.pageControl!.translatesAutoresizingMaskIntoConstraints = false
        self.pageControl!.numberOfPages = 2
        self.pageControl!.currentPage = 1
        self.pageControl?.currentPageIndicatorTintColor = UIColor(netHex: 0x00e676)
        self.pageControl?.pageIndicatorTintColor = UIColor(netHex: 0xd8d8d8)
        
        
        self.view.addSubview(self.pageControl!)
        
        
        self.leftButton = UIButton(frame: CGRect.init(x: 0, y: 0, width: 60, height: 15))
        self.leftButton!.translatesAutoresizingMaskIntoConstraints = false
        self.leftButton!.backgroundColor = UIColor.clear
        self.leftButton!.setTitle("already.read".localized, for: .normal)
        self.leftButton!.setTitleColor(UIColor(netHex: 0x66ba41), for: .normal)
        self.leftButton!.titleLabel?.font = SMFonts.IranYekanBold(15)
        self.leftButton?.contentMode = .left
        self.leftButton?.contentHorizontalAlignment = .left
        self.leftButton!.addTarget(self, action: #selector(self.skipIntroTapped(_:)),for: .touchUpInside)
        
        self.view.addSubview(self.leftButton!)
        
        self.mainButton!.addConstraint(NSLayoutConstraint(item: self.mainButton!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 56))
        self.view.addConstraint(NSLayoutConstraint(item: self.mainButton!, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 16))
        self.view.addConstraint(NSLayoutConstraint(item: self.mainButton!, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: -16))
        self.view.addConstraint(NSLayoutConstraint(item: self.mainButton!, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -30))

        
        
        self.view.addConstraint(NSLayoutConstraint(item: self.pageControl!, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.pageControl!, attribute: .bottom, relatedBy: .equal, toItem: self.mainButton, attribute: .top, multiplier: 1.0, constant: 5))
     
        self.leftButton!.addConstraint(NSLayoutConstraint(item: self.leftButton!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 90))
        self.leftButton!.addConstraint(NSLayoutConstraint(item: self.leftButton!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 170))
        
        self.view.addConstraint(NSLayoutConstraint(item: self.leftButton!, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 22))
        self.view.addConstraint(NSLayoutConstraint(item: self.leftButton!, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 25))

       
       
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updatePageControl()
    }
    
    
    func updatePageControl() {
        for (index, dot) in (pageControl?.subviews.enumerated())! {
            dot.layer.frame = CGRect.init(x: dot.frame.origin.x, y:dot.frame.origin.y , width: 12.0, height: 12.0)
            dot.layer.cornerRadius = dot.frame.size.height / 2
        }
    }
    
    @objc func skipIntroTapped(_ sender: SMBottomButton) {
        
        SMUserManager.profileLevelsCompleted = SMUserManager.CurrentStep.Signup.rawValue
        SMNavigationController.shared.style = .SMSignupStyle
        SMNavigationController.shared.setRootViewController(page: .SignupPhonePage)
		
    }
    
    
    @objc func goLastTapped(_ sender: SMBottomButton) {
        
        if pendingViewControllerIndex == 1 {
            SMUserManager.profileLevelsCompleted = SMUserManager.CurrentStep.Signup.rawValue
            SMUserManager.saveDataToKeyChain()
            SMNavigationController.shared.style = .SMSignupStyle
            SMNavigationController.shared.setRootViewController(page: .SignupPhonePage)
        }
        else{
        
            self.setViewControllers([slides[slides.count-1]], direction: .reverse, animated: true, completion : nil)
            self.pageControl!.currentPage = 0
            leftButton?.isHidden = true
            mainButton?.setTitle("enter".localized, for: .normal)
            mainButton?.enable()
            mainButton?.colors = [UIColor(netHex: 0x1c90d4), UIColor(netHex: 0x1fa8f2)]
            pendingViewControllerIndex = 1
            updatePageControl()
        
        }
        
    }
    
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?{
        let index = self.slides.index(of: viewController)!

        if index < self.slides.count - 1 {
            
            return slides[index + 1]
        }
        return nil

    }


    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?{
        
        let index = self.slides.index(of: viewController)!

        if index > 0  {

            return slides[index - 1 ]
        }

        return nil
    }
    
    var pendingViewControllerIndex = -1
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]){
    
        pendingViewControllerIndex = self.slides.index(of: pendingViewControllers[0])!
    
    }
    
    
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool){
      
        if pendingViewControllerIndex == 1 {
            leftButton?.isHidden = true
            mainButton?.setTitle("enter".localized, for: .normal)
        }
        else{
            leftButton?.isHidden = false
            mainButton?.setTitle("next".localized, for: .normal)
            

        }
        self.pageControl!.currentPage = (slides.count-1) - pendingViewControllerIndex
            updatePageControl()
        
       
    }
}










