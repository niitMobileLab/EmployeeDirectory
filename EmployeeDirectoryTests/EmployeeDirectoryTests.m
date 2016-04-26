//
//  EmployeeDirectoryTests.m
//  EmployeeDirectoryTests
//
//  Created by Christophe Coenraets on 11/18/13.
//  Copyright (c) 2013 Christophe Coenraets. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "AppDelegate.h"
#import "Employee.h"
#import "LoginViewController.h"
#import <Parse/Parse.h>


@interface EmployeeDirectoryTests : XCTestCase
@property (nonatomic, strong) NSArray *employees;
@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property(nonatomic,strong) NSArray *reports;
@end

@implementation EmployeeDirectoryTests

MasterViewController *viewControllerUnderTest;
DetailViewController *detailViewController;
LoginViewController *loginViewController;



- (void)setUp
{
    [super setUp];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    viewControllerUnderTest = [storyboard instantiateViewControllerWithIdentifier:@"masterView"];
    loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"loginVC"];
    detailViewController = [storyboard instantiateViewControllerWithIdentifier:@"EmployeeVC"];
    self.managedObjectContext = loginViewController.managedObjectContext;

}

-(void)testLoginDetails
{
    NSString *userName = @"admin";
    NSString *pwd = @"nit@12345";
    
    __block BOOL isLoginSuccessful = NO;
    __block BOOL waitingForBlock = YES;
    //Validate the UserName and Password field
    if(([userName length] > 0) && ([pwd length] > 0))
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"Username =%@", userName];
        
        
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
                if([s isEqualToString:pwd])
                {
                    waitingForBlock = NO;
                    isLoginSuccessful = YES;
                }
                else{
                    waitingForBlock = NO;
                    isLoginSuccessful = NO;
                   
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
                waitingForBlock = NO;
                isLoginSuccessful = NO;
            }
        }];
        
        while(waitingForBlock) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                     beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
        
        
    }
    
    XCTAssertTrue(isLoginSuccessful,@"Login fails");
   
}



- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testViewControllerIsComposedOfTableView {
    
    NSArray *subViews = viewControllerUnderTest.view.subviews;
    
    XCTAssertTrue([subViews containsObject:viewControllerUnderTest.tableView], @"ViewController under test is not composed of a UITableView");
}

- (void)testViewControllerConformsToTableViewDataSourceProtocol {
    
    XCTAssertTrue([viewControllerUnderTest conformsToProtocol:@protocol(UITableViewDataSource)], @"ViewController under test does not conform to the UITableViewDataSource prototocol");
    
    XCTAssertTrue([viewControllerUnderTest respondsToSelector:@selector(numberOfSectionsInTableView:)], @"ViewController under test does not implement numberOfSectionsInTableView protocol method");
    
    XCTAssertTrue([viewControllerUnderTest respondsToSelector:@selector(tableView:numberOfRowsInSection:)], @"ViewController under test does not implement tableView:numberOfRowsInSection protocol method");
    
    XCTAssertTrue([viewControllerUnderTest respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)], @"ViewController under test does not implement tableView:cellForRowAtIndexPath");
    
    //continue with other UITableViewDataSource protocol methods of interest ...
}

- (void)testViewControllerConformsToTableViewDelegateProtocol {
    
    XCTAssertTrue([detailViewController conformsToProtocol:@protocol(UITableViewDelegate)], @"*****ViewController under test does not conform to the UITableViewDelegate protocol.");
    
    XCTAssertTrue([detailViewController respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)], @"ViewController under test does not implement tableView:didSelectRowAtIndexPath: protocol method");
    
    //continue with other UITableViewDelegate protocol methods of interest ...
}

-(void)testSearchEmployee
{
    viewControllerUnderTest.managedObjectContext = self.managedObjectContext;
    
    [viewControllerUnderTest loadView];
    [viewControllerUnderTest viewDidLoad];
    bool response = [viewControllerUnderTest searchForText:@"King"];
    XCTAssertTrue(response,@"Name doesn't exist");
}

-(void)testDetailView
{
    [detailViewController viewDidLoad];
}


-(void)testReports
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Employee" inManagedObjectContext:self.managedObjectContext];
    
    // Find the direct reports
    NSFetchRequest *reportsRequest = [[NSFetchRequest alloc] init];
    [reportsRequest setEntity:entityDescription];
    
    NSPredicate *reportsPredicate = [NSPredicate predicateWithFormat:@"managerId == %@", @"1"];
    [reportsRequest setPredicate:reportsPredicate];
    
    NSError *error;
    self.reports = [self.managedObjectContext executeFetchRequest:reportsRequest error:&error];
    if([self.reports count]==12)
    {
        // All employees reports to CEO
        XCTAssertTrue(true);
    }else {
        XCTAssertTrue(false,@"Not all employees report to CEO");
    }
    

}


@end
