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
//BlueCreation,  BC127 chip
//#define BLE_SERVICE_UUID                         "BC2F4CC6-AAEF-4351-9034-D66268E328F0"
//#define BLE_CHAR_TX_UUID                         "06D1E5E7-79AD-4A71-8FAA-373789F7D93C"
//#define BLE_CHAR_RX_UUID                         "06D1E5E7-79AD-4A71-8FAA-373789F7D93C"

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
-(int) decimalIntoHex:(char) number
{
    char ge  =number/10*16;
    char shi =number%10;
    int total =ge +shi;
    return total;
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
                    /*
                     4.3.1 System Message Format
                     MSGID|MSGTYP|NODEID|VCSID|CMDTYP||CMD||CMDPKT|PRI|TIMSTMP
                     */
                    uint8_t send[20];
                    send[0]=[self decimalIntoHex:1];
                    send[1]=0xB0;//MSG Type-0xB0:Sys, 0xB1:HW,0xB2:info, 0xB3:ACT
                    send[2]=0x00;//5 bit, used for H/w msg type: 0xFD
                    send[3]=0xC3;
                    send[4]=0xA0;//CMD type, 0xA0:SET, 0xA1:GET, 0xA2:ACT
                    send[5]=0xA0;//CMD,e,g: SetSysMod:0xEC
                    send[6]=0x01; // 0x01:Cycling
                    send[7]=0x01;//(0x01)in HEX==1 in Decimal
                    send[8]=[self decimalIntoHex:[[NSDate date] timeIntervalSince1970]];// Get Sencond in since, convert ot HEX
                    send[9] =0x00;
                    send[10] =0x00;
                    send[11] =0x00;
                    send[12] =0x00;
                    send[13] =0x00;
                    send[14] =0x00;
                    send[15] =0;
                    
                    NSData *data1 =[NSData dataWithBytes:send length:16];
                    for(int i=0;i<15;i++)
                    {
                        send[15] +=send[i];
                    }
                    send[15] =send[15] & 0xFF;

                    [yp disconnect];
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
