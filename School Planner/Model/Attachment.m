//
//  Attachment.m
//  School Planner
//
//  Created by Hugh Bellamy on 16/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "Attachment.h"

#define ID_KEY @"attachment_id"
#define TYPE_KEY @"attachment_type"

#define TITLE_KEY @"attachment_title"
#define INFO_KEY @"attachment_attachmentInfo"

@implementation Attachment

+ (instancetype)attachmentWithType:(AttachmentType)type {
    Attachment *attachment = [[Attachment alloc]init];
    if(attachment) {
        attachment.type = type;
    }
    return attachment;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if(self) {
        self.ID = [aDecoder decodeObjectForKey:ID_KEY];
        self.type = (AttachmentType) [aDecoder decodeIntegerForKey:TYPE_KEY];
        
        self.title = [aDecoder decodeObjectForKey:TITLE_KEY];
        self.attachmentInfo = [aDecoder decodeObjectForKey:INFO_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.ID forKey:ID_KEY];
    [aCoder encodeInteger:self.type forKey:TYPE_KEY];
    
    [aCoder encodeObject:self.title forKey:TITLE_KEY];
    [aCoder encodeObject:self.attachmentInfo forKey:INFO_KEY];
}

- (id)copyWithZone:(NSZone *)zone {
    Attachment *attachment = (Attachment *)[[self class]allocWithZone:zone];
    attachment.ID = [self.ID copyWithZone:zone];
    attachment.type = self.type;
    attachment.title = [self.title copyWithZone:zone];
    attachment.attachmentInfo = [self.attachmentInfo copyWithZone:zone];
    return attachment;
}

- (BOOL)isEqual:(id)object {
    return object == self || ([object isKindOfClass:[self class]] && [[object ID] isEqualToString:[self ID]] && [object ID].length);

}

- (NSString *)description {
    NSString *type;
    if(self.type == AttachmentTypePhoto) {
        type = @"Photo";
    }
    else if(self.type == AttachmentTypeWebsite) {
        type = @"Website";
    }
    
    return [NSString stringWithFormat:@"Attachment - %@ - title: %@ - ID: %@ ", type, self.title, self.ID];
}

- (NSString *)ID {
    if(!_ID) {
        _ID = @"";
    }
    return _ID;
}

- (NSString *)title {
    if(!_title) {
        _title = @"";
    }
    return _title;
}

- (NSString *)attachmentInfo {
    if(!_attachmentInfo) {
        _attachmentInfo = @"";
    }
    return _attachmentInfo;
}


@end
