#import "PlexSliderView.h"
#import <QuartzCore/QuartzCore.h>


const float DISTANCE_BETWEEN_ITEMS = 100.0;
const int TEXT_LAYER_WIDTH = 80;
const float FONT_SIZE = 14.0f;
const float POINTER_WIDTH = 10.0f;
const float POINTER_HEIGHT = 7.0f;

//================================
// UIColor category 
//================================
@interface UIColor (PlexSliderColorComponents)
- (CGFloat)red;
- (CGFloat)green;
- (CGFloat)blue;
- (CGFloat)alpha;
@end


//================================
// UIColor category
//================================
@implementation UIColor (PlexSliderColorComponents)

- (CGColorSpaceModel)colorSpaceModel {
    return CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
}

- (CGFloat)red {
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    return c[0];
}

- (CGFloat)green {
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    if (self.colorSpaceModel == kCGColorSpaceModelMonochrome) return c[0];
    return c[1];
}

- (CGFloat)blue {
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    if (self.colorSpaceModel == kCGColorSpaceModelMonochrome) return c[0];
    return c[2];
}

- (CGFloat)alpha {
    return CGColorGetAlpha(self.CGColor);
}

@end



@interface PlexSliderView ()

// Private properties

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIView *scrollViewMarkerContainerView;
@property (nonatomic, retain) NSMutableArray *scrollViewMarkerLayerArray;
@property (nonatomic, retain) CALayer *pointerLayer;

- (void)setupMarkers;
- (void)snapToMarkerAnimated:(BOOL)animated;
- (void)callDelegateWithNew:(CGFloat)offset;
@end;


@implementation PlexSliderView
@synthesize distanceBetweenLabels;
@synthesize labelWidth;
@synthesize delegate;
@synthesize borderColor;
@synthesize fontSize;
@synthesize scrollView;
@synthesize scrollViewMarkerContainerView;
@synthesize scrollViewMarkerLayerArray;
@synthesize pointerLayer;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        scale = [[UIScreen mainScreen] scale];
        
        if ([self respondsToSelector:@selector(setContentScaleFactor:)]) {
            self.contentScaleFactor = scale;
        }
        labelWidth = TEXT_LAYER_WIDTH;
        distanceBetweenLabels = DISTANCE_BETWEEN_ITEMS;
        
        // Ensures that the corners are transparent
        self.backgroundColor = [UIColor clearColor];
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height)];
        self.scrollView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;        
        self.scrollView.pagingEnabled = NO;
        self.scrollView.delegate = self;
        
        self.scrollViewMarkerContainerView = [[UIView alloc] init];
        self.scrollViewMarkerLayerArray = [[NSMutableArray alloc] init];
        
        
        fontSize = FONT_SIZE;
        
        [self.scrollView addSubview:self.scrollViewMarkerContainerView];        
        [self addSubview:self.scrollView];
        [self snapToMarkerAnimated:NO];
        
        CAGradientLayer *dropshadowLayer = [CAGradientLayer layer];
        dropshadowLayer.contentsScale = scale;
        dropshadowLayer.cornerRadius = 8.0f;
        dropshadowLayer.startPoint = CGPointMake(0.0f, 0.0f);
        dropshadowLayer.endPoint = CGPointMake(0.0f, 1.0f);
        dropshadowLayer.opacity = 1.0;
        dropshadowLayer.frame = CGRectMake(1.0f, 1.0f, self.frame.size.width - 2.0, self.frame.size.height - 2.0);
        dropshadowLayer.locations = [NSArray arrayWithObjects:
                                     [NSNumber numberWithFloat:0.0f],
                                     [NSNumber numberWithFloat:0.05f],
                                     [NSNumber numberWithFloat:0.2f],
                                     [NSNumber numberWithFloat:0.8f],
                                     [NSNumber numberWithFloat:0.95f],                                   
                                     [NSNumber numberWithFloat:1.0f], nil];
        dropshadowLayer.colors = [NSArray arrayWithObjects:
                                  (id)[[UIColor colorWithRed:0.05f green:0.05f blue:0.05f alpha:0.75] CGColor], 
                                  (id)[[UIColor colorWithRed:0.25f green:0.25f blue:0.25f alpha:0.55] CGColor], 
                                  (id)[[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.05] CGColor], 
                                  (id)[[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.05] CGColor], 
                                  (id)[[UIColor colorWithRed:0.25f green:0.25f blue:0.25f alpha:0.55] CGColor],
                                  (id)[[UIColor colorWithRed:0.05f green:0.05f blue:0.05f alpha:0.75] CGColor], nil];
        
        [self.layer insertSublayer:dropshadowLayer above:self.scrollView.layer];
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.contentsScale = scale;
        gradientLayer.cornerRadius = 8.0f;
        gradientLayer.startPoint = CGPointMake(0.0f, 0.0f);
        gradientLayer.endPoint = CGPointMake(1.0f, 0.0f);
        gradientLayer.opacity = 1.0;
        gradientLayer.frame = CGRectMake(1.0f, 1.0f, self.frame.size.width - 2.0, self.frame.size.height - 2.0);
        gradientLayer.locations = [NSArray arrayWithObjects:
                                   [NSNumber numberWithFloat:0.0f],
                                   [NSNumber numberWithFloat:0.05f],
                                   [NSNumber numberWithFloat:0.3f],
                                   [NSNumber numberWithFloat:0.7f],
                                   [NSNumber numberWithFloat:0.95f],                                   
                                   [NSNumber numberWithFloat:1.0f], nil];
        gradientLayer.colors = [NSArray arrayWithObjects:
                                (id)[[UIColor colorWithRed:0.05f green:0.05f blue:0.05f alpha:0.95] CGColor], 
                                (id)[[UIColor colorWithRed:0.25f green:0.25f blue:0.25f alpha:0.8] CGColor], 
                                (id)[[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.1] CGColor], 
                                (id)[[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.1] CGColor], 
                                (id)[[UIColor colorWithRed:0.25f green:0.25f blue:0.25f alpha:0.8] CGColor],
                                (id)[[UIColor colorWithRed:0.05f green:0.05f blue:0.05f alpha:0.95] CGColor], nil];
        [self.layer insertSublayer:gradientLayer above:dropshadowLayer];
        
        self.pointerLayer = [CALayer layer];
        [self.pointerLayer setValue:[NSNumber numberWithFloat:[borderColor red]] forKey:@"borderRed"];
        [self.pointerLayer setValue:[NSNumber numberWithFloat:[borderColor green]] forKey:@"borderGreen"];
        [self.pointerLayer setValue:[NSNumber numberWithFloat:[borderColor blue]] forKey:@"borderBlue"];
        [self.pointerLayer setValue:[NSNumber numberWithFloat:[borderColor alpha]] forKey:@"borderAlpha"];        
        self.pointerLayer.opacity = 1.0;
        self.pointerLayer.contentsScale = scale;
        self.pointerLayer.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
        self.pointerLayer.delegate = [[PlexSliderLayerDelegate alloc] init];
        [self.layer insertSublayer:self.pointerLayer above:gradientLayer];
        [self.pointerLayer setNeedsDisplay];
        self.scrollView.layer.cornerRadius = 8.0f;
        self.scrollView.layer.borderWidth = 1.0f;
        self.scrollView.layer.borderColor = borderColor.CGColor ? borderColor.CGColor : [UIColor grayColor].CGColor;
        
        [self setupMarkers];
    }
    return self;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self snapToMarkerAnimated:YES];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(slider:didSelectRow:)]) {
        [self callDelegateWithNew:[self.scrollView contentOffset].x];
    }
}




- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self snapToMarkerAnimated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(slider:didSelectRow:)]) {
        [self callDelegateWithNew:[self.scrollView contentOffset].x];
    }    
}

- (void)callDelegateWithNew:(CGFloat)offset {
    CGFloat itemWidth = distanceBetweenLabels;
    
    CGFloat offSet = offset / itemWidth;
    NSUInteger target = (NSUInteger)(offSet + 0.35f);
    int steps = [delegate numberOfRowsForSlider:self];
    target = target >= steps ? steps - 1: target;
    [delegate slider:self didSelectRow:target];
}

- (void)snapToMarkerAnimated:(BOOL)animated {
    CGFloat itemWidth = distanceBetweenLabels;
    CGFloat position = [self.scrollView contentOffset].x;
    int steps = [delegate numberOfRowsForSlider:self];
    
    if (position < self.scrollViewMarkerContainerView.frame.size.width - self.frame.size.width / 2) {
        CGFloat newPosition = 0.0f;
        CGFloat offSet = position / itemWidth;
        NSUInteger target = (NSUInteger)(offSet + 0.35f);
        target = target >= steps ? steps -1 : target;
        newPosition = target * itemWidth + labelWidth / 2;
        [self.scrollView setContentOffset:CGPointMake(newPosition, 0.0f) animated:animated];
    }
}

- (void)removeAllMarkers {
    for (id marker in self.scrollViewMarkerLayerArray) {
        [(CATextLayer *)marker removeFromSuperlayer];
    }
    [self.scrollViewMarkerLayerArray removeAllObjects];
}

- (void)setupMarkers {
    [self removeAllMarkers];    
    // Calculate the new size of the content
    float leftPadding = self.frame.size.width / 2;
    float rightPadding = leftPadding/2;
    int steps = [delegate numberOfRowsForSlider:self];
    
    float contentWidth = leftPadding + (steps * distanceBetweenLabels) + rightPadding;
    self.scrollView.contentSize = CGSizeMake(contentWidth, self.frame.size.height);
    
    // Set the size of the marker container view
    [self.scrollViewMarkerContainerView setFrame:CGRectMake(0.0f, 0.0f, contentWidth, self.frame.size.height)];
    
    // Configure the new markers
    for (int i = 0; i < steps; i++) {
        CATextLayer *textLayer = [CATextLayer layer];
        textLayer.contentsScale = scale;
        textLayer.frame = CGRectIntegral(CGRectMake(leftPadding + i*distanceBetweenLabels, self.frame.size.height / 2 - fontSize / 2 + 1, labelWidth, 40));
        //NSLog(@"Adding text %d for %f, total steps %d", i, textLayer.frame.origin.x, steps);
        textLayer.foregroundColor = [UIColor blackColor].CGColor;
        textLayer.alignmentMode = kCAAlignmentCenter;
        textLayer.fontSize = fontSize;
        
        textLayer.string = [delegate slider:self titleForRow:i];
        [self.scrollViewMarkerLayerArray addObject:textLayer];
        [self.scrollViewMarkerContainerView.layer addSublayer:textLayer];
    }
}



- (void)reloadAllData {
    [self setupMarkers];
}

- (UIColor *)borderColor {
    return borderColor;
}

- (void)setBorderColor:(UIColor *)newBorderColor {
    if (newBorderColor != borderColor)
    {
        [newBorderColor retain];
        [borderColor release];
        borderColor = newBorderColor;
        
        [self.pointerLayer setValue:[NSNumber numberWithFloat:[borderColor red]] forKey:@"borderRed"];
        [self.pointerLayer setValue:[NSNumber numberWithFloat:[borderColor green]] forKey:@"borderGreen"];
        [self.pointerLayer setValue:[NSNumber numberWithFloat:[borderColor blue]] forKey:@"borderBlue"];
        [self.pointerLayer setValue:[NSNumber numberWithFloat:[borderColor alpha]] forKey:@"borderAlpha"];
        [self.pointerLayer setNeedsDisplay];
        
        self.scrollView.layer.borderColor = borderColor.CGColor;
    }
}

- (void)setFontSize:(CGFloat)newFontSize {
    fontSize = newFontSize;
    [self setupMarkers];
}

- (void)setupValue:(CGFloat)newValue {    
    CGFloat itemWidth = distanceBetweenLabels;
    CGFloat xValue = newValue * itemWidth + labelWidth / 2;
    [self.scrollView setContentOffset:CGPointMake(xValue, 0.0f) animated:NO];
}




- (void)dealloc {
    [borderColor release];
    [super dealloc];
}


@end


@implementation PlexSliderLayerDelegate

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
    CGContextSaveGState(context);
    
    CGContextSetLineWidth(context, 2.0);
	CGContextSetRGBStrokeColor(context, [[layer valueForKey:@"borderRed"] floatValue], [[layer valueForKey:@"borderGreen"] floatValue], [[layer valueForKey:@"borderBlue"] floatValue], [[layer valueForKey:@"borderAlpha"] floatValue]);
    CGContextSetRGBFillColor(context, [[layer valueForKey:@"borderRed"] floatValue], [[layer valueForKey:@"borderGreen"] floatValue], [[layer valueForKey:@"borderBlue"] floatValue], [[layer valueForKey:@"borderAlpha"] floatValue]);
    
    CGContextSetShadowWithColor(context, CGSizeMake(0, 2), 3.0, [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3].CGColor);
    
    CGContextMoveToPoint(context, layer.frame.size.width / 2 - POINTER_WIDTH / 2, 0);
    CGContextAddLineToPoint(context, layer.frame.size.width / 2, POINTER_HEIGHT);
    CGContextAddLineToPoint(context, layer.frame.size.width / 2 + POINTER_WIDTH / 2, 0);    
    CGContextFillPath(context);
    CGContextStrokePath(context);
    
    CGContextSetShadowWithColor(context, CGSizeMake(0, -2), 3.0, [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3].CGColor);
    
    CGContextMoveToPoint(context, layer.frame.size.width / 2 - POINTER_WIDTH / 2, layer.frame.size.height);
    CGContextAddLineToPoint(context, layer.frame.size.width / 2, layer.frame.size.height - POINTER_HEIGHT);
    CGContextAddLineToPoint(context, layer.frame.size.width / 2 + POINTER_WIDTH / 2, layer.frame.size.height);    
    CGContextFillPath(context);
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
}


@end
