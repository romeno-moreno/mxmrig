#ifndef __LOGGERBRIDGE_C_INTERFACE_H__
#define __LOGGERBRIDGE_C_INTERFACE_H__

// This is the C "trampoline" function that will be used
// to invoke a specific Objective-C method FROM C++
void LoggerBridgeLog (const char *parameter);

int DonationBridgeLog ();
const char* GetDefaultDeviceName ();
#endif
