//
//  SegmentSelectView.m
//  SegmentSelectDemo
//
//  Created by LiuZhiwei on 2017/3/13.
//  Copyright © 2017年 LiuZhiwei. All rights reserved.
//

#import "SegmentSelectView.h"

#define Screen_Width [UIScreen mainScreen].bounds.size.width

static CGFloat wordGap = 6.0; // 分栏标题文字距离按钮两侧边距的距离

@interface SegmentSelectView()<UIScrollViewDelegate>{

    UIView        *bottomLine;
    UIScrollView  *backScrollView;
}
@property (nonatomic, strong) UIButton        *lastButton; // 上次选中按钮
@property (nonatomic, assign) CGFloat         bottomLastX;
@property (nonatomic, strong) NSMutableArray  *titles;
@property (nonatomic, strong) NSMutableArray  *buttons;
@property (nonatomic, strong) NSMutableArray  *buttonWidths;
@property (nonatomic, assign) CGFloat         buttonTotalWidth; // 累计的分页按钮的长度

@end

@implementation SegmentSelectView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        backScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        backScrollView.showsHorizontalScrollIndicator = NO;
        backScrollView.delegate = self;
        [self addSubview:backScrollView];
    }
    
    return self;
}

- (void)setTitlesDataWithArray:(NSArray *)array{
    if (array.count > 0) {
        [self.titles removeAllObjects];
        [self.titles addObjectsFromArray:array];
        [self addSegmentButtonsWithTitles:self.titles];
    }
}

/**
 * 根据标题数据添加按钮视图 
 * button按钮说明：一般的标题栏按钮都是简单的文字显示所以用系统的button就够了，如果有特殊需求的可以封装后在这里引用
 */
- (void)addSegmentButtonsWithTitles:(NSMutableArray *)titles{
    [self.buttons removeAllObjects];
    self.buttonTotalWidth = 0.0;
    [backScrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    for (int i=0; i < titles.count; i++) {
        NSString *title = [titles[i] objectForKey:@"NAME"];;
        CGFloat buttonWidth = title.length*self.wordFont+2*wordGap;
        [self.buttonWidths addObject:[NSNumber numberWithFloat:buttonWidth]];

        UIButton *titleButton = [[UIButton alloc] initWithFrame:CGRectMake(self.buttonTotalWidth, 0, buttonWidth, self.bounds.size.height)];
        titleButton.titleLabel.font = [UIFont systemFontOfSize:self.wordFont];
        [titleButton setTitle:title forState:UIControlStateNormal];
        titleButton.tag = i;
        [titleButton addTarget:self action:@selector(titleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.buttonTotalWidth += buttonWidth;
        
        if (i==0) { // 选中按钮 字体为黄色
            [titleButton setTitleColor:self.seletColor forState:UIControlStateNormal];
            self.lastButton = titleButton;
        } else {
            [titleButton setTitleColor:self.normalColor forState:UIControlStateNormal];
        }
        [titleButton setBackgroundColor:[UIColor clearColor]];
        backScrollView.backgroundColor = [UIColor clearColor];
        
        [backScrollView addSubview:titleButton];
        [self.buttons addObject:titleButton];
    }
    
    backScrollView.contentSize = CGSizeMake(self.buttonTotalWidth, 0);
    
    // 添加底部选中线
    CGRect bottomLineFrame = CGRectMake(([self.buttonWidths[0] floatValue]-self.bottomLineWidth)/2, self.bounds.size.height-2, self.bottomLineWidth, 2);
    self.bottomLastX = wordGap;
    bottomLine = [[UIView alloc] initWithFrame:bottomLineFrame];
    bottomLine.backgroundColor = self.bottomLineColor;
    [backScrollView addSubview:bottomLine];
}

- (void)titleButtonClicked:(UIButton *)button{
    
    // 更新选中按钮
    [self.lastButton setTitleColor:self.normalColor forState:UIControlStateNormal];
    self.lastButton = nil;
    self.lastButton = button;
    [button setTitleColor:self.seletColor forState:UIControlStateNormal];
    
    NSInteger index = button.tag;
    if ([self.delegate respondsToSelector:@selector(buttonClickedWithIndex:)]) {
        [self.delegate buttonClickedWithIndex:index];
    }
    // 变更底部选中线位置
    bottomLine.frame = CGRectMake(button.frame.origin.x+([self.buttonWidths[index] floatValue]-self.bottomLineWidth)/2, self.frame.size.height-2, self.bottomLineWidth, 2);
    self.bottomLastX = bottomLine.frame.origin.x;    
    
    CGFloat contentOffsetX = backScrollView.contentOffset.x;
    CGFloat gap = button.center.x - contentOffsetX;
    
    if (gap < Screen_Width/2) { // 按钮距离屏幕左边近
        // 按钮左边距距离屏幕左边距的距离
        CGFloat leftGap = CGRectGetMinX(button.frame) - contentOffsetX;
       
        if (index == 0) { // 按钮为最左侧按钮 只把自己显示全即可
            [self reSetTitleScrollViewOffsetWithX:contentOffsetX+leftGap];
            
        } else {
            CGFloat leftButtonWidth = [self.buttonWidths[index-1] floatValue];
            if ( leftGap < leftButtonWidth){ // 按钮距离左边距不足临近按钮距离 此时需要移动
                    NSLog(@"向右滑动显示左侧按钮");
            [self reSetTitleScrollViewOffsetWithX:contentOffsetX+leftGap-leftButtonWidth];
            }
        }
        
    } else if (gap > Screen_Width/2){
    
        // 按钮右边距距离屏幕右边距的距离
        CGFloat rightGap = contentOffsetX+Screen_Width-CGRectGetMaxX(button.frame);
        
            if (index == self.titles.count-1) { // 当前是最右侧按钮
                [self reSetTitleScrollViewOffsetWithX:contentOffsetX-rightGap];
                
            } else {
                
                CGFloat rightButtonWidth = [self.buttonWidths[index+1] floatValue];
                if (rightGap < rightButtonWidth) { // 按钮距离右边距不足一个按钮距离 此时需要移动
                 [self reSetTitleScrollViewOffsetWithX:contentOffsetX+rightButtonWidth-rightGap];
            }
            
        }
    }

}

- (void)reSetTitleScrollViewOffsetWithX:(CGFloat)pointX{
    [UIView animateWithDuration:0.3 animations:^{
        backScrollView.contentOffset = CGPointMake(pointX, 0);
    }];
}

#pragma mark 页面滑动时和滑动结束调用方法
// 滑动过程中
- (void)setBottomFrameWithScrollView:(UIScrollView *)scrollView AndCurrentPageFrameX:(CGFloat)frameX{
    CGFloat scrollGap = frameX - scrollView.contentOffset.x;
    NSInteger index = self.lastButton.tag;
    
    if (scrollGap < 0) { // 页面向左滑动 底部线向右滑动
        CGFloat scale = -scrollGap*2/Screen_Width;
        CGFloat gap = ([self.buttonWidths[index] floatValue]+[self.buttonWidths[index+1] floatValue]-2*self.bottomLineWidth)/2 + self.bottomLineWidth;
        
        if (scale <= 1) {
            bottomLine.frame = CGRectMake(bottomLine.frame.origin.x, bottomLine.frame.origin.y, self.bottomLineWidth+scale*gap, 2);
        }
        else {
            bottomLine.frame = CGRectMake(self.bottomLastX+(scale-1)*gap, bottomLine.frame.origin.y, self.bottomLineWidth+gap-(scale-1)*gap, 2);
        }
        
    }
    else { // 页面向右滑动 底部线向左滑动
        CGFloat scale = scrollGap*2/Screen_Width;
        CGFloat gap = ([self.buttonWidths[index] floatValue]+[self.buttonWidths[index-1] floatValue]-2*self.bottomLineWidth)/2 + self.bottomLineWidth;
        if (scale <= 1) {
            bottomLine.frame = CGRectMake(self.bottomLastX-scale*gap, bottomLine.frame.origin.y, self.bottomLineWidth+scale*gap, 2);
            
        }
        else {
            bottomLine.frame = CGRectMake(self.bottomLastX-gap, bottomLine.frame.origin.y, self.bottomLineWidth+gap-(scale-1)*gap, 2);
        }
    }

}

// 滑动结束
- (void)setTitleWithScrollView:(UIScrollView *)scrollView AndCurrentPageFrameX:(CGFloat)frameX{
    
    CGFloat scrollGap = frameX - scrollView.contentOffset.x;
    if (scrollView.contentOffset.x == 0) {
        scrollGap = 0;
    }
    NSInteger index = scrollView.contentOffset.x/Screen_Width;
    // 变更选中标题按钮
    [self.lastButton setTitleColor:self.normalColor forState:UIControlStateNormal];
    UIButton *currentButton = self.buttons[index];
    self.lastButton = currentButton;
    [currentButton setTitleColor:self.seletColor forState:UIControlStateNormal];
    
    // 变更底部选中线位置
    bottomLine.frame = CGRectMake(currentButton.frame.origin.x+([self.buttonWidths[index] floatValue]-self.bottomLineWidth)/2, self.frame.size.height-2, self.bottomLineWidth, 2);
    self.bottomLastX = bottomLine.frame.origin.x;
    
    // 判断标签按钮是否在屏幕内
    CGFloat titleContentX = backScrollView.contentOffset.x;
    
    if (scrollGap < 0) { // 向左滑动 判断右边分页按钮是否在屏幕内
        NSLog(@"向左滑动 判断右边分页按钮是否在屏幕内");
        if (index == self.titles.count - 1) {
            if (self.buttonTotalWidth >= Screen_Width) {
                [self reSetTitleScrollViewOffsetWithX:self.buttonTotalWidth-Screen_Width];
            }
        }
        else {
            if (titleContentX+Screen_Width < CGRectGetMaxX(currentButton.frame)+[self.buttonWidths[index+1] floatValue]) { // 右侧按钮不完全在屏幕内
                CGFloat scrollGap = CGRectGetMaxX(currentButton.frame)+[self.buttonWidths[index+1] floatValue] - titleContentX - Screen_Width;
                [self reSetTitleScrollViewOffsetWithX:titleContentX+scrollGap];
            }
            
        }
        
    } else if (scrollGap >= 0){ // 向右滑动 判断左边分页按钮是否在屏幕内
        NSLog(@"向右滑动 判断左边分页按钮是否在屏幕内");
        if (index == 0) {
            [self reSetTitleScrollViewOffsetWithX:0];
        }
        else {
            if (CGRectGetMinX(currentButton.frame) - titleContentX < [self.buttonWidths[index-1] floatValue]) {
                CGFloat scrollGap = [self.buttonWidths[index-1] floatValue] + titleContentX - CGRectGetMinX(currentButton.frame);
                [self reSetTitleScrollViewOffsetWithX:titleContentX-scrollGap];
            }
            
        }
        
    }
}


#pragma mark GetterMethod
- (NSMutableArray *)titles{
    if (!_titles) {
        _titles = [NSMutableArray array];
    }
    return _titles;
}

- (NSMutableArray *)buttons{
    if (!_buttons) {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

- (NSMutableArray *)buttonWidths{
    if (!_buttonWidths) {
        _buttonWidths = [NSMutableArray array];
    }
    return _buttonWidths;
}

- (CGFloat)wordFont{
    if (!_wordFont) {
        _wordFont = 14;
    }
    return _wordFont;
}

- (CGFloat)bottomLineWidth{
    if (!_bottomLineWidth) {
        _bottomLineWidth = 20;
    }
    return _bottomLineWidth;
}

- (UIColor *)bottomLineColor{
    if (!_bottomLineColor) {
        _bottomLineColor = [UIColor yellowColor];
    }
    return _bottomLineColor;
}

- (UIColor *)seletColor{
    if (!_seletColor) {
        _seletColor = [UIColor redColor];
    }
    return _seletColor;
}

- (UIColor *)normalColor{
    if (!_normalColor) {
        _normalColor = [UIColor blackColor];
    }
    return _normalColor;
}

@end
