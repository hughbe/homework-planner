//
//  CreateWebsiteView.h
//  School Planner
//
//  Created by Hugh Bellamy on 16/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Attachment;

@protocol CreateWebsiteViewDelegate;

@interface CreateWebsiteView : UIView <UITextFieldDelegate>

- (void)reset;

@property (weak, nonatomic) id<CreateWebsiteViewDelegate> delegate;

@property (strong, nonatomic) Attachment *attachment;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *URLTextField;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *createButton;

@end

@protocol CreateWebsiteViewDelegate <NSObject>

- (void)createWebsiteViewDidCancel:(CreateWebsiteView *)createWebsiteView;
- (void)createWebsiteViewDidCreate:(CreateWebsiteView *)createWebsiteView;

@end
