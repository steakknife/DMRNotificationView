//
//  DMRNotificationView.m
//  notificationview
//
//  Created by Damir Tursunovic on 1/23/13.
//  Copyright (c) 2013 Damir Tursunovic (damir.me). All rights reserved.
//

#import "DMRNotificationView.h"

static const CGFloat kButtonCornerRadius = 3.0;
static const CGFloat kColorAdjustmentDark = -0.15;
static const CGFloat kColorAdjustmentLight = 0.35;

static const CGFloat kButtonOriginXOffset = 75;
static const CGFloat kButtonWidthDefault = 64;
static const CGFloat kButtonPadding = 2.5;

static const CGFloat minValue = 0.0;
static const CGFloat maxValue = 1.0;

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)


// Change these values to match your needs...
static CGFloat kNotificationViewTintColorTransparency = 0.80;           // Default tint color transparency
static NSTimeInterval kNotificationViewDefaultHideTimeInterval = 4.5;   // Number of seconds until auto dismiss
static CGFloat kNotificationViewVerticalInset = 10.0;                   // Top and bottom inset
static CGFloat kNotificationViewLabelVerticalPadding = 5.0;             // Distance between title and subtitle
static CGFloat kNotificationViewShadowOffset = 5.0;                     // Shadow offset
static UIColor *kNotificationViewDefaultTintColor;                      // Default tint color
static UIColor *kNotificationViewDefaultBackgroundColor;                // Default background color

@interface DMRNotificationView ()
@property (nonatomic) BOOL buttonsAdded;
@end

@implementation DMRNotificationView
@synthesize delegate = _delegate;
@synthesize tintColor = _tintColor;
@synthesize buttons = _buttons;
@synthesize buttonTitles = _buttonTitles;

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
        self.tapShouldDismiss = YES;
        self.tapFirstButtonShouldDismiss = YES;
        self.tapSecondButtonShouldDismiss = YES;
        self.didTapHandlerOnlyOnce = YES;
    }
    return self;
}

- (NSString *)firstButtonTitle {
    if (self.buttonTitles.count == 0) {
        return nil;
    }
    return self.buttonTitles[0];
}

- (NSString *)secondButtonTitle {
    if (self.buttonTitles.count < 2) {
        return nil;
    }
    return self.buttonTitles[1];
}

- (void)setFirstButtonTitle:(NSString *)firstButtonTitle {
    switch (self.buttonTitles.count) {
        case 0:
        case 1:
            {
                self.buttonTitles = @[firstButtonTitle];
            }
            break;
            
        case 2:
            {
                self.buttonTitles = @[firstButtonTitle, self.buttonTitles[1]];
            }
            break;
    }
    
}

- (void)setSecondButtonTitle:(NSString *)secondButtonTitle {
    switch (self.buttonTitles.count) {
        case 0:
            [NSException raise:@"" format:@"Cannot add a second button title until first button title is added"];
            break;
            
        case 1:
        case 2:
            {
                self.buttonTitles = @[self.buttonTitles[0], secondButtonTitle];
            }
            break;
    }
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

- (BOOL)hasButtons {
    return self.firstButtonTitle;
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
    
    const CGFloat buttonWidth = (self.hasButtons) ? ((UIView *)self.buttons[0]).frame.size.width + kButtonPadding*2 : 0;
    
    // Title
    if (_title.length > 0) {
        [textColor set];
        CGSize titleSize = [self expectedTitleSize];
        
        if (textIncludesShadow)
            CGContextSetShadowWithColor(ref, CGSizeMake(0.0, -1.0), 0.0, [UIColor colorWithWhite:0.0 alpha:0.3].CGColor);
        
        CGRect titleRect = CGRectMake(10.0, labelVerticalPosition, _targetView.bounds.size.width-20.0-buttonWidth, titleSize.height);
        
        [_title drawInRect:titleRect
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
        
        CGRect subTitleRect = CGRectMake((_targetView.bounds.size.width-subTitleSize.width)/2, labelVerticalPosition, _targetView.bounds.size.width-20.0-buttonWidth, subTitleSize.height);


        [_subTitle drawInRect:subTitleRect
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
    
    [super drawRect:rect];
}

- (void)performDelegateCallback:(SEL)selector {
    NSObject * delegate = (NSObject *)self.delegate;
    if ([delegate respondsToSelector:selector]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            SuppressPerformSelectorLeakWarning([delegate performSelector:selector
                           withObject:self]);
        });
    }
}

- (void)performDelegateCallback:(SEL)selector
                    buttonIndex:(NSInteger)buttonIndex{
    NSObject * delegate = (NSObject *)self.delegate;
    if ([delegate respondsToSelector:selector]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            SuppressPerformSelectorLeakWarning([delegate performSelector:selector
                           withObject:self
                           withObject:@(buttonIndex)]);
        });
    }
}

- (void)performDelegateCallback:(SEL)selector
                       animated:(BOOL)animated {
    NSObject * delegate = (NSObject *)self.delegate;
    if ([delegate respondsToSelector:selector]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            SuppressPerformSelectorLeakWarning([delegate performSelector:selector
                           withObject:self
                           withObject:@(animated)]);
        });
    }
}


#pragma mark -
#pragma mark Private

- (void)buttonTapped:(id)sender {
    NSInteger buttonIndex = ((UIButton *)sender).tag;
    NSLog(@"DMRNotificationView buttonTapped: button%ld pressed", (long)buttonIndex);
    [self performDelegateCallback:@selector(notificationDidTapButton::)
                      buttonIndex:buttonIndex];
    
    switch (buttonIndex) {
        case 0:
            if (self.firstButtonHandler) {
                dispatch_async(dispatch_get_main_queue(), self.firstButtonHandler);
            }
            if (self.tapFirstButtonShouldDismiss) {
                [self dismissAnimated:YES];
            }
            break;
            
        case 1:
            if (self.secondButtonHandler) {
                dispatch_async(dispatch_get_main_queue(), self.secondButtonHandler);
            }
            if (self.tapSecondButtonShouldDismiss) {
                [self dismissAnimated:YES];
            }
            break;
            
        default:
            NSLog(@"DMRNotificationView buttonTapped: Unknown button index: %ld", (long)buttonIndex);
    }
}

#pragma mark -
#pragma mark Public




- (UIColor *)darkerColorForColor:(UIColor *)color
{
    CGFloat r,g,b,a;
    if ([color getRed:&r green:&g blue:&b alpha:&a]) {
        return [UIColor colorWithRed:MAX(r + kColorAdjustmentDark, minValue)
                               green:MAX(g + kColorAdjustmentDark, minValue)
                                blue:MAX(b + kColorAdjustmentDark, minValue)
                               alpha:a];
    } else {
        return nil;
    }
}

- (UIColor *)lighterColorForColor:(UIColor *)color
{
    CGFloat r, g, b, a;
    if ([color getRed:&r green:&g blue:&b alpha:&a]){
        return [UIColor colorWithRed:MIN(r + kColorAdjustmentLight, maxValue)
                               green:MIN(g + kColorAdjustmentLight, maxValue)
                                blue:MIN(b + kColorAdjustmentLight, maxValue)
                               alpha:a];
    } else {
        return nil;
    }
    
}

- (NSArray *)buttons {
    if (!_buttons) {
        NSLog(@"buttons ctor: %@", self.buttonTitles);
        NSMutableArray *buttons = [[NSMutableArray alloc] init];
        int tag = 0;
        for (NSString *buttonTitle in self.buttonTitles) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
           // button.titleLabel.text = buttonTitle;
           // button.titleLabel.textColor = UIColor.redColor;
            button.tintColor = UIColor.redColor;
            [button setTitle:buttonTitle forState:UIControlStateNormal];
            //button.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];
            
            [button setBackgroundColor:[self darkerColorForColor:self.backgroundColor]];
            button.layer.cornerRadius = kButtonCornerRadius;
            
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
            
            button.tag = tag++;
            [button addTarget:self
                       action:@selector(buttonTapped:)
             forControlEvents:UIControlEventTouchUpInside];
            [buttons addObject:button];
        }
        _buttons = buttons;
        _buttonsAdded = NO;
    }
    return _buttons;
}

- (void)setButtonTitles:(NSArray *)buttonTitles {
    if (_buttonTitles == buttonTitles) {
        NSLog(@"nothing to do, _buttonTitles; %@, buttonTitles: %@", _buttonTitles, buttonTitles);
        return;
    }
    if (buttonTitles.count > 2) {
        [NSException raise:@"" format:@"cannot add more than 2 buttons"];
    }
    NSLog(@"set button titles to: %@", buttonTitles);
    self.buttons = nil;
    _buttonTitles = buttonTitles;
}

-(void)setButtons:(NSArray *)buttons {
    if (_buttons == buttons) {
        return;
    }
    if (_buttonsAdded) {
        for (UIButton *button in _buttons) {
            [button removeFromSuperview];
        }
        _buttonsAdded = NO;
    }
    _buttons = buttons;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat notificationWidth = CGRectGetWidth(self.bounds);
    NSLog(@"notificationWidth: %@", NSStringFromCGRect(self.bounds));
    
    UIButton *firstButton = (self.buttons.count > 0) ? self.buttons[0] : nil;
    UIButton *secondButton = (self.buttons.count == 2) ? self.buttons[1] : nil;
    CGFloat buttonOriginX = notificationWidth - kButtonOriginXOffset;
    
    CGFloat firstButtonOriginY = (secondButton) ? 6 : 17;
    CGFloat buttonHeight = (firstButton && secondButton) ? 25 : 30;
    CGFloat secondButtonOriginY = firstButtonOriginY + buttonHeight + kButtonPadding;
    
    firstButton.frame = CGRectMake(buttonOriginX, firstButtonOriginY, kButtonWidthDefault, buttonHeight);
    secondButton.frame = CGRectMake(buttonOriginX, secondButtonOriginY, kButtonWidthDefault, buttonHeight);
    NSLog(@"firstButton; %@ (frame %@)", firstButton, NSStringFromCGRect(firstButton.frame));
    NSLog(@"secondButton; %@ (frame %@)", secondButton, NSStringFromCGRect(secondButton.frame));
}


- (void)addAndLayoutButtons {
    if (_buttonsAdded) {
        return;
    }
    
    UIButton *firstButton = (self.buttons.count > 0) ? self.buttons[0] : nil;
    UIButton *secondButton = (self.buttons.count == 2) ? self.buttons[1] : nil;
    
    [self addSubview:firstButton];
    [self addSubview:secondButton];
    
    _buttonsAdded = YES;
}

-(void)showAnimated:(BOOL)animated
{
    [self performDelegateCallback:@selector(notificationWillAppearAnimated:) animated:animated];
 
    [self addAndLayoutButtons];
    [self setNeedsLayout];
    
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
    
    [self performDelegateCallback:@selector(notificationDidAppear::) animated:animated];
}

-(void)dismissAnimated:(BOOL)animated
{
    [self performDelegateCallback:@selector(notificationWillDisappear::) animated:animated];
    
    if (animated) {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self setCenter:CGPointMake(self.center.x, -self.bounds.size.height)];
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    } else {
        [self removeFromSuperview];
    }
    
    [self performDelegateCallback:@selector(notificationDidDisappear::) animated:animated];
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
        [self performDelegateCallback:@selector(notificationDidTap:)];

        if (self.didTapHandler) {
            self.didTapHandler();
            if (self.didTapHandlerOnlyOnce) {
              self.didTapHandler = nil;
            }
        }
        
        if (self.tapShouldDismiss) {
            [self dismissAnimated:YES];
        }
    }
}
@end
