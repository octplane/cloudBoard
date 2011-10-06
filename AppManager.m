#import "AppManager.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "DDHotKeyCenter.h"

@implementation AppManager

-(void)awakeFromNib{
    
    //Used to detect where our files are
    NSBundle *bundle = [NSBundle mainBundle];
    
    //Allocates and loads the images into the application which will be used for our NSStatusItem
    statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"cloudboard_normal" ofType:@"png"]];
    statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"cloudboard_selected" ofType:@"png"]];
    
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];

    [statusItem setImage:statusImage];
    [statusItem setAlternateImage:statusHighlightImage];
    [statusItem setMenu:statusMenu];
    [statusItem setHighlightMode:YES];
        
	DDHotKeyCenter * c = [[DDHotKeyCenter alloc] init];
	if (![c registerHotKeyWithKeyCode:9 modifierFlags:NSControlKeyMask target:self action:@selector(hotkeyWithEvent:) object:nil]) {
		NSLog(@"Unable to register hotkey.");
	} else {
        NSLog(@"Registered: %@", [c registeredHotKeys]);
	}
	[c release];
}

// Do something if the app becomes active
- (void) applicationWillBecomeActive:(NSNotification *)note{
 	//NSBeep();   
}

- (void) hotkeyWithEvent:(NSEvent *)hkEvent {
    NSPasteboard * pasteboard = [NSPasteboard generalPasteboard];
    NSArray *classArray = [NSArray arrayWithObject:[NSString class]];
    NSDictionary *options = [NSDictionary dictionary];
    
    BOOL ok = [pasteboard canReadObjectForClasses:classArray options:options];
    if(ok)
    {
        NSArray *objectsToPaste = [pasteboard readObjectsForClasses:classArray options:options];
        NSString *text = [objectsToPaste objectAtIndex:0];
        
        [self postText: text];
    }
}

- (void)openLinkInMenu:(NSEvent *)event {
    NSString * stringUrl = [[statusMenu highlightedItem] title];
    NSURL* url = [NSURL URLWithString: stringUrl];
    [[NSWorkspace sharedWorkspace] openURL: url];
}

- (void)postText:(NSString *)text {
    // API Basepoint
    NSURL *url = [NSURL URLWithString:@"http://dpaste.com/api/v1/"];
    
    // POST-Content urlencoden
    // @see http://simonwoodside.com/weblog/2009/4/22/how_to_really_url_encode/
    NSString* encodedString = (NSString * )CFURLCreateStringByAddingPercentEscapes(
                                                                                   NULL,
                                                                                   (CFStringRef) text,
                                                                                   NULL,
                                                                                   (CFStringRef) @"!*'();:@&=+$,/?%#[]",
                                                                                   kCFStringEncodingUTF8
                                                                                   );
    
    // Post content aufbauen
    NSString* postContent = @"content=";
    postContent = [postContent stringByAppendingString: encodedString];
    [encodedString release];
    
    // Request aufbauen und senden
    ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
    [request addRequestHeader:@"User-Agent" value:@"dpasteGUI"];
    [request setAllowCompressedResponse: (BOOL) YES];    
    [request setPostBody: [postContent dataUsingEncoding:NSUTF8StringEncoding]];
    [request setShouldRedirect: (BOOL) NO];
    [request start];
    
    // Response
    NSError *error = [request error];        
    if (!error) {
        // Url aus dem response auslesen und Anführungszeichen entfernen (piston bug?)
        NSString *response = [[request responseHeaders] objectForKey:@"Location"];
        
        // Paste in clipboard
        NSPasteboard * pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard clearContents];
        if([statusMenu numberOfItems] > 10)
        {
            // Just before the last item
            [statusMenu removeItemAtIndex:8];
        }       
        [[statusMenu insertItemWithTitle:response action:@selector(openLinkInMenu:) keyEquivalent:@"" atIndex:0] setTarget:self];
        
        NSArray *objectsToCopy = [[NSArray alloc] initWithObjects: response, nil];
        [pasteboard writeObjects:objectsToCopy];
        NSBeep();
        [statusItem setImage:statusHighlightImage];
        usleep(1000000);
        [statusItem setImage:statusImage];
        
    }
    
    
}

@end
