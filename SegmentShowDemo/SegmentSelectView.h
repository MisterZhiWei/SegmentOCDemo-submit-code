//
//  SegmentSelectView.h
//  SegmentSelectDemo
//
//  Created by LiuZhiwei on 2017/3/13.
//  Copyright © 2017年 LiuZhiwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SegmentSelectViewDelegate <NSObject>

@required
- (void)buttonClickedWithIndex:(NSInteger)index;

@end

@interface SegmentSelectView : UIButton

@property (nonatomic, assign) CGFloat bottomLineWidth; // 底部选中线宽度 不设置时为默认值


/**
 * 下边栏目的颜色
 */
@property (nonatomic, strong) UIColor *bottomLineColor;

/**
 * 选中栏目的字体颜色
 */
@property (nonatomic, strong) UIColor *seletColor;

/**
 * 默认栏目的字体颜色（即未选中栏目的字体颜色）
 */
@property (nonatomic, strong) UIColor *normalColor;

/**
 * 栏目字体大小 默认14
 */
@property (nonatomic, assign) CGFloat wordFont;

@property (nonatomic, assign) id <SegmentSelectViewDelegate> delegate;

/**
 * 设置分栏标题
 */
- (void)setTitlesDataWithArray:(NSArray *)array;

/**
 * 手动滑动页面结束时，滑动到对应标题
 * parameter srollView 页面所在滑动的scrollView
 * parameter frameX    当前页面的frame.origin.x
 */
- (void)setTitleWithScrollView:(UIScrollView *)scrollView AndCurrentPageFrameX:(CGFloat)frameX;

/**
 * 手动滑动过程中移动底部选中线
 * parameter srollView 页面所在滑动的scrollView
 * parameter frameX    当前页面的frame.origin.x
 */
- (void)setBottomFrameWithScrollView:(UIScrollView *)scrollView AndCurrentPageFrameX:(CGFloat)frameX;


@end
