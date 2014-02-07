//
//  MarkupTextStorage.m
//  TextKitDemo
//
//  Created by TracyYih on 13-10-18.
//  Copyright (c) 2013年 TracyYih. All rights reserved.
//

#import "MarkupTextStorage.h"

@implementation MarkupTextStorage
{
    NSMutableAttributedString *_attributedString;
    NSDictionary *_attributeDictionary;
    NSDictionary *_bodyAttributes;
}

- (id)init
{
    self = [super init];
    if (self) {
        _attributedString = [[NSMutableAttributedString alloc] init];
        
        [self createHighlightPatterns];
    }
    return self;
}

- (NSString *)string
{
    return [_attributedString string];
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range
{
    return [_attributedString attributesAtIndex:location effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str
{
    [self beginEditing];
    [_attributedString replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedCharacters | NSTextStorageEditedAttributes
           range:range changeInLength:str.length - range.length];
    [self endEditing];
}

- (void)setAttributes:(NSDictionary *)attrs range:(NSRange)range
{
    [self beginEditing];
    [_attributedString setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes
           range:range changeInLength:0];
    [self endEditing];
}

#pragma mark -
- (void)processEditing
{
    [self performReplacementsForRange:[self editedRange]];
    [super processEditing];
}

- (void)performReplacementsForRange:(NSRange)changedRange
{
    NSRange extendedRange = NSUnionRange(changedRange, [[_attributedString string]
                                                        lineRangeForRange:NSMakeRange(changedRange.location, 0)]);
    extendedRange = NSUnionRange(changedRange, [[_attributedString string]
                                                lineRangeForRange:NSMakeRange(NSMaxRange(changedRange), 0)]);
    [self applyStylesToRange:extendedRange];
}

- (NSDictionary*)createAttributesForFontStyle:(NSString*)style
                                    withTrait:(uint32_t)trait {
    UIFontDescriptor *fontDescriptor = [UIFontDescriptor
                                        preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
    
    UIFontDescriptor *descriptorWithTrait = [fontDescriptor
                                             fontDescriptorWithSymbolicTraits:trait];
    
    UIFont* font =  [UIFont fontWithDescriptor:descriptorWithTrait size: 0.0];
    return @{ NSFontAttributeName : font };
}

- (void)createHighlightPatterns {
    _bodyAttributes = @{ NSFontAttributeName:[UIFont fontWithName:@"Avenir Next" size:14],
                         NSBackgroundColorAttributeName: [UIColor clearColor],
                         NSForegroundColorAttributeName: [UIColor colorWithRed:(100 / 255.0) green:(100 / 255.0) blue:(100 / 255.0) alpha:1],
                         NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleNone],
                         NSStrokeColorAttributeName: @0 };
    NSDictionary *headingAttributes = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:15],
                                         NSForegroundColorAttributeName: [UIColor blackColor] };
    
    NSDictionary *boldAttributes = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:14],
                                      NSForegroundColorAttributeName: [UIColor blackColor] };
    
    NSDictionary *italicAttributes = @{ NSFontAttributeName: [UIFont italicSystemFontOfSize:14] };
    
    NSDictionary *boldItalicAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-BoldItalic" size:14],
                                            NSForegroundColorAttributeName: [UIColor blackColor] };
    
    NSDictionary *strikethroughAttributes = @{ NSStrikethroughColorAttributeName: [UIColor blackColor],
                                               NSStrikethroughStyleAttributeName: @1};
    
    NSDictionary *inlineCodeAttributes = @{ NSBackgroundColorAttributeName: [UIColor colorWithRed:(239 / 255.0) green:(239 / 255.0) blue:(239 / 255.0) alpha:1],
                                            NSForegroundColorAttributeName: [UIColor blackColor]};
    
    NSMutableDictionary *blockCodeAttributes = [_bodyAttributes mutableCopy];
    blockCodeAttributes[NSFontAttributeName] = [UIFont fontWithName:@"Menlo-Regular" size:14];
    
    NSDictionary *linkAttributes = @{ NSForegroundColorAttributeName: [UIColor colorWithRed:0.255 green:0.514 blue:0.769 alpha:1.00] };
    
    //TODO: full markdown highlight
    /*
     1. 标题       H1~H6 === ---
     2. 粗体       **bold** __bold__
     3. 斜体       *italic* _italic_
     4. 粗斜体      ***bold italic*** ___bold italic___ *__bold italic__* **_bold italic_** _**bold italic**_ __*bold italic*__
     5. 链接       [link](http://example.com/)                 [link][id] \n [id]: http://example.com/
     6. 图片       ![image](http://example.com/image.png)      ![image][id] \n [id]: http://example.com/image.png
     7. 纯链接      http://example.com/
     8. 行内代码    `inline code`
     9. 代码块      ```\n code block \n```
     10. 引用      > text
     11. 分割线     ---  * * *  - - -
     */
    
    _attributeDictionary = @{
                             @"[a-zA-Z0-9\t\n ./<>?;:\\\"'`!@#$%^&*()[]{}_+=|\\-]":_bodyAttributes,
                             @"(\\#{1,6}([^\n]+?)*\n)": headingAttributes,
                             @"\\**(?:^|[^*])(\\*\\*(\\w+(\\s\\w+)*)\\*\\*)":boldAttributes,
                             @"\\**(?:^|[^*])(\\*(\\w+(\\s\\w+)*)\\*)":italicAttributes,
                             @"(\\*\\*\\*\\w+(\\s\\w+)*\\*\\*\\*)":boldItalicAttributes,
                             @"(~~\\w+(\\s\\w+)*~~)": strikethroughAttributes,
                             @"(`\\w+(\\s\\w+)*`)":inlineCodeAttributes,
                             @"(```\n([\\s\n\\d\\w[/[\\.,-\\/#!?@$%\\^&\\*;:|{}<>+=\\-'_~()\\\"\\[\\]\\\\]/]]*)\n```)":blockCodeAttributes,
                             @"(!?\\[\\w+(\\s\\w+)*\\]\\(\\w+\\w[/[\\.,-\\/#!?@$%\\^&\\*;:|{}<>+=\\-'_~()\\\"\\[\\]\\\\]/ \\w+]*\\))":linkAttributes
                             };}

- (void)applyStylesToRange:(NSRange)searchRange
{
    for (NSString *key in _attributeDictionary) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:key options:0 error:nil];
        
        NSDictionary *attributes = _attributeDictionary[key];
        
        [regex enumerateMatchesInString:[_attributedString string] options:0 range:searchRange
                             usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
                                 NSRange matchRange = [match rangeAtIndex:1];
                                 [self addAttributes:attributes range:matchRange];
                                 
                                 if (NSMaxRange(matchRange)+1 < self.length) {
                                     [self addAttributes:_bodyAttributes range:NSMakeRange(NSMaxRange(matchRange)+1, 1)];
                                 }
                             }];
    }}

@end
