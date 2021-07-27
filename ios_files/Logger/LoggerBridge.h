#import "LoggerBridge-C-Interface.h"
#import <Foundation/Foundation.h>

@protocol LoggerBridgeDelegate

-(void)log:(NSString *)string;

@end

@interface LoggerBridge : NSObject

@property(nonatomic, weak) id<LoggerBridgeDelegate> delegate;

+ (LoggerBridge *)shared;

- (void)log:(const char *) text;
- (NSString *)htmlString:(const char *) text;

@end
