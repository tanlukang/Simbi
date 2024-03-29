//
//  SMBHomeViewController.swift
//  Simbi
//
//  Created by flynn on 10/8/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

import UIKit


protocol SMBHomeViewDelegate {
    
    func homeView(homeView: SMBHomeViewController, didSelectUserFromFriendsList user:SMBUser)
}


enum SMBHomeViewAlertType: Int {
    case ProfilePicture, CheckIn
}


class SMBHomeViewController: UIViewController {
    
    weak var parent: SMBMainViewController?
    var delegate: SMBHomeViewDelegate?
    
    let homeBackgroundView  = SMBHomeBackgroundView()
    let userInfoView        = UIView()
    
    let profilePictureView  = SMBImageView()
    let nameLabel           = UILabel()
    let locationLabel       = UILabel()
    
    let scrollFadeView      = UIView()
    
    var activityDrawerView: SMBActivityDrawerView?
    
    
    // MARK: - ViewController Lifecycle
    
    convenience init() { self.init(nibName: nil, bundle: nil) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.simbiBlueColor()
        self.view.clipsToBounds = true
        
        
        // Set up views.
        
        homeBackgroundView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        homeBackgroundView.userInteractionEnabled = false
        self.view.addSubview(homeBackgroundView)
        
        
        userInfoView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.width-88)
        userInfoView.center = self.view.center
        userInfoView.autoresizingMask = .FlexibleTopMargin
        
        
        profilePictureView.frame = CGRectMake(66, 0, self.view.frame.width-132, self.view.frame.width-132)
        profilePictureView.backgroundColor = UIColor.simbiBlackColor()
        profilePictureView.userInteractionEnabled = false
        profilePictureView.layer.cornerRadius = profilePictureView.frame.width/2
        profilePictureView.layer.masksToBounds = true
        profilePictureView.layer.borderWidth = 1
        profilePictureView.layer.borderColor = UIColor.simbiWhiteColor().CGColor
        profilePictureView.layer.shadowColor = UIColor.blackColor().CGColor
        profilePictureView.layer.shadowRadius = 2
        profilePictureView.layer.shadowOpacity = 0.5
        userInfoView.addSubview(profilePictureView)
        
        let profilePictureButton = UIButton(frame: CGRectInset(profilePictureView.frame, 20, 20))
        profilePictureButton.layer.cornerRadius = profilePictureButton.frame.width/2
        profilePictureButton.addTarget(self, action: "pinLocationAction:", forControlEvents: .TouchUpInside)
        userInfoView.addSubview(profilePictureButton)
        
        let profilePictureRingView = UIView(frame: CGRectMake(0, 0, self.view.frame.width-110, self.view.frame.width-110))
        profilePictureRingView.center = profilePictureView.center
        profilePictureRingView.backgroundColor = UIColor(white: 1, alpha: 0.33)
        profilePictureRingView.layer.cornerRadius = profilePictureRingView.frame.width/2
        profilePictureRingView.userInteractionEnabled = false
        userInfoView.insertSubview(profilePictureRingView, belowSubview: profilePictureView)
        
        
        nameLabel.frame = CGRectMake(0, profilePictureView.frame.height+8, self.view.frame.width, 44)
        nameLabel.textColor = UIColor.whiteColor()
        nameLabel.font = UIFont.simbiFontWithAttributes(kFontLight, size: 32)
        nameLabel.textAlignment = .Center
        nameLabel.layer.shadowColor = UIColor.blackColor().CGColor
        nameLabel.layer.shadowOpacity = 0.25
        nameLabel.layer.shadowRadius = 1
        nameLabel.layer.shadowOffset = CGSizeMake(1, 1)
        nameLabel.userInteractionEnabled = false
        userInfoView.addSubview(nameLabel)
        
        locationLabel.frame = CGRectMake(0, nameLabel.frame.origin.y+28, self.view.frame.width, 44)
        locationLabel.textColor = UIColor.whiteColor()
        locationLabel.font = UIFont.simbiFontWithAttributes(kFontMedium, size: 16)
        locationLabel.textAlignment = .Center
        locationLabel.layer.shadowColor = UIColor.blackColor().CGColor
        locationLabel.layer.shadowOpacity = 0.25
        locationLabel.layer.shadowRadius = 1
        locationLabel.layer.shadowOffset = CGSizeMake(1, 1)
        locationLabel.userInteractionEnabled = false
        userInfoView.addSubview(locationLabel)
        
        self.view.addSubview(userInfoView)
        
        
        activityDrawerView = SMBActivityDrawerView(frame: CGRectMake(0, self.view.frame.height-44, self.view.frame.width, self.view.frame.height-self.view.frame.width), delegate: self)
        self.view.addSubview(activityDrawerView!)
        
        
        // Overlaid view that fades to black as the user swipes to the side.
        scrollFadeView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        scrollFadeView.backgroundColor = UIColor.blackColor()
        scrollFadeView.alpha = 0
        scrollFadeView.userInteractionEnabled = false
        self.view.insertSubview(scrollFadeView, belowSubview: activityDrawerView!)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        activityDrawerView!.frame = CGRectMake(
            0,
            self.view.frame.height-44,
            self.view.frame.width,
            self.view.frame.height-self.view.frame.width
        )
        
        if SMBUser.exists() {
            homeBackgroundView.updateFilteredProfilePicture()
            profilePictureView.setParseImage(SMBUser.currentUser().profilePicture, withType: kImageTypeMediumSquare)
            nameLabel.text = SMBUser.currentUser().name
            locationLabel.text = SMBUser.currentUser().cityAndState()
        }
        else {
            profilePictureView.image = nil
        }
    }
    
    
    // MARK: - User Actions
    
    func pinLocationAction(sender: AnyObject) {
        
        parent!.view.userInteractionEnabled = false
        
        let coverView = UIView(frame: CGRectMake(0, 0, profilePictureView.frame.width, profilePictureView.frame.height))
        coverView.backgroundColor = UIColor.simbiLightGrayColor()
        coverView.layer.cornerRadius = coverView.frame.width/2
        coverView.alpha = 0
        profilePictureView.addSubview(coverView)
        
        UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            
            self.profilePictureView.transform = CGAffineTransformMakeScale(-1, 1);
            coverView.alpha = 1
            
            }) { (Bool) -> Void in
                
                self.parent!.viewWillDisappear(true)
                
                let topLevelCoverView = UIView(frame: CGRectMake(0, 0, coverView.frame.width, coverView.frame.height))
                topLevelCoverView.center = coverView.superview!.convertPoint(coverView.center, toView: nil)
                topLevelCoverView.backgroundColor = UIColor.simbiLightGrayColor()
                topLevelCoverView.layer.cornerRadius = coverView.frame.width/2
                self.parent!.view.addSubview(topLevelCoverView)
                
                coverView.removeFromSuperview()
                
                let navigationController = UINavigationController(rootViewController: SMBPinLocationViewController())
                navigationController.view.backgroundColor = navigationController.visibleViewController.view.backgroundColor
                navigationController.setNavigationBarHidden(true, animated: false)
                
                self.parent!.navigationController!.presentViewControllerByGrowingView(navigationController, growingView: topLevelCoverView)
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 666_666_666), dispatch_get_main_queue(), { () -> Void in
                    
                    navigationController.setNavigationBarHidden(false, animated: true)
                    topLevelCoverView.removeFromSuperview()
                    self.profilePictureView.transform = CGAffineTransformMakeScale(1, 1)
                    
                    self.parent!.view.userInteractionEnabled = true
                })
        }
    }
    
    
    func swipeControlDidBeginTouch(sender: AnyObject) {
        parent!.scrollView.scrollEnabled = false
    }
    
    
    func swipeControlDidEndTouch(sender: AnyObject) {
        parent!.scrollView.scrollEnabled = true
    }
}


// MARK: - SMBActivitiyDrawerDelegate

extension SMBHomeViewController: SMBActivityDrawerDelegate {
    
    func activityDrawerDidSelectUser(user: SMBUser!) {
        
        if let delegate = self.delegate {
            self.view.endEditing(true)
            delegate.homeView(self, didSelectUserFromFriendsList: user)
        }
    }
    
    
    func toggleActivityDrawer() {
        
        self.view.endEditing(true)
        
        let width = self.view.frame.width
        let height = self.view.frame.height
        let activityHeight = activityDrawerView!.frame.height
        
        if activityDrawerView!.frame.origin.y < height-44 {
            
            UIView.animateWithDuration(0.33, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                
                self.activityDrawerView!.frame = CGRectMake(0, height-44, width, activityHeight)
                //                self.homeBackgroundView.frame = CGRectMake(0, 0, width, height)
                self.userInfoView.center = CGPointMake(width/2, height/2)
                
                }, completion: nil)
        }
        else {
            
            UIView.animateWithDuration(0.33, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                
                self.activityDrawerView!.frame = CGRectMake(0, height-activityHeight, width, activityHeight)
                //                self.homeBackgroundView.frame = CGRectMake(0, 0, width, height-activityHeight+44)
                self.userInfoView.center = CGPointMake(width/2, (height-activityHeight+44)/2)
                
                }, completion: nil)
        }
    }
}


// MARK: - SMBSplitViewChild

extension SMBHomeViewController: SMBSplitViewChild {
    
    func splitViewDidScroll(splitView: SMBSplitViewController, position: CGFloat) {
        
        homeBackgroundView.frame = CGRectMake(position/2, 0, homeBackgroundView.frame.width, homeBackgroundView.frame.height)
        scrollFadeView.alpha = abs(position)/(3*self.view.frame.width)
    }
}
