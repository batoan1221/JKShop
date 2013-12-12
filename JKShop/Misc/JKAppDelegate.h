//
//  JKAppDelegate.h
//  JKShop
//
//  Created by admin on 11/30/13.
//  Copyright (c) 2013 Nguyễn Bá Toàn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseAppDelegate.h"

@interface JKAppDelegate : BaseAppDelegate <UIApplicationDelegate>

@property (retain, nonatomic) UIViewController *centerController;
@property (retain, nonatomic) UIViewController *leftController;

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) NSString *loggedInUserID;
@property (strong, nonatomic) FBSession *loggedInSession;

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
- (void) closeSession;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
+ (JKAppDelegate *)getRootViewController;

@end
