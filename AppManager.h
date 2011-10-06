#import <Cocoa/Cocoa.h>

@interface AppManager: NSObject {
    IBOutlet NSMenu *statusMenu;
    NSStatusItem * statusItem;
    NSImage *statusImage;
    NSImage *statusHighlightImage;
}
- (void) hotkeyWithEvent:(NSEvent *)hkEvent;
- (void)postText:(NSString *)text;
- (void)openLinkInMenu:(NSEvent *)event;
@end
