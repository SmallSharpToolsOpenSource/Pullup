//
//  Macros.h
//  Pullup
//
//  Created by Brennan Stehling on 6/29/16.
//  Copyright © 2016 SmallSharpTools. All rights reserved.
//

#ifndef Macros_h
#define Macros_h

// Make sure NDEBUG is defined on Release
#ifndef NDEBUG

#define DebugLog(message, ...) NSLog(@"%s: " message, __PRETTY_FUNCTION__, ##__VA_ARGS__)

#else

#define DebugLog(message, ...)

#endif

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define isiOS7OrLater floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1

#define LOG_FRAME(label, frame) DebugLog(@"%@: %f, %f, %f, %f", label, frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)
#define LOG_SIZE(label, size) DebugLog(@"%@, %f, %f", label, size.width, size.height)
#define LOG_POINT(label, point) DebugLog(@"%@: %f, %f", label, point.x, point.y)
#define LOG_OFFSET(label, offset) DebugLog(@"%@: %f, %f", label, offset.x, offset.y)

#endif /* Macros_h */
