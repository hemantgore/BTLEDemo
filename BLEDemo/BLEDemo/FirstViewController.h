//
//  FirstViewController.h
//  BLEDemo
//
//  Created by Gore, Hemant D. on 05/06/15.
//  Copyright (c) 2015 Test. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLEBaseViewController.h"
#import "BLECentralManager.h"
@interface FirstViewController : BLEBaseViewController<CBPeripheralDelegate,UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) IBOutlet UIButton *scanButton;
@property(nonatomic,strong) IBOutlet UITableView *peripheralTable;
-(IBAction) scanButtonAction:(id)sender;
@end

