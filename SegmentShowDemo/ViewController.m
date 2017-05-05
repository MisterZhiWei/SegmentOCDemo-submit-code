//
//  ViewController.m
//  SegmentShowDemo
//
//  Created by LiuZhiwei on 14/04/2017.
//  Copyright © 2017 LiuZhiwei. All rights reserved.
//
#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_Height [UIScreen mainScreen].bounds.size.height

#import "ViewController.h"
#import "SegmentSelectView.h"

@interface ViewController ()<UIScrollViewDelegate,SegmentSelectViewDelegate>{

    SegmentSelectView *segmentView;
    UIScrollView *listView;
}

@property (nonatomic, assign) CGFloat           currentX; // 当前列表页的frame-X
@property (nonatomic, assign) NSInteger         currentPage; // 当前（滑到）页
@property (nonatomic, assign) BOOL              isClick;
@end

@implementation ViewController

#pragma mark 系统方法
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initSubViews];
}

- (void)initSubViews{
    CGRect segmentFrame = CGRectMake(0, 20, Screen_Width, 50);
    segmentView = [[SegmentSelectView alloc] initWithFrame:segmentFrame];
    segmentView.backgroundColor = [UIColor colorWithRed:212/255.0 green:245/255.0 blue:253/255.0 alpha:1.0];
    segmentView.seletColor = [UIColor colorWithRed:0/255.0 green:180/255.0 blue:227/255.0 alpha:1.0];
    segmentView.normalColor = [UIColor colorWithRed:85/255.0 green:90/255.0 blue:100/255.0 alpha:1.0];
    segmentView.bottomLineColor = [UIColor colorWithRed:0/255.0 green:180/255.0 blue:227/255.0 alpha:1.0];
    segmentView.wordFont = 16.0f;
    segmentView.delegate = self;
    [self.view addSubview:segmentView];
    
    listView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 70, Screen_Width, Screen_Height-90)];
    listView.delegate = self;
    listView.pagingEnabled = YES;
    listView.bounces = NO;
    listView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:listView];
    
    NSArray *titles = [self makeData];
    
    [segmentView setTitlesDataWithArray:titles];
    
    for (int i=0; i < titles.count; i++) {
        CGRect frame = CGRectMake(i*Screen_Width, 0, Screen_Width, Screen_Height-90);
        UILabel *showLab = [[UILabel alloc] initWithFrame:frame];
        showLab.text = [titles[i] objectForKey:@"NAME"];
        showLab.textColor = [UIColor whiteColor];
        showLab.backgroundColor = [UIColor blackColor];
        showLab.textAlignment = NSTextAlignmentCenter;
        [listView addSubview:showLab];
    }
    
    listView.contentSize = CGSizeMake(titles.count*Screen_Width, 0);
}

#pragma mark SegmentSelectViewDelegate
- (void)buttonClickedWithIndex:(NSInteger)index{
    self.isClick = YES;
    listView.contentOffset = CGPointMake(index*Screen_Width, 0);
    // 解决点击按钮后 首次拖拽滑动页面 底部线位置变化Bug
    [self scrollViewDidEndDecelerating:listView];
    // (实际使用时)判断列表页是否已经加载了数据 没加载则请求 否则不做请求
    
}

#pragma mark scrollDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (!self.isClick) {
        [segmentView setBottomFrameWithScrollView:scrollView AndCurrentPageFrameX:self.currentX];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [segmentView setTitleWithScrollView:scrollView AndCurrentPageFrameX:self.currentX];
    self.currentX = scrollView.contentOffset.x;
    NSInteger index = self.currentX/Screen_Width;
    self.currentPage = index;
    
    // (实际使用时)判断列表页是否已经加载了数据 没加载则请求 否则不做请求
    if (self.isClick) {
        self.isClick = NO;
    }
}

#pragma mark 模拟获取数据
- (NSArray *)makeData{

    NSArray *data = @[@{@"NAME":@"要闻"},@{@"NAME":@"道"},@{@"NAME":@"人工智能科技"},@{@"NAME":@"汽车"},@{@"NAME":@"农业科技"},@{@"NAME":@"文学"},@{@"NAME":@"社会科学"},@{@"NAME":@"军事纪实"},@{@"NAME":@"自定义频道"},@{@"NAME":@"大数据技术"},];
    
    return data;
}


@end
