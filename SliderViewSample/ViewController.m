#import "ViewController.h"

@implementation ViewController
@synthesize slider;


- (void)viewDidLoad
{
    [super viewDidLoad];
    slider = [[PlexSliderView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    slider.delegate = self;
    [slider reloadAllData];
    [self.view addSubview:slider];
}


- (void)slider:(PlexSliderView *)slider didSelectRow:(NSInteger)row {
    NSLog(@"Selected %d", row);
    
}


- (NSInteger)numberOfRowsForSlider:(PlexSliderView *)slider {
    return 10;
}

- (NSString *)slider:(PlexSliderView *)slider titleForRow:(NSInteger)row {
    switch (row) {
        case 0:
            return @"Zero 000";
        case 1:
            return @"One 111";
        case 2:
            return @"Two 222";
        case 3:
            return @"Three 333";
        case 4:
            return @"Four 444";
        case 5:
            return @"Five 555";
        case 6:
            return @"Six 666";
        case 7:
            return @"Seven 777";
        case 8:
            return @"Eight 888";
        case 9:
            return @"Nine 999";
        default:
            return @"Null --";
    }
}



-(void)dealloc {
    [slider release];
    [super dealloc];
}
@end
