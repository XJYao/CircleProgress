//
//  XCircleProgress.m
//  XFramework
//
//  Created by XJY on 16/1/27.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "XCircleProgress.h"

@interface XCircleProgress () {
    NSArray *observableKeypaths;
}

@end

@implementation XCircleProgress

#pragma mark - Public

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
        [self registerForKVO];
        [self addUI];
        
        if (!CGRectEqualToRect(frame, CGRectZero)) {
            [self setNeedsLayout];
        }
    }
    return self;
}

#pragma mark - Private

- (void)dealloc {
    [self unregisterFromKVO];
}

- (void)initialize {
    [self setBackgroundColor:[UIColor clearColor]];
    
    observableKeypaths = @[
                           @"progress",
                           @"textFont",
                           @"text"
                           ];

    _progress = 0;
    _indicatorGradient = YES;
    _indicatorRadius = 50;
    
    _indicatorAlpha = 1.0f;
    _indicatorBackgroundAlpha = 1.0f;
    _indicatorColor = [UIColor whiteColor];
    _indicatorBackgroundColor = [UIColor whiteColor];
    _indicatorWidth = 5;
    _indicatorBackgroundWidth = 3;
    
    _textColor = [UIColor whiteColor];
    _textFont = [UIFont boldSystemFontOfSize:17];
    _text = @"";
    _pointImageSize = CGSizeZero;
}

- (void)registerForKVO {
    for (NSString *key in observableKeypaths) {
        [self addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (void)unregisterFromKVO {
    for (NSString *key in observableKeypaths) {
        [self removeObserver:self forKeyPath:key];
    }
}

- (void)addUI {
    _textLabel = [[UILabel alloc] init];
    [_textLabel setBackgroundColor:[UIColor clearColor]];
    [_textLabel setTextAlignment:NSTextAlignmentCenter];
    [_textLabel setTextColor:_textColor];
    [_textLabel setFont:_textFont];
    [_textLabel setText:_text];
    [_textLabel setNumberOfLines:0];
    [_textLabel setLineBreakMode:NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail];
    [self addSubview:_textLabel];
    
    _pointImageView = [[UIImageView alloc] init];
    [_pointImageView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_pointImageView];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat textLabelWidth = 0;
    CGFloat textLabelHeight = 0;
    CGFloat textLabelX = 0;
    CGFloat textLabelY = 0;
    if ([self isStringEmpty:_textLabel.text] == NO) {
        textLabelWidth = [self labelSize].width;
        textLabelHeight = [self heightForWidth:textLabelWidth];
        
        textLabelX = (self.frame.size.width - textLabelWidth) / 2.0;
        textLabelY = (self.frame.size.width - textLabelHeight) / 2.0;
    }
    
    [_textLabel setFrame:CGRectMake(textLabelX, textLabelY, textLabelWidth, textLabelHeight)];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat startAngle = - M_PI_2;

    //draw background
    if (_indicatorBackgroundColor) {
        NSArray *RGB = [self getRGBFromColor:_indicatorBackgroundColor];
        
        CGFloat R = [[RGB objectAtIndex:0] floatValue];
        CGFloat G = [[RGB objectAtIndex:1] floatValue];
        CGFloat B = [[RGB objectAtIndex:2] floatValue];

        UIColor *color = [UIColor colorWithRed:R green:G blue:B alpha:_indicatorBackgroundAlpha];
        CGContextSetStrokeColorWithColor(context, [color CGColor]);
        CGContextSetLineWidth(context, _indicatorBackgroundWidth);
        
        CGFloat endAngle = startAngle + 2 * M_PI;
        CGContextAddArc(context, self.frame.size.width / 2.0, self.frame.size.height / 2.0, _indicatorRadius, startAngle, endAngle, 0);
        CGContextDrawPath(context, kCGPathStroke);
    }
    
    //draw indicator
    if (_indicatorColor) {
        NSArray *RGB = [self getRGBFromColor:_indicatorColor];
        
        CGFloat R = [[RGB objectAtIndex:0] floatValue];
        CGFloat G = [[RGB objectAtIndex:1] floatValue];
        CGFloat B = [[RGB objectAtIndex:2] floatValue];

        if (_indicatorGradient == NO) {
            UIColor *color = [UIColor colorWithRed:R green:G blue:B alpha:_indicatorAlpha];
            CGContextSetStrokeColorWithColor(context, [color CGColor]);
            
            CGContextSetLineWidth(context, _indicatorWidth);
            CGFloat endAngle = startAngle + _progress * 2 * M_PI;
            CGContextAddArc(context, self.frame.size.width / 2.0, self.frame.size.height / 2.0, _indicatorRadius, startAngle, endAngle, 0);
            CGContextDrawPath(context, kCGPathStroke);
        } else {

            for (CGFloat progress = 0; progress <= _progress; progress += 0.01) {
                UIColor *color = [UIColor colorWithRed:R green:G blue:B alpha:(_indicatorBackgroundAlpha + (_indicatorAlpha - _indicatorBackgroundAlpha) * progress)];
                CGContextSetStrokeColorWithColor(context, [color CGColor]);
                
                CGFloat currentIndicatorWidth = _indicatorBackgroundWidth + (_indicatorWidth - _indicatorBackgroundWidth) * progress;
                CGContextSetLineWidth(context, currentIndicatorWidth);
                
                CGFloat endAngle = startAngle + 0.01 * 2 * M_PI;
                CGContextAddArc(context, self.frame.size.width / 2.0, self.frame.size.height / 2.0, _indicatorRadius, startAngle, endAngle, 0);
                
                CGContextDrawPath(context, kCGPathStroke);
                
                startAngle = endAngle;
                
                if (_pointImageView && _pointImageView.image) {
                    CGFloat pointImageViewWidth = 0;
                    CGFloat pointImageViewHeight = 0;
                    
                    if (CGSizeEqualToSize(_pointImageSize, CGSizeZero)) {
                        CGFloat pointImageViewWidth = _pointImageView.image.size.width;
                        CGFloat pointImageViewHeight = _pointImageView.image.size.height;
                        
                        if (pointImageViewWidth > _indicatorWidth * 2) {
                            pointImageViewWidth = _indicatorWidth * 2;
                        }
                        
                        if (pointImageViewHeight > _indicatorWidth * 2) {
                            pointImageViewHeight = _indicatorWidth * 2;
                        }
                    } else {
                        pointImageViewWidth = _pointImageSize.width;
                        pointImageViewHeight = _pointImageSize.height;
                    }

                    CGFloat pointImageViewX = _indicatorRadius * cos(endAngle) + self.frame.size.width / 2.0 - pointImageViewWidth / 2.0;
                    CGFloat pointImageViewY = _indicatorRadius * sin(endAngle) + self.frame.size.height / 2.0 - pointImageViewHeight / 2.0;
                    
                    [_pointImageView setFrame:CGRectMake(pointImageViewX, pointImageViewY, pointImageViewWidth, pointImageViewHeight)];
                }
            }
        }
    }
}

#pragma mark - Property

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    [_textLabel setTextColor:_textColor];
}

#pragma mark - Tool

void x_dispatch_main_async(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

- (BOOL)isStringEmpty:(NSString *)str {
    if(str != NULL && str && [str isEqualToString:@""] == NO && str.length > 0) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)isArrayEmpty:(NSArray *)array {
    if (array != nil && array.count > 0) {
        return NO;
    } else {
        return YES;
    }
}

- (CGSize)labelSize {
    return ([self isStringEmpty:_textLabel.text] == NO ? [_textLabel.text sizeWithFont:_textLabel.font] : CGSizeZero);
}

- (CGFloat)heightForWidth:(CGFloat)width {
    CGSize maximumLabelSize = CGSizeMake(width, MAXFLOAT);
    
    CGSize labelSize;
    if ([self isStringEmpty:_textLabel.text] == YES) {
        labelSize = CGSizeZero;
    } else {
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
            NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:_textLabel.font, NSFontAttributeName,nil];
            labelSize = [_textLabel.text boundingRectWithSize:maximumLabelSize options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
        } else {
            labelSize = [_textLabel.text sizeWithFont:_textLabel.font constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
        }
    }
    
    return labelSize.height + 1;
}

- (NSArray *)getRGBFromColor:(UIColor *)color {
    if (!color) {
        return nil;
    }
    
    CGColorRef colorRef = [color CGColor];
    size_t numComponents = CGColorGetNumberOfComponents(colorRef);
    
    NSArray *componentsArray = nil;
    
    if (numComponents == 2 || numComponents == 4) {
        const CGFloat *components = CGColorGetComponents(colorRef);
        
        CGFloat R;
        CGFloat G;
        CGFloat B;
        CGFloat alpha;
        
        if (numComponents == 2) {
            R = components[0];
            G = R;
            B = R;
            alpha = components[1];
        } else if (numComponents == 4) {
            R = components[0];
            G = components[1];
            B = components[2];
            alpha = components[3];
        }
        
        componentsArray = @[
                            [NSNumber numberWithFloat:R],
                            [NSNumber numberWithFloat:G],
                            [NSNumber numberWithFloat:B],
                            [NSNumber numberWithFloat:alpha],
                            ];
    }
    
    return componentsArray;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    x_dispatch_main_async(^{
        if ([keyPath isEqualToString:@"progress"] == YES)
        {
            [self setNeedsDisplay];
        }
        
        else if ([keyPath isEqualToString:@"textFont"] == YES)
        {
            [_textLabel setFont:_textFont];
            [self setNeedsLayout];
        }
        
        else if ([keyPath isEqualToString:@"text"] == YES)
        {
            [_textLabel setText:_text];
            [self setNeedsLayout];
        }
    });
}

@end
