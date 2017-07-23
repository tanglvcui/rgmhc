//
//  PAAlarmViewController.m
//  PersonalAlarm
//
//  Created by 唐都 on 17/7/14.
//  Copyright © 2017年 唐都. All rights reserved.
//

#import "PAAlarmViewController.h"
#import "PANavView.h"
#import "PAAlarmCell.h"
#import "PAClockView.h"
#import "PAAddClockViewController.h"
#import "PADBManager.h"
#import "ClockSettings+CoreDataClass.h"


#define UserCellIdetifeir @"PAAlarmCell"

@interface PAAlarmViewController ()<UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource,PANavViewDelegate>
{
    UIImageView *_headerImage;//头部图片
    UILabel *_dateLabel;//头部提示文字
    
}
@property(nonatomic,strong)UIImageView *backgroundImgView;
@property(nonatomic,assign)float backImgHeight;
@property(nonatomic,assign)float backImgWidth;
@property(nonatomic,strong)PANavView *NavView;
@property(nonatomic,strong)UIImageView *headImageView;
@property(nonatomic,strong)UITableView *tableView;
//闹钟数据源
@property(nonatomic,strong)NSMutableArray *dataArray;

@end

@implementation PAAlarmViewController

#pragma -mark Lazy
-(NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    /** 设置导航控制器代理*/
    self.navigationController.delegate = self;
    [self backImageView];
    [self createNaView];
    [self loadData];
    [self layoutTableView];
    
}




//底部imageView
-(void)backImageView{
//    UIImage *image=[UIImage imageNamed:@"back"];
//    _backgroundImgView =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200)];
//    _backgroundImgView.image=image;
//    _backgroundImgView.userInteractionEnabled=YES;
//    [self.view addSubview:_backgroundImgView];
//    _backImgHeight=_backgroundImgView.frame.size.height;
//    _backImgWidth=_backgroundImgView.frame.size.width;
}

- (void)createNaView
{
    self.NavView=[[PANavView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    self.NavView.title = @"唐唐";
    self.NavView.navColor = [UIColor whiteColor];
    self.NavView.left_button_image = @"left";
    self.NavView.right_button_image = @"right";
    self.NavView.delegate = self;
    [self.view addSubview:self.NavView];
}

- (void)loadData
{
    self.dataArray = [NSMutableArray arrayWithArray:[[PADBManager shared] allSettings]];
}


-(void)layoutTableView
{
    if (!_tableView) {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.showsVerticalScrollIndicator=NO;
        _tableView.dataSource=self;
        _tableView.delegate=self;
        _tableView.tableFooterView = [[UIView alloc] init];
        [_tableView registerNib:[UINib nibWithNibName:UserCellIdetifeir bundle:nil] forCellReuseIdentifier:UserCellIdetifeir];
        [self.view addSubview:_tableView];
    }
    [_tableView setTableHeaderView:[self headImageView]];
}


-(UIImageView *)headImageView{
    if (!_headImageView) {
        _headImageView=[[UIImageView alloc]init];
        _headImageView.frame=CGRectMake(0, 64, SCREEN_WIDTH, 170);
        _headImageView.backgroundColor=[UIColor clearColor];
        _headImageView.userInteractionEnabled = YES;
        _headerImage =[[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2-35, 50, 150, 150)];
        _headerImage.center=CGPointMake(SCREEN_WIDTH/2, 70);
        [_headerImage setImage:[UIImage imageNamed:@"clock"]];
        [_headerImage.layer setMasksToBounds:YES];
        [_headerImage.layer setCornerRadius:35];
        _headerImage.backgroundColor=[UIColor clearColor];
        _headerImage.userInteractionEnabled=YES;
        UITapGestureRecognizer *header_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(header_tap_Click:)];
        [_headerImage addGestureRecognizer:header_tap];
        [_headImageView addSubview:_headerImage];
        _dateLabel=[[UILabel alloc]initWithFrame:CGRectMake(147, 130, 105, 20)];
        _dateLabel.center = CGPointMake(SCREEN_WIDTH/2, 125);
        _dateLabel.text = @"Rainy";
        _dateLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *nick_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(nick_tap_Click:)];
        [_dateLabel addGestureRecognizer:nick_tap];
        _dateLabel.textColor=[UIColor whiteColor];
        _dateLabel.textAlignment=NSTextAlignmentCenter;
        //clock
        PAClockView *clock = [[PAClockView alloc] initWithFrame:_headerImage.frame];
        [_headImageView addSubview:clock];
        //        [_headImageView addSubview:_nameLabel];
    }
    return _headImageView;
}

#pragma mark ---- UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return _dataArray.count;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PAAlarmCell *cell = [tableView dequeueReusableCellWithIdentifier:UserCellIdetifeir forIndexPath:indexPath];
    ClockSettings *model=[self.dataArray objectAtIndex:indexPath.row];
    NSLog(@"______modeluserID = %@",model.userInfoID);
    [cell configureUIWithModel:model];
    return cell;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    int contentOffsety = scrollView.contentOffset.y;
    NSLog(@"offset = %d",contentOffsety);
    if (scrollView.contentOffset.y<=170) {
        self.NavView.headerBackView.alpha = scrollView.contentOffset.y/170;
        self.NavView.left_button_image = @"left";
        self.NavView.right_button_image = @"right";
        self.NavView.navColor = [UIColor whiteColor];
//        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }else{
        self.NavView.headerBackView.alpha = 1;
        
        self.NavView.left_button_image = @"theleft";
        self.NavView.right_button_image = @"theright";
        self.NavView.navColor = TDColor(87, 173, 104, 1);
//        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    }
//    if (contentOffsety<0) {
//        CGRect rect = _backgroundImgView.frame;
//        rect.size.height = _backImgHeight-contentOffsety;
//        rect.size.width = _backImgWidth* (_backImgHeight-contentOffsety)/_backImgHeight;
//        rect.origin.x =  -(rect.size.width-_backImgWidth)/2;
//        rect.origin.y = 0;
//        _backgroundImgView.frame = rect;
//    }else{
//        CGRect rect = _backgroundImgView.frame;
//        rect.size.height = _backImgHeight;
//        rect.size.width = _backImgWidth;
//        rect.origin.x = 0;
//        rect.origin.y = -contentOffsety;
//        _backgroundImgView.frame = rect;
//    }
}




-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//cell编辑
//删除
-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) wkSelf=self;
    UITableViewRowAction *deleteAction=[UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        ClockSettings *model=[wkSelf.dataArray objectAtIndex:indexPath.row];
        [wkSelf.dataArray removeObject:model];
        [[PADBManager shared] deletePeopleWithUid:model.time AndTag:model.tag];
        NSLog(@"____id = %@",[model objectID]);
        [wkSelf.tableView reloadData];
    }];
    return @[deleteAction];
}





#pragma - mark Click
- (void)leftClick
{
    NSLog(@"左侧被点击");
    
}

- (void)rightClick
{
    NSLog(@"you侧被点击");
    [self performSegueWithIdentifier:@"addClock" sender:nil];
}

-(void)header_tap_Click:(UITapGestureRecognizer *)tap
{
    NSLog(@"头像");
}
//昵称
-(void)nick_tap_Click:(UIButton *)item
{
    NSLog(@"昵称");
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addClock"]) {
        PAAddClockViewController *receive = segue.destinationViewController;
        receive.reloadBlock = ^{
            self.dataArray = [NSMutableArray arrayWithArray:[[PADBManager shared] allSettings]];
            [self.tableView reloadData];
        };
        
    }

}


#pragma mark - UINavigationControllerDelegate
// 将要显示控制器
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    //判断要显示的控制器是否是自己
    BOOL isShowHomePage = [viewController isKindOfClass:[self class]];
    [self.navigationController setNavigationBarHidden:isShowHomePage animated:YES];
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
