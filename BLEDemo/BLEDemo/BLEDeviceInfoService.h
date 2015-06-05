//
//  BLEDeviceInfoService.h
//  BLEDemo
//
//  Created by Gore, Hemant D. on 05/06/15.
//  Copyright (c) 2015 Test. All rights reserved.
//

#import "YMSCBService.h"
#import "BLETagHeader.h"
@class YMSCBCharacteristic;
@interface BLEDeviceInfoService : YMSCBService
/** @name Properties */
/// System ID
@property (nonatomic, strong) NSString *system_id;
/// Model Number
@property (nonatomic, strong) NSString *model_number;
/// Serial Number
@property (nonatomic, strong) NSString *serial_number;
/// Firmware Revision
@property (nonatomic, strong) NSString *firmware_rev;
/// Hardware Revision
@property (nonatomic, strong) NSString *hardware_rev;
/// Software Revision
@property (nonatomic, strong) NSString *software_rev;
/// Manufacturer Name
@property (nonatomic, strong) NSString *manufacturer_name;
/// IEEE 11073 Certification Data
@property (nonatomic, strong) NSString *ieee11073_cert_data;

/** @name Read Device Information */
/**
 Issue set of read requests to obtain device information which is store in the class properties.
 */
- (void)readDeviceInfo;
@end
