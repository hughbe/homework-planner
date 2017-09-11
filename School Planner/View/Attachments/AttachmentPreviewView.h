//
//  AttachmentPreviewView.h
//  School Planner
//
//  Created by Hugh Bellamy on 17/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AttachmentPreviewViewDelegate;

@interface AttachmentPreviewView : UIView <UIWebViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) id<AttachmentPreviewViewDelegate> delegate;
@property (strong, nonatomic) NSArray *attachments;
@property (assign, nonatomic) NSInteger viewingAttachment;

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@protocol AttachmentPreviewViewDelegate <NSObject>

- (void)attachmentPreviewViewDidClose:(AttachmentPreviewView *)attachmentPreviewView;

@end
