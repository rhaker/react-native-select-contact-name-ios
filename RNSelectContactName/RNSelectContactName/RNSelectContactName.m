//
//  RNSelectContactName.m
//  RNSelectContactName
//
//  Created by Ross Haker on 10/22/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "RNSelectContactName.h"

@implementation RNSelectContactName

// Expose this module to the React Native bridge
RCT_EXPORT_MODULE()

// Persist data
RCT_EXPORT_METHOD(selectName:(BOOL *)boolType
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    
    // save the resolve promise
    self.resolve = resolve;
    
    // set up an error message
    NSError *error = [
                      NSError errorWithDomain:@"some_domain"
                      code:200
                      userInfo:@{
                                 NSLocalizedDescriptionKey:@"ios8 or higher required"
                                 }];
    
    
    // detect the ios version
    NSString *ver = [[UIDevice currentDevice] systemVersion];
    float ver_float = [ver floatValue];
    
    // check that ios is version 8.0 or higher
    if (ver_float < 8.0) {
        
        reject(error);
        
    } else {
        
        // check permissions
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
            ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
            
            // permission denied
            error = [
                     NSError errorWithDomain:@"some_domain"
                     code:300
                     userInfo:@{
                                NSLocalizedDescriptionKey:@"Permissions denied by user."
                                }];
            
            reject(error);
            
        } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
            
            // permission authorized
            ABPeoplePickerNavigationController *picker;
            picker = [[ABPeoplePickerNavigationController alloc] init];
            picker.peoplePickerDelegate = self;
            
            UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
            [vc presentViewController:picker animated:YES completion:nil];
            
        } else {
            
            // not determined - request permissions
            ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
                
                if (!granted){
                    
                    // user denied access
                    NSError *errorDenied = [
                                            NSError errorWithDomain:@"some_domain"
                                            code:300
                                            userInfo:@{
                                                       NSLocalizedDescriptionKey:@"Permissions denied by user."
                                                       }];
                    
                    reject(errorDenied);
                    return;
                }
                
                // user authorized access
                ABPeoplePickerNavigationController *picker;
                picker = [[ABPeoplePickerNavigationController alloc] init];
                picker.peoplePickerDelegate = self;
                
                UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
                [vc presentViewController:picker animated:YES completion:nil];
                
            });
            
        }
        
    }
    
    
}

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person
{
    
    // get the first name
    NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    
    //get the middle name
    NSString *middleName = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
    
    // get the last name
    NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    // set the return strings
    NSString* returnFirstName;
    NSString* returnLastName;
    NSString* returnMiddleName;
    
    // check for null values
    if (firstName) {
        returnFirstName = firstName;
    } else {
        returnFirstName = @"";
    }
    
    // check for null values
    if (lastName) {
        returnLastName = lastName;
    } else {
        returnLastName = @"";
    }
   
    // check for null values
    if (middleName) {
        returnMiddleName = middleName;
    } else {
        returnMiddleName = @"";
    }
    
    // Set the return dictionary
    NSDictionary *resultsDict = @{
                                  @"firstName" : returnFirstName,
                                  @"middleName" : returnMiddleName,
                                  @"lastName" : returnLastName,
                                  };
    
    
    UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [vc dismissViewControllerAnimated:YES completion:nil];
    
    // resolve the name
    self.resolve(resultsDict);
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    return NO;
}

-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    
    UIViewController *vc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [vc dismissViewControllerAnimated:YES completion:nil];
}

@end
