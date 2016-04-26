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

-(bool)isLoginSuccessful:(UITextField*)UserName password:(UITextField*)password
{
    __block bool isLoginSuccessful = NO;
    Utility *util = [Utility sharedManager];
    
    //Validate the UserName and Password field
    if(([UserName.text length] > 0) && ([password.text length] > 0))
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
                    PFObject *obj=[objects objectAtIndex:0];
                    PFFile *file1 = [obj objectForKey:@"EmployeesJson"];
                    
                    [file1 saveInBackground];
                    
                    NSData *data = [file1 getData];
                    NSDictionary *jsonObject=[NSJSONSerialization
                                              JSONObjectWithData:data
                                              options:NSJSONReadingMutableLeaves
                                              error:nil];
                    [self setUpData:jsonObject];
                    isLoginSuccessful = YES;
                    [self performSegueWithIdentifier:@"Employees" sender:self];
                }
                else{
                    [util removeLoadingScreen];
                    isLoginSuccessful = NO;
                    [self showAlert:@"Enter Valid Credential"];
                }
                
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
                [util removeLoadingScreen];
                isLoginSuccessful = NO;
                [self showAlert:@"Enter Valid Credential"];
                
            }
        }];
    }
    else{
        [self showAlert:nil];
    }
    
    return isLoginSuccessful;
    

    
}

-(IBAction)signInPressed:(id)sender
{
    [self isLoginSuccessful:userNameField password:pwdField];
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

-(void)setUpData:(NSDictionary *)employeeData
{
    NSDictionary * employeeDict = [employeeData objectForKey:@"employees"];

    for (NSDictionary *emp in employeeDict )
    {
        Employee *employee = [NSEntityDescription insertNewObjectForEntityForName:@"Employee" inManagedObjectContext:self.managedObjectContext];
        
        employee.id = [NSNumber numberWithInt:[[emp valueForKey:@"id"] intValue]];
        employee.firstName = emp[@"firstName"];
        employee.lastName = emp[@"lastName"];
        employee.title = emp[@"title"];
        employee.managerId = [NSNumber numberWithInt:[[emp valueForKey:@"managerId"] intValue]];
        employee.officePhone = emp[@"officePhone"];
        employee.cellPhone = emp[@"cellPhone"];
        employee.email = emp[@"email"];
        employee.picture = emp[@"picture"];
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Error: %@", [error localizedDescription]);
        }
    
    }
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    MasterViewController *controller = (MasterViewController *)segue.destinationViewController;
    controller.managedObjectContext = self.managedObjectContext;
    
}


@end
