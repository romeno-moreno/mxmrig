#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface XmrigManager : NSObject

+ (XmrigManager *)shared;
- (void)startMining;

- (BOOL)isMining;

- (void)pause;
- (void)resume;

- (void)showHashrate;
- (void)showResults;
- (void)showConnection;

@end

NS_ASSUME_NONNULL_END
