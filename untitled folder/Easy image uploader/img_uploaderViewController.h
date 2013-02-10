//
//  img_uploaderViewController.h
//  simple image uploader
//
//  Created by Jordi Kroon on 8/30/12.
//  Copyright (c) 2012 Jordi Kroon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAD.h>
#import <SystemConfiguration/SystemConfiguration.h>


@class Reachability;

Reachability* internetReachable;
Reachability* hostReachable;

@interface img_uploaderViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,ADBannerViewDelegate ,
UIAlertViewDelegate > {
    
    ADBannerView *adView;
    BOOL bannerIsVisible;
}

@property (retain, nonatomic) IBOutlet UIBarButtonItem *uploadImage;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *UploadButton;
@property (nonatomic,assign) BOOL bannerIsVisible;
@property (retain, nonatomic) IBOutlet UIImageView *ImageView;

@property (strong, nonatomic) UIPopoverController *popover;

-(void) checkNetworkStatus:(NSNotification *)notice;
- (IBAction)tapUpload:(id)sender;
- (IBAction)uploadImage:(id)sender;


@end

