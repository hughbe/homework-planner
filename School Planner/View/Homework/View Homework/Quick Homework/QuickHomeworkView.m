//
//  QuickHomeworkView.m
//  School Planner
//
//  Created by Hugh Bellamy on 14/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "QuickHomeworkView.h"

#import "UIView+Borders.h"

#import "Homework.h"
#import "Subject.h"

#import "HomeworkTableViewCell.h"
#import "Attachment.h"

@interface QuickHomeworkView ()

@property (strong, nonatomic) NSDateFormatter *dueDateFormatter;

@end

@implementation QuickHomeworkView

+ (QuickHomeworkView *)quickHomeworkView {
    return [[[NSBundle mainBundle]loadNibNamed:@"QuickHomeworkView" owner:nil options:nil] firstObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.attachmentsTableView registerNib:[UINib nibWithNibName:@"AttachmentTableViewCell" bundle:nil] forCellReuseIdentifier:@"Cell"];
    
    self.containerView.center = self.center;
    self.containerView.layer.cornerRadius = 2.5;
    
    CGPoint center = self.center;
    center.x += self.frame.size.width;
    self.attachmentsTableView.center = center;
    self.attachmentsTableView.layer.cornerRadius = 2.5;
    
    self.attachmentPreviewView.center = center;
    self.attachmentPreviewView.delegate = self;
    
    
    CAShapeLayer *border = [CAShapeLayer layer];
    border.strokeColor = [UIColor colorWithRed:67/255.0f green:37/255.0f blue:83/255.0f alpha:1].CGColor;
    border.fillColor = nil;
    border.lineDashPattern = @[@4, @2];
    border.path = [UIBezierPath bezierPathWithRect:self.homeworkSubjectContainerView.bounds].CGPath;
    
    [self.homeworkSubjectContainerView.layer addSublayer:border];
    
    [self.homeworkDateContainerView addRightBorderWithWidth:1.0 andColor:[UIColor blackColor]];
    
    UIColor *timeBackgroundColor = [UIColor colorWithWhite:0.65 alpha:1.0];
    CGFloat timeBorderWidth = 1;
    CGFloat timeCornerRadius = 0.0;
    //self.homeworkTimeContainerView.backgroundColor = timeBackgroundColor;
    //self.homeworkTimeContainerView.layer.borderWidth = timeBorderWidth;
    //self.homeworkTimeContainerView.layer.cornerRadius = timeCornerRadius;
    
    self.homeworkDateEndContainerView.backgroundColor = timeBackgroundColor;
    self.homeworkDateEndContainerView.layer.borderWidth = timeBorderWidth;
    self.homeworkDateEndContainerView.layer.cornerRadius = timeCornerRadius;
    
    self.homeworkSummaryLabel.textAlignment = NSTextAlignmentJustified;
    [self.backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backgroundTapped)]];
}

- (void)backgroundTapped {
    if(self.attachmentsTableView.center.x < self.frame.size.width) {
        [UIView animateWithDuration:0.25 animations:^{
            self.attachmentsTableView.center = CGPointMake(self.center.x + self.frame.size.width, self.center.y);
        }];
        
        [UIView animateWithDuration:0.35 animations:^{
            self.containerView.center = self.center;
        }];
    }
    else {
        self.homeworkSummaryLabel.selectedRange = NSMakeRange(0, 0);
        [self.delegate quickHomeworkViewDidClose:self];
    }
}

- (void)setHomework:(Homework *)homework {
    _homework = homework;
    [self refresh];
}

- (void)refresh {
    self.homeworkSubjectLabel.text = self.homework.subject.subjectName;
    self.homeworkSummaryLabel.text = self.homework.summary;
    
    self.teacherLabel.text = self.homework.subject.teacher;
    
    self.typeLabel.text = [self.homework typeString];
    self.homeworkDateLabel.text = [self.homework dueDateString];
    
    self.attachmentsNumberLabel.text = [@([self.homework.attachments count])stringValue];
    [self.attachmentsTableView reloadData];
}

- (IBAction)showAttachments:(id)sender {
    if(self.homework.attachments.count) {
        [UIView animateWithDuration:0.35 animations:^{
            self.attachmentsTableView.center = self.center;
        }];
    
        [UIView animateWithDuration:0.25 animations:^{
            CGRect frame = self.containerView.frame;
            frame.origin.y = self.frame.size.height - self.homeworkSubjectLabel.frame.size.height - 8;
            self.containerView.frame = frame;
        }];
    }
}

- (NSDateFormatter *)dueDateFormatter {
    if(!_dueDateFormatter) {
        _dueDateFormatter = [[NSDateFormatter alloc]init];
        _dueDateFormatter.dateStyle = NSDateFormatterShortStyle;
    }
    return _dueDateFormatter;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.containerView.center = self.center;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.homework.attachments.count ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.homework.attachments.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if((NSUInteger)indexPath.row < self.homework.attachments.count) {
        Attachment *attachment = self.homework.attachments[indexPath.row];
        return attachment.type == AttachmentTypePhoto ? UITableViewAutomaticDimension : 60;
    }
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeworkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.accessoryImageView.center = CGPointMake(cell.accessoryImageView.center.x, cell.frame.size.height / 2);
    cell.timeLabel.text = @"";
    if((NSUInteger)indexPath.row < self.homework.attachments.count) {
        Attachment *attachment = self.homework.attachments[indexPath.row];
        cell.subjectLabel.text = attachment.title;
        if(attachment.type == AttachmentTypePhoto) {
            cell.accessoryImageView.image = [UIImage imageNamed:@"camera.png"];
            cell.subjectLabel.center = CGPointMake(cell.subjectLabel.center.x, cell.frame.size.height / 2);
        }
        else if(attachment.type == AttachmentTypeWebsite) {
            if([attachment.attachmentInfo isKindOfClass:[NSString class]]) {
                cell.timeLabel.text = attachment.attachmentInfo;
                cell.subjectLabel.center = CGPointMake(cell.subjectLabel.center.x, cell.subjectLabel.frame.size.height / 2);
            }
            cell.accessoryImageView.image = [UIImage imageNamed:@"website.png"];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if((NSUInteger)indexPath.row < self.homework.attachments.count) {
        self.attachmentPreviewView.attachments = self.homework.attachments;
        self.attachmentPreviewView.viewingAttachment = indexPath.row;
        [UIView animateWithDuration:0.3 animations:^{
            self.attachmentPreviewView.center = CGPointMake(self.center.x, self.frame.size.height / 2);
        }];
    }
}

- (void)attachmentPreviewViewDidClose:(AttachmentPreviewView *)attachmentPreviewView {
    [UIView animateWithDuration:0.3 animations:^{
        self.attachmentPreviewView.center = CGPointMake(self.center.x + self.frame.size.width, self.center.y);
    }];
}
@end
