//
//  PFDetailViewController.m
//  GLKitSampler
//
//  Created by Jim Hillhouse on 2/22/12.
//  Copyright (c) 2012 CocoaCoder.org. All rights reserved.
//

#import "PFDetailViewController.h"

#import "PFGLKitSample1ViewController.h"

#import <QuartzCore/QuartzCore.h>




@interface PFDetailViewController ()


@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) NSString *overviewString;

- (void)configureView;
- (void)dimOverviewView;
- (void)undimOverviewView;
- (void)displayInfo;
- (IBAction)glViewTransition:(id)sender;

@end




@implementation PFDetailViewController



@synthesize detailItem              = _detailItem;
@synthesize overviewView            = _overviewView;
@synthesize textOverviewTextView    = _textOverviewView;
@synthesize overviewLabel           = _overviewLabel;
@synthesize masterPopoverController = _masterPopoverController;

@synthesize overviewString          = _overviewString;

@synthesize managedObject           = _managedObject;


    
    
    
#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    NSLog(@"DetailView -setDetailItem:");
    if (_detailItem != newDetailItem) 
    {
        _detailItem = newDetailItem;
        
        self.title = [self.detailItem description];
        
        // Update the view.
        
        //
        // Update for the iPad here. That's because the iPad loads in the detail, or second, view
        // at start-up whereas the iPhone does not.
        //
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) 
        {
            NSLog(@"DetailView -setDetailItem UIUserInterfaceIdiomPad");
            [self configureView];
        }
    }

    if (self.masterPopoverController != nil) 
    {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}



- (void)configureView
{
    NSLog(@"DetailView -configureView");

    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) 
    {
        [self.overviewView.layer setCornerRadius:12.0];
    }
    else 
    {
        [self.overviewView.layer setCornerRadius:8.0];
    }
    

    if ([[self.detailItem description] isEqualToString:@"Line"]) 
    {
        NSLog(@"DetailView -configureView Set: Line");
 
        self.overviewString = @"This GLKit example shows how to create a simple line using two points and GL_LINE_LOOP in the glDrawArrays call.";
        [self undimOverviewView];
    }
    else 
    {
        self.overviewView.alpha = 0.0;
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
     
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Star_Nursery"]];
    
    
    //
    // Great the the iPhone...but not so great for the iPad since it loads the view on start-up.
    // Which means, you can call methods in here until the cows come home, all to no avail on an
    // iPad app. At least, that's how my mileage varied.
    //
//    self.title = [self.detailItem description];
}



- (void)viewDidUnload
{
    NSLog(@"DetailView unloading");
    
    [self setOverviewLabel:nil];
    
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    self.overviewView = nil;
}



- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"DetailView -viewDidAppear");
    
    [super viewDidAppear:animated];
    
    
    //
    // Since the iPhone doesn't load the detail, or second, view at start-up, the view needs to be
    // configured now.
    //
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
    {
        [self configureView];
    }
}



#pragma mark - Segue Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"GLKViewSegue"]) 
    {
//        PFGLKitSample1ViewController *glkSample1ViewController = [segue destinationViewController];        
//        glkSample1ViewController = [segue destinationViewController];
        //self.detailItem = nil;
    }
}



- (void)glViewTransition:(id)sender
{
    
    if ([[self.detailItem description] isEqualToString:@"Line"]) 
    {
        [self performSegueWithIdentifier:@"GLKViewSegue" sender:sender];
    }
}



#pragma mark - Dimming and Undimming Methods

- (void)dimOverviewView
{
    [UIView animateWithDuration:0.75 animations:^{
        self.overviewView.alpha = 0.0;
    }
                     completion:^(BOOL finished){
                         NSLog(@"contentView has been dimmed");
                     }];
}



- (void)undimOverviewView
{
    [UIView animateWithDuration:0.0 animations:^{
        //
        // This was the only way I could find, and quite by accident, to update the iPad detail view
        // and do a fade-in. [self.view setNeedsDisplay] was useless. This seems to have the effect
        // of kicking the detail view in the ass to get it to update and display the updated label
        // and text view.
        //
        // Strange...
        //
    }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:0.75 animations:^{
                             self.overviewView.alpha = 1.0;
                             
                             [self displayInfo];
                         }];
                         NSLog(@"contentView has been undimmed");
                     }];
}



- (void)displayInfo
{
    self.overviewLabel.text = [[self.managedObject valueForKey:@"name"] description];
    self.textOverviewTextView.text = [[self.managedObject valueForKey:@"summary"] description];
    
    NSLog(@"DetailView -configureView self.detailItem = %@", [self.detailItem description]);
    NSLog(@"DetailView -configureView self.title = %@", self.overviewLabel.text);
    NSLog(@"DetailView -configureView self.text = %@", self.textOverviewTextView.text);
}



# pragma mark - Method for handling rotation.

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } 
    else 
    {
        return YES;
    }
}



#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}



- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}



@end
