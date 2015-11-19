//
//  PeripheralsTableViewCell.h
//  ECApplicationTemplate
//
//  Created by chengyh on 15/11/13.
//  Copyright © 2015年 jianyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PeripheralsTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *manufacturerLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *pairingPeripheralIndicatorView;

@property (nonatomic, copy) NSString *manufacturerString;

@end
