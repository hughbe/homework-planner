//
//  Attachment.h
//  School Planner
//
//  Created by Hugh Bellamy on 16/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AttachmentType) {
    AttachmentTypePhoto,
    AttachmentTypeWebsite
};

@interface Attachment : NSObject <NSCoding, NSCopying>

+ (instancetype)attachmentWithType:(AttachmentType)type;

@property (strong, nonatomic) NSString *ID;

@property (assign, nonatomic) AttachmentType type;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) id attachmentInfo;

@end
