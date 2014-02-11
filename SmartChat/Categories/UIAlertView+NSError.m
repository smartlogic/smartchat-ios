#import "UIAlertView+NSError.h"

@implementation UIAlertView (NSError)

+ (UIAlertView *)alertViewWithError:(NSError *)error
{
    return [[UIAlertView alloc] initWithTitle:error.localizedDescription
                                      message:error.localizedRecoverySuggestion
                                     delegate:nil
                            cancelButtonTitle:NSLocalizedString(@"OK", nil)
                            otherButtonTitles:nil, nil];
}


@end
