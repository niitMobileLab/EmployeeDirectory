//
//  LoginViewController.m
//  ProductCatalogue
//
//  Created by Naveen on 4/19/16.
//  Copyright © 2016 NIIT. All rights reserved.
//

#import "LoginViewController.h"
#import "MasterViewController.h"
#import "Employee.h"
#import <Parse/Parse.h>
#import "Utility.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    userNameField.text = @"";
    pwdField.text = @"";
    [userNameField becomeFirstResponder];

    [self.navigationController setNavigationBarHidden:YES];
}


- (void) addEmployee:(NSNumber *) id firstName:(NSString *)firstName
lastName:(NSString *)lastName
title:(NSString *)title
managerId:(NSNumber *)managerId
officePhone:(NSString *)officePhone
cellPhone:(NSString *)cellPhone
email:(NSString *)email
picture:(NSString *)picture
{
    Employee *employee = [NSEntityDescription insertNewObjectForEntityForName:@"Employee" inManagedObjectContext:self.managedObjectContext];
    
    employee.id = id;
    employee.firstName = firstName;
    employee.lastName = lastName;
    employee.title = title;
    employee.managerId = managerId;
    employee.officePhone = officePhone;
    employee.cellPhone = cellPhone;
    employee.email = email;
    employee.picture = picture;
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    
}


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"EmployeeDirectory" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"EmployeeDirectory.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

-(IBAction)signInPressed:(id)sender
{
    Utility *util = [Utility sharedManager];
    
    //Validate the UserName and Password field
    if(([userNameField.text length] > 0) && ([pwdField.text length] > 0))
    {
        [util showLoadingScreen];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Username =%@", userNameField.text];
        
        PFQuery *query = [PFQuery queryWithClassName:@"Users" predicate:predicate];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (!error) {
                // The find succeeded.
                NSString *s = nil;
                if([objects count] >=1)
                {
                    PFObject *obj=[objects objectAtIndex:0];
                    s =(NSString*)[obj objectForKey:@"Password"];
                }
                if([s isEqualToString:pwdField.text])
                {
                    [util removeLoadingScreen];
                    [self performSegueWithIdentifier:@"Employees" sender:self];
                }
                else{
                    [util removeLoadingScreen];

                    [self showAlert:@"Enter Valid Credential"];
                }

            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
                [util removeLoadingScreen];

                [self showAlert:@"Enter Valid Credential"];

            }
        }];
    }
    else{
        [self showAlert:nil];
    }
}

-(void)showAlert:(NSString*)msg
{
    NSString *message = msg ? msg : @"Enter User Credentials";
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@""
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
    userNameField.text = @"";
    pwdField.text = @"";
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [userNameField resignFirstResponder];
    [pwdField resignFirstResponder];
}

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    MasterViewController *controller = (MasterViewController *)segue.destinationViewController;
    controller.managedObjectContext = self.managedObjectContext;
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        NSLog(@"This is the first launch");
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // Adding sample data
        [self addEmployee:@1 firstName:@"James" lastName:@"King" title:@"CEO" managerId:@0 officePhone:@"617-219-2001" cellPhone:@"781-219-9991" email:@"jking@fakemail.com" picture:@"james_king.jpg" ];
        [self addEmployee:@2 firstName:@"Julie" lastName:@"Taylor" title:@"VP of Marketing" managerId:@1 officePhone:@"617-219-2001" cellPhone:@"781-219-9992" email:@"julie@fakemail.com" picture:@"julie_taylor.jpg" ];
        [self addEmployee:@3 firstName:@"Eugene" lastName:@"Lee" title:@"CFO" managerId:@1 officePhone:@"617-219-2003" cellPhone:@"781-219-9993" email:@"eugene@fakemail.com" picture:@"eugene_lee.jpg" ];
        [self addEmployee:@4 firstName:@"John" lastName:@"Williams" title:@"VP of Engineering" managerId:@1 officePhone:@"617-219-2004" cellPhone:@"781-219-9994" email:@"john@fakemail.com" picture:@"john_williams.jpg" ];
        [self addEmployee:@5 firstName:@"Ray" lastName:@"Moore" title:@"VP of Sales" managerId:@1 officePhone:@"617-219-2005" cellPhone:@"781-219-9995" email:@"ray@fakemail.com" picture:@"ray_moore.jpg" ];
        [self addEmployee:@6 firstName:@"Paul" lastName:@"Jones" title:@"QA Manager" managerId:@4 officePhone:@"617-219-2006" cellPhone:@"781-219-9996" email:@"paul@fakemail.com" picture:@"paul_jones.jpg" ];
        [self addEmployee:@7 firstName:@"Paula" lastName:@"Gates" title:@"Software Architect" managerId:@4 officePhone:@"617-219-2007" cellPhone:@"781-219-9997" email:@"paula@fakemail.com" picture:@"paula_gates.jpg" ];
        [self addEmployee:@8 firstName:@"Lisa" lastName:@"Wong" title:@"Marketing Manager" managerId:@2 officePhone:@"617-219-2008" cellPhone:@"781-219-9998" email:@"lisa@fakemail.com" picture:@"lisa_wong.jpg" ];
        [self addEmployee:@9 firstName:@"Gary" lastName:@"Donovan" title:@"Marketing Manager" managerId:@2 officePhone:@"617-219-2009" cellPhone:@"781-219-9999" email:@"gary@fakemail.com" picture:@"gary_donovan.jpg" ];
        [self addEmployee:@10 firstName:@"Kathleen" lastName:@"Byrne" title:@"Sales Representative" managerId:@5 officePhone:@"617-219-2010" cellPhone:@"781-219-9910" email:@"kathleen@fakemail.com" picture:@"kathleen_byrne.jpg" ];
        [self addEmployee:@11 firstName:@"Amy" lastName:@"Jones" title:@"Sales Representative" managerId:@5 officePhone:@"617-219-2011" cellPhone:@"781-219-9911" email:@"amy@fakemail.com" picture:@"amy_jones.jpg" ];
        [self addEmployee:@12 firstName:@"Steven" lastName:@"Wells" title:@"Software Architect" managerId:@4 officePhone:@"617-219-2012" cellPhone:@"781-219-9912" email:@"steven@fakemail.com" picture:@"steven_wells.jpg" ];
    }
}


@end
