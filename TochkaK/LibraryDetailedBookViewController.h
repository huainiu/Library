//
//  LibraryDetailedBookViewController.h
//  TochkaK
//
//  Created by Alexandra Vtyurina on 09/03/14.
//
//

#import <UIKit/UIKit.h>
#import "LibraryBook.h"

@interface LibraryDetailedBookViewController : UIViewController
@property (strong, nonatomic) LibraryBook* bookToShow;

-(void) updateUI;

@end