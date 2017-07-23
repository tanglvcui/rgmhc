//
//  PARepeatViewController.h
//  PersonalAlarm
//
//  Created by 唐都 on 17/7/14.
//  Copyright © 2017年 唐都. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PARepeatViewController : UIViewController


typedef void(^deliverRepeatBlock)(NSString *selectedRepeatMode);
typedef void(^deliverRepeatDayBlock)(NSArray *selectedRepeatModeDay);


@property (nonatomic, copy) deliverRepeatBlock deliverRepeatBlock;
@property (nonatomic,copy) deliverRepeatDayBlock selectedDayArrBlock;


@end
