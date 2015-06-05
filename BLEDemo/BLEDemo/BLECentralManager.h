//
//  BLECentralManager.h
//  BLEDemo
//
//  Created by Gore, Hemant D. on 05/06/15.
//  Copyright (c) 2015 Test. All rights reserved.
//

#import "YMSCBCentralManager.h"
/**
 Application CoreBluetooth central manager service for BLE.
 
 This class defines a singleton application service instance which manages access to
 the BLE Device via the CoreBluetooth API.
 
 */
@interface BLECentralManager : YMSCBCentralManager

/**
 Return singleton instance.
 @param delegate UI delegate.
 */
+ (BLECentralManager *)initSharedServiceWithDelegate:(id)delegate;

/**
 Return singleton instance.
 */

+ (BLECentralManager *)sharedService;
@end
