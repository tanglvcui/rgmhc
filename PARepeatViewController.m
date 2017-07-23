
//
//  PARepeatViewController.m
//  PersonalAlarm
//
//  Created by 唐都 on 17/7/14.
//  Copyright © 2017年 唐都. All rights reserved.
//

#import "PARepeatViewController.h"
#import "PApickDayCell.h"




static NSString *dayCellID = @"PAchooseDayTableViewCell";


@interface PARepeatViewController ()
@property (weak, nonatomic) IBOutlet UITableView *repeatTableView;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSMutableArray *selectedArr;

@end

@implementation PARepeatViewController

- (NSMutableArray *)selectedArr
{
    if (!_selectedArr) {
        _selectedArr = [NSMutableArray array];
    }
    return _selectedArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


#pragma -mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PApickDayCell *cell = [tableView dequeueReusableCellWithIdentifier:dayCellID];
    if (indexPath.row == 0) {
        cell.dayLabel.text = @"星期天";
    }else if (indexPath.row == 1){
        cell.dayLabel.text = @"星期一";
    }
    else if (indexPath.row == 2){
        cell.dayLabel.text = @"星期二";
    }else if (indexPath.row == 3){
        cell.dayLabel.text = @"星期三";
    }else if (indexPath.row == 4){
        cell.dayLabel.text = @"星期四";
    }else if (indexPath.row == 5){
        cell.dayLabel.text = @"星期五";
    }else{
        cell.dayLabel.text = @"星期六";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _currentIndex = indexPath.row;
    PApickDayCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.isSelected == YES) {
        cell.isSelected = NO;
        cell.selectedImageView.image = [UIImage imageNamed:@""];
        [self.selectedArr removeObject:[NSString stringWithFormat:@"%ld",indexPath.row]];
    }else
    {
        cell.selectedImageView.image = [UIImage imageNamed:@"selected"];
        cell.isSelected = YES;
        [self.selectedArr addObject:[NSString stringWithFormat:@"%ld",indexPath.row]];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"____selected = %@",self.selectedArr);
}

- (IBAction)backClick:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    //排序
    NSComparator finderSort = ^(id string1,id string2){
        
        if ([string1 intValue] > [string2 intValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }else if ([string1 integerValue] < [string2 integerValue]){
            return (NSComparisonResult)NSOrderedAscending;
        }
        else
            return (NSComparisonResult)NSOrderedSame;
    };
    //数组排序：
    NSMutableArray *resultArray = [[self.selectedArr sortedArrayUsingComparator:finderSort] mutableCopy];
    for (int i = 0; i<resultArray.count; i++) {
        switch ([resultArray[i] intValue]) {
            case 0:
                [resultArray replaceObjectAtIndex:[resultArray indexOfObject:@"0"] withObject:@"星期天"];
                break;
            case 1:
                [resultArray replaceObjectAtIndex:[resultArray indexOfObject:@"1"] withObject:@"星期一"];
                break;
            case 2:
                [resultArray replaceObjectAtIndex:[resultArray indexOfObject:@"2"] withObject:@"星期二"];
                break;
            case 3:
                [resultArray replaceObjectAtIndex:[resultArray indexOfObject:@"3"] withObject:@"星期三"];
                break;
            case 4:
                [resultArray replaceObjectAtIndex:[resultArray indexOfObject:@"4"] withObject:@"星期四"];
                break;
            case 5:
                [resultArray replaceObjectAtIndex:[resultArray indexOfObject:@"5"] withObject:@"星期五"];
                break;
            case 6:
                [resultArray replaceObjectAtIndex:[resultArray indexOfObject:@"6"] withObject:@"星期六"];
                break;
                
                
            default:
                break;
        }
        
    }
    __block NSString *strings = [self.selectedArr componentsJoinedByString:@","];
    NSLog(@"_____string_____ = %@",strings);
    if (self.deliverRepeatBlock) {
        if (self.selectedArr.count == 7) {
            self.deliverRepeatBlock(@"每天");
        }else if (self.selectedArr.count ==0){
            self.deliverRepeatBlock(@"不重复");
        }
        else{
        self.deliverRepeatBlock([resultArray componentsJoinedByString:@","]);
        }
        self.selectedDayArrBlock(self.selectedArr);
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
