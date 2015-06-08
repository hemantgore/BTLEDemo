//
//  FirstViewController.m
//  BLEDemo
//
//  Created by Gore, Hemant D. on 05/06/15.
//  Copyright (c) 2015 Test. All rights reserved.
//

#import "FirstViewController.h"
#import "BLEPeripheralTag.h"
#import "YMSCBService.h"
#import "YMSCBCharacteristic.h"
#import "YMSCBDescriptor.h"
@interface FirstViewController ()

@end

@implementation FirstViewController
@synthesize scanButton,peripheralTable;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    BLECentralManager *centralManager = [BLECentralManager initSharedServiceWithDelegate:self];
    [centralManager addObserver:self
                     forKeyPath:@"isScanning"
                        options:NSKeyValueObservingOptionNew
                        context:NULL];
//    [self scanButtonAction:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    BLECentralManager *centralManager = [BLECentralManager sharedService];
    
    if (object == centralManager) {
        if ([keyPath isEqualToString:@"isScanning"]) {
            if (centralManager.isScanning) {
                [self.scanButton setTitle:@"Stop Scanning" forState:UIControlStateNormal];
            } else {
                [self.scanButton setTitle:@"Start Scan" forState:UIControlStateNormal];
            }
        }
    }
}

- (IBAction)scanButtonAction:(id)sender {
    BLECentralManager *centralManager = [BLECentralManager sharedService];
    
    if (centralManager.isScanning == NO) {
        [centralManager startScan];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
         [NSTimer scheduledTimerWithTimeInterval:(float)5.0 target:self selector:@selector(scanTimer:) userInfo:nil repeats:NO];
    }
    else {
        [centralManager stopScan];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
//        for (DEAPeripheralTableViewCell *cell in [self.peripheralsTableView visibleCells]) {
//            if (cell.yperipheral.cbPeripheral.state == CBPeripheralStateDisconnected) {
//                cell.rssiLabel.text = @"—";
//                cell.peripheralStatusLabel.text = @"QUIESCENT";
//                [cell.peripheralStatusLabel setTextColor:[[DEATheme sharedTheme] bodyTextColor]];
//            }
//        }
        
    }
}
- (void)scanTimer:(NSTimer *)timer
{
     BLECentralManager *centralManager = [BLECentralManager sharedService];
    [centralManager stopScan];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSLog(@"ymsPeripherals::%@",centralManager.ymsPeripherals);
    [self.peripheralTable reloadData];
}

#pragma mark - CBCentralManagerDelegate Methods


- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            break;
        case CBCentralManagerStatePoweredOff:
            break;
            
        case CBCentralManagerStateUnsupported: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"Unfortunately this device can not talk to Bluetooth Smart (Low Energy) Devices"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
            
            [alert show];
            break;
        }
        case CBCentralManagerStateResetting: {
//            [self.peripheralsTableView reloadData];
            break;
        }
        case CBCentralManagerStateUnauthorized:
            break;
            
        case CBCentralManagerStateUnknown:
            break;
            
        default:
            break;
    }
    
    
    
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    BLECentralManager *centralManager = [BLECentralManager sharedService];
    YMSCBPeripheral *yp = [centralManager findPeripheral:peripheral];
    yp.delegate = self;
    
    [yp readRSSI];
    
//    for (DEAPeripheralTableViewCell *cell in [self.peripheralsTableView visibleCells]) {
//        if (cell.yperipheral == yp) {
//            [cell updateDisplay];
//            break;
//        }
//    }
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
//    for (DEAPeripheralTableViewCell *cell in [self.peripheralsTableView visibleCells]) {
//        [cell updateDisplay];
//    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    BLECentralManager *centralManager = [BLECentralManager sharedService];
    
    YMSCBPeripheral *yp = [centralManager findPeripheral:peripheral];
    if (yp.isRenderedInViewCell == NO) {
//        [self.peripheralsTableView reloadData];
        yp.isRenderedInViewCell = YES;
    }
    
//    if (centralManager.isScanning) {
//        for (DEAPeripheralTableViewCell *cell in [self.peripheralsTableView visibleCells]) {
//            if (cell.yperipheral.cbPeripheral == peripheral) {
//                if (peripheral.state == CBPeripheralStateDisconnected) {
//                    cell.rssiLabel.text = [NSString stringWithFormat:@"%d", [RSSI integerValue]];
//                    cell.peripheralStatusLabel.text = @"ADVERTISING";
//                    [cell.peripheralStatusLabel setTextColor:[[DEATheme sharedTheme] advertisingColor]];
//                } else {
//                    continue;
//                }
//            }
//        }
//    }
}
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
    BLECentralManager *centralManager = [BLECentralManager sharedService];
    
    for (CBPeripheral *peripheral in peripherals) {
        YMSCBPeripheral *yp = [centralManager findPeripheral:peripheral];
        if (yp) {
            yp.delegate = self;
            NSLog(@"BLE name:%@",yp.name);
        }
    }
    
    [self.peripheralTable reloadData];
    
}


#pragma mark - CBPeripheralDelegate Methods

- (void)performUpdateRSSI:(NSArray *)args {
    CBPeripheral *peripheral = args[0];
    
    [peripheral readRSSI];
    
}
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    
    if (error) {
        NSLog(@"ERROR: readRSSI failed, retrying. %@", error.description);
        
        if (peripheral.state == CBPeripheralStateConnected) {
            NSArray *args = @[peripheral];
            [self performSelector:@selector(performUpdateRSSI:) withObject:args afterDelay:2.0];
        }
        
        return;
    }
    
//    for (DEAPeripheralTableViewCell *cell in [self.peripheralsTableView visibleCells]) {
//        if (cell.yperipheral) {
//            if (cell.yperipheral.isConnected) {
//                if (cell.yperipheral.cbPeripheral == peripheral) {
//                    cell.rssiLabel.text = [NSString stringWithFormat:@"%@", peripheral.RSSI];
//                    break;
//                }
//            }
//        }
//    }
    
    BLECentralManager *centralManager = [BLECentralManager sharedService];
    YMSCBPeripheral *yp = [centralManager findPeripheral:peripheral];
    
    NSArray *args = @[peripheral];
    [self performSelector:@selector(performUpdateRSSI:) withObject:args afterDelay:yp.rssiPingPeriod];
}
#pragma mark - UITableViewDelegate and UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
     BLECentralManager *centralManager = [BLECentralManager sharedService];
    return [centralManager.ymsPeripherals count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat result;
    result = 80.0;
    return result;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"peripheralCell";
    UITableViewCell *pcell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    BLECentralManager *centralManager = [BLECentralManager sharedService];
     YMSCBPeripheral *yp = [centralManager peripheralAtIndex:indexPath.row];
    UILabel *name = (UILabel*)[pcell viewWithTag:100];
    name.text= yp.name;
    
    UILabel *pID = (UILabel*)[pcell viewWithTag:101];
    pID.text= [NSString stringWithFormat:@"Connected:%d",yp.isConnected];
    
    return pcell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BLECentralManager *centralManager = [BLECentralManager sharedService];
    YMSCBPeripheral *yp = [centralManager peripheralAtIndex:indexPath.row];
    NSLog(@"Connecting to peripheral with UUID : %@", yp.cbPeripheral.identifier.UUIDString);
    [yp connectWithOptions:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey] withBlock:^(YMSCBPeripheral *yp, NSError *error) {
        if(!error){
            NSLog(@"connected");
            [yp discoverServices:[yp services] withBlock:^(NSArray *yservices, NSError *error) {
                if (error) {
                    NSLog(@"Error in services");
                }else{
                    NSLog(@"services discovered");
//                     for (YMSCBService *service in yservices) {
//                         __weak YMSCBService *thisService = (YMSCBService *)service;
//                         
//                         [service discoverCharacteristics:[service characteristics] withBlock:^(NSDictionary *chDict, NSError *error) {
//                             if (error) {
//                                NSLog(@"discoverCharacteristics error::%@",error);
//                             }else{
//                                 for (NSString *key in chDict) {
//                                     YMSCBCharacteristic *ct = chDict[key];
//                                     //NSLog(@"%@ %@ %@", ct, ct.cbCharacteristic, ct.uuid);
//                                     
//                                     [ct discoverDescriptorsWithBlock:^(NSArray *ydescriptors, NSError *error) {
//                                         if (error) {
//                                             NSLog(@"discoverDescriptorsWithBlock error::%@",error);
//                                         }
//                                         for (YMSCBDescriptor *yd in ydescriptors) {
//                                             NSLog(@"Descriptor: %@ %@ %@", thisService.name, yd.UUID, yd.cbDescriptor);
//                                         }
//                                     }];
//                                 }
//                             }
//                         }];
//                     }
                }
                
            }];
        }else{
            NSLog(@"Not connected");
        }
    }];
}
@end
