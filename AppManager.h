#import <Cocoa/Cocoa.h>

@interface AppManager: NSObject {
    IBOutlet NSProgressIndicator* progressDings;
    IBOutlet NSTextField* urlLabel;
    IBOutlet NSButton* clickOpenButton;
    IBOutlet NSWindow* window;
}
- (IBAction)clickOpen:(NSButton*)sender;
- (void) hotkeyWithEvent:(NSEvent *)hkEvent;
- (void)postText:(NSString *)text;
@end
