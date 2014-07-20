//
//  DMRNotificationView.m
//  notificationview
//
//  Created by Damir Tursunovic on 1/23/13.
//  Copyright (c) 2013 Damir Tursunovic (damir.me). All rights reserved.
//

#import "DMRNotificationView.h"

// Change these values to match your needs...
static CGFloat kNotificationViewTintColorTransparency = 0.80;           // Default tint color transparency
static NSTimeInterval kNotificationViewDefaultHideTimeInterval = 4.5;   // Number of seconds until auto dismiss
static CGFloat kNotificationViewVerticalInset = 10.0;                   // Top and bottom inset
static CGFloat kNotificationViewLabelVerticalPadding = 5.0;             // Distance between title and subtitle
static CGFloat kNotificationViewShadowOffset = 5.0;                     // Shadow offset
static UIColor *kNotificationViewDefaultTintColor;                      // Default tint color
static UIColor *kNotificationViewDefaultBackgroundColor;                // Default background color

@implementation DMRNotificationView
@synthesize delegate = _delegate;
@synthesize tintColor = _tintColor;

-(void)dealloc
{
    [self setDidTapHandler:nil];
}


+(void)initialize {
    kNotificationViewDefaultTintColor = [UIColor colorWithRed:0.133 green:0.267 blue:0.533 alpha:1.000];
    kNotificationViewDefaultBackgroundColor = UIColor.clearColor;
}



#pragma mark -
#pragma mark Default Initializer

-(id)initWithTitle:(NSString *)title subTitle:(NSString *)subTitle targetView:(UIView *)view
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.tintColor = kNotificationViewDefaultTintColor;
        self.backgroundColor = kNotificationViewDefaultBackgroundColor;
        self.contentMode = UIViewContentModeRedraw;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.title = title;
        self.subTitle = subTitle;
        self.targetView = view;
        self.isTransparent = YES;
        self.hideTimeInterval = kNotificationViewDefaultHideTimeInterval;
    }
    return self;
}


#pragma mark -
#pragma mark Convenience Initializers

+(void)showInView:(UIView *)view title:(NSString *)title subTitle:(NSString *)subTitle
{
    [self showInView:view title:title subTitle:subTitle tintColor:nil];
}

+(void)showInView:(UIView *)view title:(NSString *)title subTitle:(NSString *)subTitle tintColor:(UIColor *)tintColor
{
    DMRNotificationView *notificationView = [[self alloc] initWithTitle:title subTitle:subTitle targetView:view];
    
    if (tintColor) {
        notificationView.tintColor = tintColor;
    }
    
    [notificationView showAnimated:YES];
}

+(void)showWarningInView:(UIView *)view title:(NSString *)title subTitle:(NSString *)subTitle
{
    [self showInView:view title:title subTitle:subTitle tintColor:[self tintColorForType:DMRNotificationViewTypeWarning]];
}

+(void)showSuccessInView:(UIView *)view title:(NSString *)title subTitle:(NSString *)subTitle
{
    [self showInView:view title:title subTitle:subTitle tintColor:[self tintColorForType:DMRNotificationViewTypeSuccess]];
}




#pragma mark -
#pragma mark Drawing

-(void)drawRect:(CGRect)rect
{
    CGContextRef ref = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ref);
 
    // Tint color
    CGContextSetFillColorWithColor(ref, _tintColor.CGColor);
    CGContextSetShadowWithColor(ref, CGSizeMake(0.0, 1.0), kNotificationViewShadowOffset, [UIColor colorWithWhite:0.0 alpha:1.0].CGColor);
    CGContextFillRect(ref, CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height-kNotificationViewShadowOffset));
    
    CGContextRestoreGState(ref);
    
    UIColor *textColor = [self textColor];                  // Depends on fillColor
    BOOL textIncludesShadow = [self textIncludesShadow];    // Depends on fillColor
    CGFloat labelVerticalPosition = kNotificationViewVerticalInset;    
    
    // Title
    if (_title.length > 0) {
        [textColor set];
        CGSize titleSize = [self expectedTitleSize];
        
        if (textIncludesShadow)
            CGContextSetShadowWithColor(ref, CGSizeMake(0.0, -1.0), 0.0, [UIColor colorWithWhite:0.0 alpha:0.3].CGColor);
        
        [_title drawInRect:CGRectMake(10.0, labelVerticalPosition, _targetView.bounds.size.width-20.0, titleSize.height)
                  withFont:[self titleFont]
             lineBreakMode:NSLineBreakByWordWrapping
                 alignment:NSTextAlignmentCenter];
        
        labelVerticalPosition += titleSize.height+kNotificationViewLabelVerticalPadding;
    }
    
    // Subtitle
    if (_subTitle.length > 0) {
        [textColor set];
        CGSize subTitleSize = [self expectedSubTitleSize];
        
        if (textIncludesShadow)
            CGContextSetShadowWithColor(ref, CGSizeMake(0.0, -1.0), 0.0, [UIColor colorWithWhite:0.0 alpha:0.3].CGColor);
        
        [_subTitle drawInRect:CGRectMake((_targetView.bounds.size.width-subTitleSize.width)/2, labelVerticalPosition, _targetView.bounds.size.width-20.0, subTitleSize.height)
                  withFont:[self subTitleFont]
             lineBreakMode:NSLineBreakByWordWrapping];
    }
    
    // Lines
    CGContextSetAllowsAntialiasing(ref, false);
    CGContextSetLineWidth(ref, 1.0);

//    CGContextMoveToPoint(ref, CGRectGetMinX(rect), CGRectGetMaxY(rect)-(kNotificationViewShadowOffset+0.5));
//    CGContextAddLineToPoint(ref, CGRectGetMaxX(rect), CGRectGetMaxY(rect)-(kNotificationViewShadowOffset+0.5));
//    CGContextSetStrokeColorWithColor(ref, [UIColor colorWithWhite:1.0 alpha:0.5].CGColor);
//    CGContextStrokePath(ref);
}

- (void)performDelegateCallback:(SEL)selector animated:(BOOL)animated {
    NSObject * delegate = (NSObject *)self.delegate;
    if ([delegate respondsToSelector:selector]) {
        [delegate performSelectorOnMainThread:selector withObject:[NSNumber numberWithBool:animated] waitUntilDone:NO];
    }
}



#pragma mark -
#pragma mark Public

-(void)showAnimated:(BOOL)animated
{
    [self performDelegateCallback:@selector(notificationWillAppearAnimated:) animated:animated];
    
    CGSize expectedSize = [self expectedSize];
    [self setFrame:CGRectMake(0.0, 0.0, expectedSize.width, expectedSize.height)];
    
    CGPoint animateToCenter = self.center;
    [self setCenter:CGPointMake(self.center.x, self.center.y-self.bounds.size.height)];
    [_targetView addSubview:self];
    
    if (animated) {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self setCenter:animateToCenter];
        } completion:nil];
    } else {
        [self setCenter:animateToCenter];
    }
    
    if (_hideTimeInterval > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, _hideTimeInterval* NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self dismissAnimated:YES];
        });
    }
    
    [self performDelegateCallback:@selector(notificationDidAppearAnimated:) animated:animated];
}

-(void)dismissAnimated:(BOOL)animated
{
    [self performDelegateCallback:@selector(notificationWillDisppearAnimated:) animated:animated];
    
    if (animated) {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self setCenter:CGPointMake(self.center.x, -self.bounds.size.height)];
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    } else {
        [self removeFromSuperview];
    }
    
    [self performDelegateCallback:@selector(notificationDidDisappearAnimated:) animated:animated];
}





#pragma mark -
#pragma mark Setters

-(void)setTintColor:(UIColor *)tintColor
{
    if (tintColor == _tintColor) {
        return;
    }
    
    if ([tintColor isEqual:[UIColor clearColor]]) {
        [NSException raise:NSInvalidArgumentException format:@"Tint color cannot be [UIColor clearColor]"];
    }

    _tintColor = [self transparentTintColorFromColor:tintColor];
}

- (UIColor *)tintColor {
    if (!_tintColor) {
        _tintColor = kNotificationViewDefaultTintColor;
    }
    return _tintColor;
}

-(void)setTargetView:(UIView *)targetView
{
    if (_targetView == targetView) {
        return;
    }
    
    if (!targetView) {
        [NSException raise:NSInvalidArgumentException format:@"DMRNotificationView must have a targetView"];
    }
    
    _targetView = targetView;
}

-(void)setTitle:(NSString *)title
{
    if (_title == title) {
        return;
    }
    
    if (title.length == 0) {
        [NSException raise:NSInvalidArgumentException format:@"DMRNotificationView cannot have an empty title"];
    }
    
    _title = title;
}

-(void)setType:(DMRNotificationViewType)type
{
    if (_type == type) {
        return;
    }
    
    _type = type;
    
    [self setTintColor:[DMRNotificationView tintColorForType:type]];
}

-(void)setIsTransparent:(BOOL)transparent
{
    _transparent = transparent;
    
    UIColor *tintColor = _tintColor;
    _tintColor = nil;
    [self setTintColor:tintColor];
}



#pragma mark -
#pragma mark Getters

-(UIColor *)transparentTintColorFromColor:(UIColor *)color
{
    CGFloat opacity = (_transparent) ? kNotificationViewTintColorTransparency : 1.0;
    CGColorRef transparentColor = CGColorCreateCopyWithAlpha(color.CGColor, opacity);
    
    UIColor *newColor = [UIColor colorWithCGColor:transparentColor];
    CGColorRelease(transparentColor);
    
    return newColor;
}

-(UIColor *)textColor
{   
    CGFloat white = 0;
    [_tintColor getWhite:&white alpha:nil];
    return (white < 0.65) ? [UIColor whiteColor] : [UIColor colorWithRed:0.187 green:0.187 blue:0.187 alpha:1.000];
}

-(BOOL)textIncludesShadow
{
    CGFloat white = 0;
    [_tintColor getWhite:&white alpha:nil];
    return (white < 0.65);
}

-(CGSize)expectedSize
{
    CGFloat height = kNotificationViewVerticalInset;
    
    height += [self expectedTitleSize].height;
    
    if (_subTitle.length > 0) {
        height += [self expectedSubTitleSize].height + (2*kNotificationViewLabelVerticalPadding);
    }
    
    height += kNotificationViewVerticalInset+kNotificationViewShadowOffset;
    
    return CGSizeMake(_targetView.bounds.size.width, height);
}

-(CGSize)expectedTitleSize
{
    if (_title.length == 0) {
        return CGSizeZero;
    }
    
    return [_title sizeWithFont:[self titleFont]
              constrainedToSize:CGSizeMake(_targetView.bounds.size.width-20.0, 999.0)
                  lineBreakMode:NSLineBreakByWordWrapping];
}

-(CGSize)expectedSubTitleSize
{
    if (_subTitle.length == 0) {
        return CGSizeZero;
    }
    
    return [_subTitle sizeWithFont:[self subTitleFont]
                 constrainedToSize:CGSizeMake(_targetView.bounds.size.width-20.0, 999.0)
                     lineBreakMode:NSLineBreakByWordWrapping];
}

-(UIFont *)titleFont
{
    if (!_titleFont) {
        _titleFont = [UIFont boldSystemFontOfSize:18.0];
    }
    
    return _titleFont;
}

-(UIFont *)subTitleFont
{
    if (!_subTitleFont) {
        _subTitleFont = [UIFont systemFontOfSize:15.0];
        
    }

    return _subTitleFont;
}

+(UIColor *)tintColorForType:(DMRNotificationViewType)type
{
    switch (type) {
        case DMRNotificationViewTypeWarning:
            return [UIColor colorWithRed:0.725 green:0.000 blue:0.068 alpha:1.000];
            
        case DMRNotificationViewTypeSuccess:
            return [UIColor greenColor];
            
        default:
            return [UIColor colorWithRed:0.133 green:0.267 blue:0.533 alpha:1.000];
    }
}




#pragma mark -
#pragma mark UIView

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    if (CGRectContainsPoint(self.frame, touchLocation)) {
        [self performDelegateCallback:@selector(notificationDidTapAnimated:) animated:YES];

        if (self.didTapHandler) {
            self.didTapHandler();
            self.didTapHandler = nil;
        }
        
        [self dismissAnimated:YES];
    }
}
@end
