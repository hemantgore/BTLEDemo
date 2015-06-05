//
//  BLEPeripheralTag.h
//  BLEDemo
//
//  Created by Gore, Hemant D. on 05/06/15.
//  Copyright (c) 2015 Test. All rights reserved.
//

#import "YMSCBPeripheral.h"
@class BLEDeviceInfoService;

@interface BLEPeripheralTag : YMSCBPeripheral

@property (nonatomic, readonly) BLEDeviceInfoService *devinfo;
@end
