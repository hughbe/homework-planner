//
//  CreatePhotoView.m
//  School Planner
//
//  Created by Hugh Bellamy on 16/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "CreatePhotoView.h"

#import "UIView+Borders.h"
#import "UIKitLocalizedString.h"

#import "Attachment.h"

@interface CreatePhotoView ()

@property (assign, nonatomic) BOOL showCustomImage;

@end

@implementation CreatePhotoView

@synthesize attachment = _attachment;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.cancelButton.layer.cornerRadius = 0;
    self.createButton.layer.cornerRadius = 0;
    
    UIColor *buttonBorderColour = [UIColor colorWithWhite:0.8 alpha:1.0];
    CGFloat buttonBorderWidth = 1.75;
    [self.cancelButton addTopBorderWithHeight:buttonBorderWidth andColor:buttonBorderColour];
    [self.createButton addTopBorderWithHeight:buttonBorderWidth andColor:buttonBorderColour];
    
    [self.imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickImage)]];
    
    self.layer.cornerRadius = 2.5;
    [self reset];
    
    self.imagePickerController = [[UIImagePickerController alloc]init];
    self.imagePickerController.delegate = self;
}

- (void)reset {
    self.attachment = nil;
    self.hidden = YES;
}

- (IBAction)verify {
    self.attachment.title = self.titleTextField.text;
    self.createButton.enabled = self.titleTextField.text.length && self.imageView.image && self.showCustomImage;
}

- (void)pickImage {
    UIViewController *controller = self.window.rootViewController;
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Add Photo", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *camera = [UIAlertAction actionWithTitle:NSLocalizedString(@"Camera", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Camera not available", nil)  message:nil preferredStyle:UIAlertControllerStyleAlert];
            [controller presentViewController:alert animated:YES completion:nil];
        }
        else {
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self.window.rootViewController presentViewController:self.imagePickerController animated:YES completion:nil];
        }
    }];
    
    UIAlertAction *cameraRoll = [UIAlertAction actionWithTitle:NSLocalizedString(@"Camera Roll", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Camera not available", nil)  message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            [controller presentViewController:alert animated:YES completion:nil];
        }
        else {
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self.window.rootViewController presentViewController:self.imagePickerController animated:YES completion:nil];
        }
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:UIKitLocalizedString(UIKitCancelIdentifier) style:UIAlertActionStyleDefault handler:nil];
    
    [actionSheet addAction:camera];
    [actionSheet addAction:cameraRoll];
    [actionSheet addAction:cancel];
    
    [controller presentViewController:actionSheet animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    UIImage *originalImage = (UIImage *) info[UIImagePickerControllerOriginalImage];
    
    UIImage *finalImage = editedImage ?: originalImage;
    if (finalImage.imageOrientation != UIImageOrientationUp) {
        UIGraphicsBeginImageContextWithOptions(finalImage.size, NO, finalImage.scale);
        [finalImage drawInRect:(CGRect){{0, 0}, finalImage.size}];
        finalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }

    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum (finalImage, nil, nil , nil);
    }
    [self imagePickerControllerDidCancel:picker];
    
    self.showCustomImage = YES;
    self.attachment.attachmentInfo = UIImagePNGRepresentation(finalImage);
    self.imageView.image = finalImage;
    [self verify];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (IBAction)cancelCreation:(id)sender {
    [self.delegate createPhotoViewDidCancel:self];
}

- (IBAction)completeCreation:(id)sender {
    [self.delegate createPhotoViewDidCreate:self];
}

- (Attachment *)attachment {
    if(!_attachment) {
        _attachment = [Attachment attachmentWithType:AttachmentTypePhoto];
    }
    return _attachment;
}

- (void)setAttachment:(Attachment *)attachment {
    _attachment = attachment;

    
    
    self.titleTextField.text = attachment.title;
    self.imageView.image = [UIImage imageWithData:attachment.attachmentInfo];
    if(!self.imageView.image) {
        self.showCustomImage = NO;
        self.imageView.image = [UIImage imageNamed:@"No Image"];
    }
    else {
        self.showCustomImage = YES;
    }
    
    [self verify];
}
@end
