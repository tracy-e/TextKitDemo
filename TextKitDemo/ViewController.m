//
//  ViewController.m
//  TextKitDemo
//
//  Created by TracyYih on 13-10-18.
//  Copyright (c) 2013年 TracyYih. All rights reserved.
//

#import "ViewController.h"
#import "MarkupTextStorage.h"

@interface ViewController ()<UITextViewDelegate>
{
    MarkupTextStorage *_textStorage;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(preferredContentSizeDidChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    NSDictionary *titleAttributes = @{
                                      NSForegroundColorAttributeName: [UIColor purpleColor],
                                      NSTextEffectAttributeName: NSTextEffectLetterpressStyle
                                      };
    self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Markdown"
                                                                     attributes:titleAttributes];
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    
    [self createMarkupTextView];
}

- (void)createMarkupTextView
{   
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"Avenir Next" size:14]};
    NSString *content = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"content" ofType:@"txt"]
                                                  encoding:NSUTF8StringEncoding
                                                     error:nil];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:content
                                                                           attributes:attributes];
    _textStorage = [[MarkupTextStorage alloc] init];
    [_textStorage setAttributedString:attributedString];
    
    CGRect textViewRect = CGRectMake(20, 60, 280, self.view.bounds.size.height - 70);
    
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(textViewRect.size.width, CGFLOAT_MAX)];
    [layoutManager addTextContainer:textContainer];
    [_textStorage addLayoutManager:layoutManager];
    
    _textView = [[UITextView alloc] initWithFrame:textViewRect
                                    textContainer:textContainer];
    _textView.delegate = self;
    [self.view addSubview:_textView];
}

- (void)preferredContentSizeDidChanged:(NSNotification *)notification
{
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    [_textView resignFirstResponder];
}

@end
