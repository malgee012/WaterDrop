//
//  MGWaterDorpView.h
//  WaterDrop
//
//  Created by acmeway on 2017/6/6.
//  Copyright © 2017年 acmeway. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MGWaterDorpView : UIView

/// 进度
@property (nonatomic, assign) float   progress;

/// 振幅
@property (nonatomic, assign) float   waveAmplitude;

/// 获取波幅最小值
- (CGFloat)amplitudeMin;

/// 波幅可调节幅度
- (CGFloat)amplitudeSpan;

- (void)startDrawPath;


@end
