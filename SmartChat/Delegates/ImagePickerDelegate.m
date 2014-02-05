#import "ImagePickerDelegate.h"

@implementation ImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"imagePickerController:%@ didFinishPickingMediaWithInfo:%@", picker, info);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"imagePickerControllerDidCancel:%@", picker);
}

@end
