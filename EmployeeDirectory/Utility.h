//
//  Utility.h
//  EmployeeDirectory
//
//  Created by Naveen on 4/21/16.
//  Copyright © 2016 Christophe Coenraets. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject
@property (nonatomic, strong)  UIView *vw;

-(void)showLoadingScreen;
-(void)removeLoadingScreen;
+ (id)sharedManager;

@end
