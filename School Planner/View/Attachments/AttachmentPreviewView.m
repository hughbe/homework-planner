//
//  AttachmentPreviewView.m
//  School Planner
//
//  Created by Hugh Bellamy on 17/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "AttachmentPreviewView.h"

#import "UINavigationBar+Addition.h"

#import "Attachment.h"

@interface AttachmentPreviewView()

@end

@implementation AttachmentPreviewView

@synthesize attachments = _attachments;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UINavigationBar *navigationBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 20)];
    [navigationBar hideBottomHairline];
    [self addSubview:navigationBar];
}

- (void)imageViewTapped:(UITapGestureRecognizer *)tapGestureRecognizer {
    [UIView animateWithDuration:0.2 animations:^{
        UIView *bar = [self.scrollView viewWithTag:200 + (tapGestureRecognizer.view.tag - 100)];
        bar.alpha = 1 - bar.alpha;
    }];
}

- (void)close:(UIBarButtonItem *)sender {
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    [self.delegate attachmentPreviewViewDidClose:self];
}

- (void)share:(UIBarButtonItem *)sender {
    Attachment *attachment = self.attachments[sender.tag];
    id toShare = [NSNull null];
    if(attachment.type == AttachmentTypePhoto) {
        toShare = [UIImage imageWithData:attachment.attachmentInfo];
    }
    else if(attachment.type == AttachmentTypeWebsite) {
        toShare = attachment.attachmentInfo;
    }
    
    NSArray *activityItems = @[toShare];
    UIActivityViewController *shareViewController = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    [self.window.rootViewController presentViewController:shareViewController animated:YES completion:nil];
}

- (void)back:(UIBarButtonItem *)sender {
    UIWebView *webView = [self.scrollView viewWithTag:sender.tag - 400];
    [webView goBack];
}

- (void)forward:(UIBarButtonItem *)sender {
    UIWebView *webView = [self.scrollView viewWithTag:sender.tag - 300];
    [webView goForward];
}

- (void)refresh:(UIBarButtonItem *)sender {
    UIWebView *webView = [self.scrollView viewWithTag:sender.tag - 500];
    [webView reload];
}

- (void)loadAttachments {
    for(UIView *view in [self.scrollView.subviews copy]) {
        if(view.tag > 0) {
            [view removeFromSuperview];
        }
    }
    
    NSInteger i = 0;
    for(Attachment *attachment in self.attachments) {
        
        UINavigationBar *bar = [[UINavigationBar alloc]initWithFrame:CGRectMake(i * self.frame.size.width, 20, self.frame.size.width, 44)];
        bar.tag = 200 + i;
        if(attachment.type == AttachmentTypePhoto) {
            bar.alpha = 0.0;
        }
        [bar pushNavigationItem:[[UINavigationItem alloc]initWithTitle:attachment.title] animated:NO];
        bar.translucent = NO;
        bar.topItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStylePlain target:self action:@selector(close:)];
        bar.topItem.leftBarButtonItem.tag = i;
        bar.topItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)];
        
        CGRect frame = self.bounds;
        frame.origin.x = i * frame.size.width;
        UIView *view;
        if(attachment.type == AttachmentTypePhoto) {
            view = [[UIScrollView alloc]init];
            ((UIScrollView *)view).delegate = self;
            ((UIScrollView *)view).minimumZoomScale = 1;
            ((UIScrollView *)view).maximumZoomScale = 3;
            UIImage *image = [UIImage imageWithData:attachment.attachmentInfo];
            UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
            imageView.userInteractionEnabled = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageViewTapped:)];
            tapGestureRecognizer.cancelsTouchesInView = NO;
            [imageView addGestureRecognizer:tapGestureRecognizer];
            imageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
            imageView.tag = 100 + i;
            [view addSubview:imageView];
        }
        else {
            view = [[UIWebView alloc]init];
            view.tag = 100 + i;
            frame.origin.y = bar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
            frame.size.height -= frame.origin.y;
            ((UIWebView*)view).delegate = self;
            NSString *URLString = attachment.attachmentInfo;
            if(![URLString containsString:@"http://"]) {
                URLString = [@"http://" stringByAppendingString:URLString];
            }
            NSURL *URL = [NSURL URLWithString:URLString];
            NSURLRequest *request = [NSURLRequest requestWithURL:URL];
            [(UIWebView *)view loadRequest:request];
        }
        view.frame = frame;
        [self.scrollView addSubview:view];
        [self.scrollView addSubview:bar];
        
        if(attachment.type == AttachmentTypeWebsite) {
            UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(i * self.frame.size.width, self.scrollView.frame.size.height - 44, self.frame.size.width, 44)];
            toolbar.tag = 300 + i;
            UIBarButtonItem *back = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
            back.enabled = NO;
            back.tag = 500 + i;
            UIBarButtonItem *forward = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"forward.png"] style:UIBarButtonItemStylePlain target:self action:@selector(forward:)];
            forward.enabled = NO;
            forward.tag = 400 + i;
            forward.enabled = NO;
            forward.tag = 400 + i;
            UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            UIBarButtonItem *reload = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
            reload.tag = 600 + i;
            [toolbar setItems:@[back, forward, flexibleSpace, reload] animated:NO];
            [self.scrollView addSubview:toolbar];
        }
        i++;
    }
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * i, self.scrollView.frame.size.height);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    for(UIImageView *view in scrollView.subviews) {
        if([view isKindOfClass:[UIImageView class]]) {
            return view;
        }
    }
    return nil;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    UINavigationBar *bar = [self.scrollView viewWithTag:webView.tag + 100];
    bar.topItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    UIToolbar *toolbar = [self.scrollView viewWithTag:webView.tag + 200];
    
    for(UIBarButtonItem *barButtonItem in toolbar.items) {
        if([barButtonItem isKindOfClass:[UIBarButtonItem class]]) {
            if(barButtonItem.tag < 600) {
                if(barButtonItem.tag > 500) {
                    barButtonItem.enabled = [webView canGoBack];
                }
                else {
                    barButtonItem.enabled = [webView canGoForward];
                }
            }
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Connection Error", nil) preferredStyle:UIAlertControllerStyleAlert];

    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
    
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
}

- (NSArray *)attachments {
    if(!_attachments) {
        _attachments = [NSArray array];
    }
    return _attachments;
}

- (void)setAttachments:(NSArray *)attachments {
    _attachments = attachments;
    [self loadAttachments];
}

- (void)setViewingAttachment:(NSInteger)viewingAttachment {
    _viewingAttachment = viewingAttachment;
    self.scrollView.contentOffset = CGPointMake(viewingAttachment * self.frame.size.width, 0);
}

@end
