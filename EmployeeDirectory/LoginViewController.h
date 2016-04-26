//
//  LoginViewController.h
//  ProductCatalogue
//
//  Created by Naveen on 4/19/16.
//  Copyright © 2016 NIIT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController< UITextFieldDelegate>
{
    IBOutlet UITextField *userNameField;
    IBOutlet UITextField *pwdField;
    
}

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
-(bool)isLoginSuccessful:(UITextField*)UserName password:(UITextField*)password;

@end
