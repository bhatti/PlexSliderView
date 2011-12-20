#import <UIKit/UIKit.h>
#import "PlexSliderView.h"

@interface ViewController : UIViewController<PlexSliderViewDelegate> {
    PlexSliderView *slider;
}

@property(nonatomic, retain) PlexSliderView *slider;

@end


