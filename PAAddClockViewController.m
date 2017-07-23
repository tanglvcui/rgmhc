//
//  PAAddClockViewController.m
//  PersonalAlarm
//
//  Created by 唐都 on 17/7/14.
//  Copyright © 2017年 唐都. All rights reserved.
//



#import "Masonry.h"
#import "PAAddClockViewController.h"
#import "PAPickerTableViewCell.h"
#import "PATagTableViewCell.h"
#import "PARingsTableViewCell.h"
#import "ClockSettings+CoreDataClass.h"
#import "PATagViewController.h"
#import "PARepeatViewController.h"
#import "PADBManager.h"
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"
#import "LVRecordTool.h"
#import "PARecordView.h"
#import "PALotificationTool.h"
#import "NSDate+fish_Extension.h"




static NSString *pickerCellID = @"pickerCell";
static NSString *repeatCellID = @"repeatCell";
static NSString *tagCellID = @"tagCell";
static NSString *ringCellID = @"ringCell";
static NSString *testCellID = @"testCell";


@interface PAAddClockViewController ()<UITableViewDelegate, UITableViewDataSource,datePickerValueChangedDelegate>
@property (weak, nonatomic) IBOutlet UITableView *addClockTableView;
//记录选择
@property (nonatomic,copy) NSString *time;
@property (nonatomic,copy) NSString *path;
@property (nonatomic,copy) NSString *tag;
@property (nonatomic,copy) NSString *repeatDay;
@property (nonatomic,strong) NSMutableArray *dataArr;
@property (nonatomic,copy) NSString *noticeObjectID;
//选择的重复模式
@property (nonatomic,assign)NoticeRepeatMode repeatMode;
//选择的重复模式array
@property (nonatomic,strong)NSArray *repeatModeArr;





//播放器
@property (nonatomic,strong)AVAudioPlayer *player;






@end

@implementation PAAddClockViewController

-(NSArray *)repeatModeArr
{
    if (!_repeatModeArr) {
        _repeatModeArr = [NSArray array];
    }
    return _repeatModeArr;
}


-(NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.addClockTableView.tableFooterView = [[UIView alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
}

#pragma -mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        PAPickerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:pickerCellID];
        cell.delegate = self;
        return cell;
    }else if (indexPath.row == 1){
        PATagTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:repeatCellID];
        return cell;
    }else if (indexPath.row == 2){
        PARingsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tagCellID];
        return cell;
    }else if (indexPath.row == 3)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ringCellID];
        return cell;
    }else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:testCellID];
        cell.separatorInset = UIEdgeInsetsMake(0, SCREEN_WIDTH, 0, 0);
        return cell;
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return SCREEN_HEIGHT/3;
    }else if(indexPath.row == 4)
    {
        return 85;
    }else
    {
        return 45;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//保存点击
- (IBAction)saveClick:(UIBarButtonItem *)sender {
    //获取当前选择项的值
    /** datePicker*/
    UIDatePicker *picker = [self.view viewWithTag:100];
    /** 闹铃*/
    UILabel *tagLabel = [self.view viewWithTag:102];
    self.tag = tagLabel.text;
    NSLog(@"保存时的tag = %@",self.tag);
    //获取重复标签字符串的格式
    UILabel *repeatModeLabel = [self.view viewWithTag:101];
    self.repeatDay = repeatModeLabel.text;
    NSLog(@"label.text = %@",self.repeatDay);
    
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *components = [calendar components:unitFlags fromDate:picker.date];
    NSInteger hour = [components hour];
    NSInteger min = [components minute];
    NSInteger weekDay = [components weekday];
    
    
    //获取当前是星期几，与选择的日期做比较
    NSLog(@"______当前是星期 %ld",weekDay);
    
    
    
    NSCalendar *calendar2 = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSTimeZone *zone = [NSTimeZone  systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: now];
    NSDate *localeDate = [now  dateByAddingTimeInterval: interval];
    NSDateComponents *witchDayComponent = [[NSDateComponents alloc] init];
    //weekDay 1，星期天 、 2，星期一、 3，星期二、 4，星期三、 5，星期四、 6，星期五、 7，星期六
    witchDayComponent.weekday = 1;
    [witchDayComponent setHour:hour];
    [witchDayComponent setMinute:min];
    NSLog(@"localDate = %@",localeDate);
    NSDate *nextWitchDay = [calendar2 nextDateAfterDate:localeDate matchingComponents:witchDayComponent options:NSCalendarMatchNextTime];
    NSDate *nextDate = [nextWitchDay  dateByAddingTimeInterval: interval];
    NSLog(@"nextDate = %@",nextDate);
    NSDate *currentDate = [NSDate date];
    //用于格式化NSDate对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设置格式：zzz表示时区
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    //NSDate转NSString
    NSString *selectedDateString = [dateFormatter stringFromDate:currentDate];
    self.time = selectedDateString;
    
    
    
    
    for (int i = 0; i<self.repeatModeArr.count; i++) {
        
        //转换成时分， 星期格式
        if ([self.repeatModeArr[i] integerValue] + 1 == weekDay) {//当天
            NSDate *pickerDate = [picker date];
            // 获取用户通过UIDatePicker设置的日期和时间
            NSDateFormatter *pickerFormatter = [[NSDateFormatter alloc] init];
            // 创建一个日期格式器
            [pickerFormatter setDateFormat:@"yyy-MM-dd HH:mm"];
            NSString *dateString = [pickerFormatter stringFromDate:pickerDate];
            NSDate *dateTime = [pickerFormatter dateFromString:dateString];
            NSLog(@"___final Date = %@",dateTime);
            NSLog(@"___nextDate = %@",nextDate);
            //数据库存储
            [[PADBManager shared] insertRingPath:@"123" tag:self.tag time:dateString repeatDay:self.repeatDay];
            //插入后会有一个唯一的objectID,取值
            self.noticeObjectID = [[PADBManager shared].objectID lastPathComponent];
//            nextDate = dateTime;
            [PALotificationTool registerLocalNotification:dateTime repeatMode:self.repeatMode AndAlertBody:self.tag AndSoundName:@"66728.wav" AndNotificationParam:self.noticeObjectID AndNotificationKey:self.noticeObjectID];
        }else {//下一个星期几
            self.repeatMode = NoticeRepeatModeWeek;
            //数据库存储
            [[PADBManager shared] insertRingPath:@"123" tag:self.tag time:self.time  repeatDay:self.repeatDay];
            //插入后会有一个唯一的objectID,取值
            self.noticeObjectID = [[PADBManager shared].objectID lastPathComponent];
            [PALotificationTool registerLocalNotification:nextDate repeatMode:self.repeatMode AndAlertBody:self.tag AndSoundName:@"66728.wav" AndNotificationParam:self.noticeObjectID AndNotificationKey:self.noticeObjectID];

        }
    }
    
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.navigationController popViewControllerAnimated:YES];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    
    NSLog(@"____________当前通知的key是%@_____________",self.noticeObjectID);
    
    //    //判断repeatModeDay模式
    //    if ([repeatModeLabel.text isEqualToString:@"每天"]) {
    //        self.repeatMode = NoticeRepeatModeDay;
    //        [PALotificationTool registerLocalNotification:nextDate repeatMode:self.repeatMode AndAlertBody:self.tag AndSoundName:@"66728.wav" AndNotificationParam:self.noticeObjectID AndNotificationKey:self.noticeObjectID];
    //    }else if ([repeatModeLabel.text rangeOfString:@","].location != NSNotFound){//有","指定在一个星期的哪几天重复
    //        self.repeatMode = NoticeRepeatModeWeek;
    //        //分割字符串
    //        NSArray *cutArr = [repeatModeLabel.text componentsSeparatedByString:@","];
    //        NSLog(@"_____cutArr 的个数为 %ld",cutArr.count);
    //        for (int i = 0; i<cutArr.count; i++) {
    //            [PALotificationTool registerLocalNotification:picker.date repeatMode:self.repeatMode AndAlertBody:self.tag AndSoundName:@"66728.wav" AndNotificationParam:self.noticeObjectID AndNotificationKey:self.noticeObjectID];
    //        }
    //    }else if ([repeatModeLabel.text isEqualToString:@"不重复"]){
    //        self.repeatMode = NoticeRepeatModeNone;
    //        [PALotificationTool registerLocalNotification:picker.date repeatMode:self.repeatMode AndAlertBody:self.tag AndSoundName:@"66728.wav" AndNotificationParam:self.noticeObjectID AndNotificationKey:self.noticeObjectID];
    //    }
    //    else{//没有",",指定在一个星期哪一天重复
    //        //
    //        self.repeatMode = NoticeRepeatModeWeek;
    //        [PALotificationTool registerLocalNotification:picker.date repeatMode:self.repeatMode AndAlertBody:self.tag AndSoundName:@"66728.wav" AndNotificationParam:self.noticeObjectID AndNotificationKey:self.noticeObjectID];
    //    }
    //
    
    
    if (self.reloadBlock) {
        self.reloadBlock();
    }
    
    
    //数据库存储
    //    [[PADBManager shared] insertRingPath:@"asdfasdf" tag:self.tag time:self.time];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"tagDetail"]) {//标签label
        UILabel *tagLabel = [self.view viewWithTag:102];
        PATagViewController *receive = segue.destinationViewController;
        receive.tag = tagLabel.text;
        receive.deliverBlock = ^(NSString *writtenTag) {
            tagLabel.text = writtenTag;
        };
    }
    if ([segue.identifier isEqualToString:@"repeatDetail"]) {//重复label
        PARepeatViewController *rVc = segue.destinationViewController;
        UILabel *repeatLabel = [self.view viewWithTag:101];
        rVc.deliverRepeatBlock = ^(NSString *selectedRepeatMode){
            repeatLabel.text = selectedRepeatMode;
        };
        rVc.selectedDayArrBlock = ^(NSArray *selectedDayArr){
            
            self.repeatModeArr = selectedDayArr;
        };
    }
}

- (IBAction)backClick:(UIBarButtonItem *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)testVoiceClick:(id)sender {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *path = [docDir stringByAppendingString:@"/lvRecord.pcm"];
    NSLog(@"___测试的地址是%@____",path);
    LVRecordTool *recordTool = [LVRecordTool sharedRecordTool];
    [recordTool playWithBundlePath:nil];
}

#pragma -mark DatePickerValueChangedDelegate
- (void)datePickerValueChange:(NSString *)formatDate
{
    self.time = formatDate;
    NSLog(@"picker time = %@",self.time);
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
