#import <UIKit/UIKit.h>
@class PlexSliderView;


@protocol PlexSliderViewDelegate <NSObject>
@required

- (void)slider:(PlexSliderView *)PlexSlider didSelectRow:(NSInteger)row;
- (NSInteger)numberOfRowsForSlider:(PlexSliderView *)PlexSlider;
- (NSString *)slider:(PlexSliderView *)PlexSlider titleForRow:(NSInteger)row;
@end  


@interface PlexSliderView : UIView<UIScrollViewDelegate> {
    id<PlexSliderViewDelegate> delegate;    
    UIColor *borderColor;
    CGFloat fontSize;
    NSInteger labelWidth;
    CGFloat distanceLabels;
    BOOL singleItemMode;
@private
    CGFloat scale; // Drawing scale    
    
}

@property (nonatomic, retain) UIColor *borderColor;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) BOOL singleItemMode;

@property (nonatomic, assign) CGFloat distanceBetweenLabels;
@property (nonatomic, assign) NSInteger labelWidth;
@property (nonatomic, assign) id<PlexSliderViewDelegate> delegate;

- (void)reloadAllData;
- (void) resetPosition;
- (void) setValue:(NSInteger) value;
@end



//================================
// STPointerLayerDelegate interface
//================================
@interface PlexSliderLayerDelegate : NSObject {}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context;

@end