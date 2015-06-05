//
//  BLEBaseService.h
//  BLEDemo
//
//  Created by Gore, Hemant D. on 05/06/15.
//  Copyright (c) 2015 Test. All rights reserved.
//

#import "YMSCBService.h"

@interface BLEBaseService : YMSCBService
/**
 Dictionary containing the values measured by the sensor.
 
 This is an abstract propery.
 */
@property (nonatomic, readonly) NSDictionary *sensorValues;

/**
 Turn on CoreBluetooth peripheral service.
 
 This method turns on the service by:
 
 *  writing to *config* characteristic to enable service.
 *  writing to *data* characteristic to enable notification.
 
 */
- (void)turnOn;


/**
 Turn off CoreBluetooth peripheral service.
 
 This method turns off the service by:
 
 *  writing to *config* characteristic to disable service.
 *  writing to *data* characteristic to disable notification.
 
 */
- (void)turnOff;
@end
