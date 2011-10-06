#import "AppManager.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "DDHotKeyCenter.h"

@implementation AppManager

-(void)awakeFromNib{
    
    [window center];
    [window setReleasedWhenClosed:NO];
    
    NSLog(@"Registering hotkey");
    
	DDHotKeyCenter * c = [[DDHotKeyCenter alloc] init];
	if (![c registerHotKeyWithKeyCode:9 modifierFlags:NSControlKeyMask target:self action:@selector(hotkeyWithEvent:) object:nil]) {
		NSLog(@"Unable to register hotkey.");
	} else {
        NSLog(@"Registered: %@", [c registeredHotKeys]);
	}
	[c release];
}

// Redisplay the window after close and click on the dock icon
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    [window makeKeyAndOrderFront: (id) theApplication];
    return flag;
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
        [progressDings setHidden: (BOOL) NO];
        [progressDings startAnimation: (NSButton *)clickOpenButton];
        
        [self postText: text];
        
        // Hide indicator
        [progressDings stopAnimation: (NSButton*) clickOpenButton];
        [progressDings setHidden: (BOOL) YES];        
        
    }
}

- (IBAction)clickOpen:(NSButton*)sender {
    // Öffnet den Webbrowser mit der URL aus dem Textfeld
    NSURL* url = [NSURL URLWithString: [urlLabel stringValue]];
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
        [urlLabel setStringValue:response];
        [urlLabel selectText: (id) clickOpenButton];
        // Open Button aktivieren
        [clickOpenButton setEnabled: (BOOL) YES];
        
        // Paste in clipboard
        NSPasteboard * pasteboard = [NSPasteboard generalPasteboard];
        [pasteboard clearContents];
        NSArray *objectsToCopy = [[NSArray alloc] initWithObjects: response, nil];
        [pasteboard writeObjects:objectsToCopy];
        NSBeep();
    }else{
        [urlLabel setStringValue: @"Request/Response Error with the API"];
    }
    
    
}
@end
