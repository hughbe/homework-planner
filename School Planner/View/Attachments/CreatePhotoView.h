//
//  CreatePhotoView.h
//  School Planner
//
//  Created by Hugh Bellamy on 16/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Attachment;
@protocol CreatePhotoViewDelegate;

@interface CreatePhotoView : UIView <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (void)reset;

@property (weak, nonatomic) id<CreatePhotoViewDelegate> delegate;

@property (strong, nonatomic) Attachment *attachment;

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *createButton;

@property (strong, nonatomic) UIImagePickerController *imagePickerController;

@end

@protocol CreatePhotoViewDelegate <NSObject>

- (void)createPhotoViewDidCancel:(CreatePhotoView *)createPhotoView;
- (void)createPhotoViewDidCreate:(CreatePhotoView *)createPhotoView;

@end
