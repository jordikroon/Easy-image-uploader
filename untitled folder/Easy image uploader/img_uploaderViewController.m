//
//  img_uploaderViewController.m
//  simple image uploader
//
//  Created by Jordi Kroon on 8/30/12.
//  Copyright (c) 2012 Jordi Kroon. All rights reserved.
//
// TODO:
// more localizations
//
//
//
// Changelog:
//
// 19 sept. 2012
// improved upload speed
// fixed iAD
// support up side down orientation

// fixed deprecated warning iOS 6


#import "img_uploaderViewController.h"
#import "Reachability.h"
#import "MBProgressHUD.h"



@interface img_uploaderViewController ()

@end

@implementation img_uploaderViewController
@synthesize uploadImage;
@synthesize UploadButton;
@synthesize ImageView;
@synthesize bannerIsVisible;
@synthesize popover;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UploadButton.enabled = YES;
    // check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    hostReachable = [Reachability reachabilityWithHostName: @"www.google.nl"];
    [hostReachable startNotifier];
    
    adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    CGRect adFrame = adView.frame;
    adFrame.origin.y = self.view.frame.size.height;
    adView.frame = adFrame;
    
    [adView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    [self.view addSubview:adView];
    adView.delegate=self;
    self.bannerIsVisible=NO;
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if (!self.bannerIsVisible)
    {

        
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        // banner is invisible now and moved out of the screen on 50 px
        CGRect adFrame = adView.frame;
        adFrame.origin.y = self.view.frame.size.height-adView.frame.size.height;
        adView.frame = adFrame;
        
        [UIView commitAnimations];
        self.bannerIsVisible = YES;
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)  name:UIDeviceOrientationDidChangeNotification  object:nil];
}

- (void)orientationChanged:(NSNotification *)notification{
    NSLog(@"test");
    if (!self.bannerIsVisible) {
        if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown)
        {
            NSLog(@"test2");
            CGRect adFrame = adView.frame;
            adFrame.origin.y = self.view.frame.size.height;
            adView.frame = adFrame;
        } else {
            NSLog(@"test3");
            CGRect adFrame = adView.frame;
            adFrame.origin.y = self.view.frame.size.width;
            adView.frame = adFrame;
        }
        
    } else {
        if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight)
        {
            NSLog(@"test2");
            CGRect adFrame = adView.frame;
            adFrame.origin.y = self.view.frame.size.width-adView.frame.size.height;
            adView.frame = adFrame;
        } else {
            NSLog(@"test3");
            CGRect adFrame = adView.frame;
            adFrame.origin.y = self.view.frame.size.width-adView.frame.size.width;
            adView.frame = adFrame;
        }
        
    }
}
- (void)DidRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [adView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    CGRect adFrame = adView.frame;
    adFrame.origin.y = self.view.frame.size.height-adView.frame.size.height;
    adView.frame = adFrame;
    [self.view addSubview:adView];
    [self.view bringSubviewToFront:adView];
    self.bannerIsVisible=NO;
    
}- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (self.bannerIsVisible)
    {
        
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
        // banner is visible and we move it out of the screen, due to connection issue
        
        CGRect adFrame = adView.frame;
        adFrame.origin.y = self.view.frame.size.height+adView.frame.size.height;
        adView.frame = adFrame;
        
        [UIView commitAnimations];
        self.bannerIsVisible = NO;
    }
}


- (void)viewDidUnload
{
    [self setUploadImage:nil];
    [self setImageView:nil];
    [self setUploadButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}


- (IBAction)tapUpload:(id)sender {
    
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Uploadmethod", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
        destructiveButtonTitle:nil
        otherButtonTitles:NSLocalizedString(@"Camera", @""),
                          NSLocalizedString(@"Photolib", @""), nil];
	popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [popupQuery addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
    }
    [popupQuery showFromBarButtonItem:uploadImage animated:YES];
    

}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
        

if (buttonIndex == 1) {
        // choose picture
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            popover = [[UIPopoverController alloc] initWithContentViewController:picker];

            [popover presentPopoverFromBarButtonItem:uploadImage permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

            
        } else {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:picker animated:YES completion:nil];
        }
    }
    
    if(buttonIndex == 0) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];

    }

}
- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker  {
     if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
         [popover dismissPopoverAnimated:YES];

     } else {
         [picker dismissViewControllerAnimated:YES completion:nil];
     }
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    [popover dismissPopoverAnimated:YES];
    
    UIImage* originalImage = nil;
    originalImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if(originalImage==nil)
    {
        NSLog(@"image picker original");
        originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    } else {
        
        NSLog(@"image picker editedImage");
    }
    if(originalImage==nil)
    {
        NSLog(@"image picker croprect");
        originalImage = [info objectForKey:UIImagePickerControllerCropRect];
    }
    
    ImageView.image = originalImage;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    hud.mode = MBProgressHUDAnimationZoom;
    hud.labelText = NSLocalizedString(@"Uploading", @"");;
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        
        NSData *imageData = UIImageJPEGRepresentation(originalImage, 0.6);
        NSString *urlString = @"http://imgios.com/upload.php";
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        
        
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"image.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSData dataWithData:imageData]];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];	[request setHTTPBody:body];
        
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@",returnString);
        
        hud.labelText = NSLocalizedString(@"Succeed", @"");
        
        wait(1);
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
 
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sharelink", @"") message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss", @"") otherButtonTitles:nil];
        
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.transform = CGAffineTransformTranslate( alert.transform, 0.0, -100.0 );
        UITextField * alertTextField = [alert textFieldAtIndex:0];
        alertTextField.text = returnString;
        alertTextField.enabled = NO;
        [alert show];
        alert.tag = 1;

        [UIPasteboard generalPasteboard].string = alertTextField.text;
        NSLog(@"URL pasted to clipboard");
    });


}


- (IBAction)uploadImage:(id)sender {

 
}

-(void) checkNetworkStatus:(NSNotification *)notice
{
    
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];

    if(internetStatus == NotReachable || hostStatus == NotReachable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Nocontitle", @"")
                                                    message:NSLocalizedString(@"Nocontxt", @"A valid internet connection is required to communicate with the servers. Please turn on WIFI or 3G!")
                                                    delegate:nil
                                                    cancelButtonTitle:nil
                                                    otherButtonTitles:nil];
        [alert show];
                              

    }
}


@end
