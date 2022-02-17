#import "LoggerBridge.h"
#import <AVFoundation/AVFoundation.h>
#import "../ansi2html/ansi_esc2html.h"
#import <xmrig_notls-Swift.h>

@implementation LoggerBridge

+ (LoggerBridge *)shared {
    static LoggerBridge *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

// C "trampoline" function to invoke Objective-C method
void LoggerBridgeLog (const char *param)
{
    [LoggerBridge.shared log: param];
}

- (void)log: (const char *) text
{
    [_delegate log: [self htmlString:text]];
}

- (NSString *)htmlString:(const char *) text
{
    ANSI_SGR2HTML ansisgr2html;
    std::string stdstr(text);
    std::string html = ansisgr2html.strictParse(stdstr);
    
    NSString *str = [NSString stringWithUTF8String: html.c_str()];
    return str;
}

int DonationBridgeLog ()
{
    return (int)ConfigValues.donation;
}

const char* GetDefaultDeviceName () {
    return [ConfigValues.defaultDeviceName cStringUsingEncoding:NSUTF8StringEncoding];
}

@end
