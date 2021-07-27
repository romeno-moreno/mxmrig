#import "XmrigManager.h"
#import <AVFoundation/AVFoundation.h>
#import "Logger/LoggerBridge.h"
#import <xmrig-Swift.h>

#include "App.h"
#include "base/kernel/Entry.h"
#include "base/kernel/Process.h"


@implementation XmrigManager {
    xmrig::App *currentApp;
}

+ (XmrigManager *)shared {
    static XmrigManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

-(void) startMining {
    //[AudioPlayer.shared playSound];
    using namespace xmrig;
    [ConfigManager renameDeviceToActual];
    NSArray<NSString *> * array = [[NSProcessInfo processInfo] arguments];
   //NSString *deviceNameParam = [[@"--pass=\"" stringByAppendingString:[ConfigManager deviceName]] stringByAppendingString:@"\""];
    array = [array arrayByAddingObject:[NSString stringWithFormat:  @"--config=%@", [ConfigManager getFullConfigPath].path]];
    //array = [array arrayByAddingObject: @"-t"];
    //array = [array arrayByAddingObject: @"8"];
    
    int count = [array count];
    char **cargs = (char **) malloc(sizeof(char *) * (count + 1));
    //cargs is a pointer to 4 pointers to char

    int i;
    for(i = 0; i < count; i++) {
        NSString *s = [array objectAtIndex:i];//get a NSString
        const char *cstr = [s cStringUsingEncoding:NSUTF8StringEncoding];//get cstring
        int len = strlen(cstr);//get its length
        char *cstr_copy = (char *) malloc(sizeof(char) * (len + 1));//allocate memory, + 1 for ending '\0'
        strcpy(cstr_copy, cstr);//make a copy
        cargs[i] = cstr_copy;//put the point in cargs
    }
    cargs[i] = NULL;
    
    
    Process process(count, cargs);
    const Entry::Id entry = Entry::get(process);
    if (entry) {
        Entry::exec(process, entry);
        return;
    }

    App app(&process);
    currentApp = &app;
    app.exec();
}

- (BOOL)isMining {
    return currentApp != NULL;
}

-(void) showHashrate {
    currentApp->onConsoleCommand('h');
}

- (void)showResults {
    currentApp->onConsoleCommand('s');
}

- (void)showConnection {
    currentApp->onConsoleCommand('c');
}

- (void)pause {
    currentApp->onConsoleCommand('p');
}

- (void)resume {
    currentApp->onConsoleCommand('r');
}

@end
