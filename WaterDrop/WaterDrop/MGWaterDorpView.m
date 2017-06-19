//
//  MGWaterDorpView.m
//  WaterDrop
//
//  Created by acmeway on 2017/6/6.
//  Copyright © 2017年 acmeway. All rights reserved.
//

#import "MGWaterDorpView.h"

static CGFloat amplitude_min = 16.0;  //波幅最小值
static CGFloat amplitude_span = 26.0;//波幅可调节幅度

static CGFloat cycle = 1.0;//循环次数,

static CGFloat waveMoveSpan = 5.0;//波浪移动单位跨度,
static CGFloat animationUnitTime = 0.08;//重画单位时间,

CGFloat term = 0.0;  //周期（在代码中重新计算）,
CGFloat phasePosition = 0.0; //相位必须为0(画曲线机制局限),
CGFloat amplitude = 29.0;//波幅
CGFloat position = 40.0;//X轴所在的Y坐标（在代码中重新计算(即水深度)

BOOL waving = YES;

// 底部半圆弧半径
#define CircleRadius 70
// 前景色
#define heavyColor [UIColor colorWithHex:@"ffa854"]
// 后面色
#define lightColor [UIColor colorWithHex:@"ffb658"]

#define MGWidth  self.bounds.size.width
#define MGHeight self.bounds.size.height

@interface MGWaterDorpView ()<CAAnimationDelegate>

@property (nonatomic, assign) CGFloat originX; //X坐标起点

@property (nonatomic, weak) CAShapeLayer *lineChartLayer;

@end
@implementation MGWaterDorpView


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        
        [self animationWaterWave];
        
    }
    return self;
}

- (void)animationWaterWave
{
    self.originX = 0;
    self.progress = 0.5;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        CGFloat tempOriginX =  self.originX;
        
        while (waving) {
            
            if (self.originX <= tempOriginX - term)
            {
                self.originX = tempOriginX - waveMoveSpan;
            } else
            {
                self.originX -= waveMoveSpan;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self setNeedsDisplay];
            });
            
            [NSThread sleepForTimeInterval:animationUnitTime];
        }
    });

    
}
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    position = (1 - self.progress) * self.bounds.size.height;
    
    [self setupShapeLayer];

    [self drawWaveWaterWithOriginX:self.originX - term / 5 fillColor:lightColor];

    [self drawWaveWaterWithOriginX:self.originX fillColor:heavyColor];
    
//    [self setupShapeLayer];
    
}

/**  （循环画波浪）
 *  画水波
 *
 @param originX 起始位置
 @param fillColor 填充色
 */
- (void)drawWaveWaterWithOriginX:(double)originX fillColor:(UIColor *)fillColor
{
    UIBezierPath *curvePath = [UIBezierPath bezierPath];
    
    [curvePath moveToPoint:CGPointMake(originX, position)];
    
    CGFloat tempPoint = originX;
    
    // (2 * cycle)即可充满屏幕，即一个循环,为了移动画布使波浪移动，我们要画2个循环
    int tempValue = [self roundingWithCount:(2 * cycle) * 2];
    
    for (int i = 0; i < tempValue; i++) {
        
        // 二次贝塞尔曲线
        [curvePath addQuadCurveToPoint:[self keyPointWith:tempPoint + term / 2 originX:originX]
                          controlPoint:[self keyPointWith:tempPoint + term / 4 originX:originX]];
        
        tempPoint += term / 2;
    }
    
    // 关闭路径
    [curvePath addLineToPoint:CGPointMake(curvePath.currentPoint.x, self.bounds.size.height)];
    [curvePath addLineToPoint:CGPointMake((CGFloat)originX, self.bounds.size.height)];
    
    [curvePath closePath];
    
    [fillColor setFill];
    curvePath.lineWidth = 10;
    
    [curvePath fill];

}


/**
 * 水滴图层路径
 */
- (void)setupShapeLayer
{
    // 修改默认线条颜色
    [[UIColor colorWithHex:@"FF8854"] set];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    // 设置起点
    [path moveToPoint:CGPointMake(CircleRadius * 2, 0)];
    
    // 添加第一条 二次贝塞尔曲线
    [path addQuadCurveToPoint:CGPointMake(CircleRadius * 1, 100) controlPoint:CGPointMake(3 + CircleRadius * 1, 55)];
    
    // 添加半圆路径
    [path addArcWithCenter:CGPointMake(CircleRadius * 2, CircleRadius + 30) radius:CircleRadius startAngle:-M_PI endAngle:0 clockwise:NO];
    
    // 添加第二条 二次贝塞尔曲线
    [path addQuadCurveToPoint:CGPointMake(CircleRadius * 2, 0) controlPoint:CGPointMake(CircleRadius * 2 + (CircleRadius - 3), 55)];
    
    CAShapeLayer *lineChartLayer = [CAShapeLayer layer];
    self.lineChartLayer = lineChartLayer;
    lineChartLayer.path = path.CGPath;
    lineChartLayer.fillColor = [[UIColor clearColor] CGColor];
    lineChartLayer.strokeColor = [UIColor colorWithHex:@"FF8854"].CGColor;
    
    // 设置路径宽度为0，使线条不显示出来
    lineChartLayer.lineWidth = 0;
    lineChartLayer.lineCap = kCALineCapRound;
    
    // 路径关闭渲染超出的部分剪切掉（这里指波浪）
    [path stroke];
    [path addClip];
    
    // 修改默认线条颜色
//    [[UIColor colorWithHexString:@"FF8854" alpha:1] setStroke];
    
    
    [self.layer addSublayer:lineChartLayer];
    
    [self drawGradientBackgroundViewWithlayer:lineChartLayer];
    
}


/**
 绘制渐变水滴轮廓

 @param shapeLayer 路径shapeLayer
 */
- (void)drawGradientBackgroundViewWithlayer:(CAShapeLayer *)shapeLayer
{
    
    CALayer *gradientLayer = [CALayer layer];
    gradientLayer.frame = self.bounds;
    
    CAGradientLayer *gradientLayer1 = [CAGradientLayer layer];
    gradientLayer1.frame = CGRectMake(MGWidth/2.0, 0, MGWidth/2.0,  MGHeight/2.0);
    gradientLayer1.colors = @[(__bridge id)[UIColor colorWithWhite:1 alpha:0.8].CGColor,
                               (__bridge id)[UIColor colorWithWhite:1 alpha:0.6].CGColor];
    gradientLayer1.startPoint = CGPointMake(0, 0);
    gradientLayer1.endPoint = CGPointMake(0, 1);
    
    CAGradientLayer *gradientLayer2 = [CAGradientLayer layer];
    gradientLayer2.frame = CGRectMake(MGWidth/2.0, MGHeight/2.0, MGWidth/2.0,  MGHeight/2.0);
    gradientLayer2.colors = @[(__bridge id)[UIColor colorWithWhite:1 alpha:0.6].CGColor,
                               (__bridge id)[UIColor colorWithWhite:1 alpha:0.4].CGColor];
    
    [gradientLayer2 setLocations:@[@0.3, @0.8,@1]];
    gradientLayer2.startPoint = CGPointMake(0, 0);
    gradientLayer2.endPoint = CGPointMake(0, 1);
    
    CAGradientLayer *gradientLayer3 = [CAGradientLayer layer];
    gradientLayer3.frame = CGRectMake(0, MGHeight/2.0, MGWidth/2.0,  MGHeight/2.0);
    gradientLayer3.colors = @[(__bridge id)[UIColor colorWithWhite:1 alpha:0.27].CGColor,
                              (__bridge id)[UIColor colorWithWhite:1 alpha:0.4].CGColor];
    
    [gradientLayer3 setLocations:@[@0.2, @0.8]];
    gradientLayer3.startPoint = CGPointMake(0.5, 0);
    gradientLayer3.endPoint = CGPointMake(0.5, 1);
    
    CAGradientLayer *gradientLayer4 = [CAGradientLayer layer];
    gradientLayer4.frame = CGRectMake(0, 0, MGWidth/2.0,  MGHeight/2.0);
    gradientLayer4.colors = @[(__bridge id)[UIColor colorWithWhite:1 alpha:0.18].CGColor,
                              (__bridge id)[UIColor colorWithWhite:1 alpha:0.27].CGColor];
    
    [gradientLayer4 setLocations:@[@0.2, @0.8]];
    gradientLayer4.startPoint = CGPointMake(0.5, 1);
    gradientLayer4.endPoint = CGPointMake(0.5, 0);

    
    // 绘制第一个渐变图层
    [gradientLayer addSublayer:gradientLayer1];
    
    [gradientLayer addSublayer:gradientLayer2];
    
    [gradientLayer addSublayer:gradientLayer3];
    
    [gradientLayer addSublayer:gradientLayer4];
    
    [self.layer addSublayer:gradientLayer];
    
    [gradientLayer setMask:shapeLayer];
    
}

/** 动画开始 */
- (void)startDrawPath
{
    // 设置路径宽度为5，使其能够显示出来
    self.lineChartLayer.lineWidth = 5;

    // 设置动画的相关属性
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 2.5;
    pathAnimation.repeatCount = 1;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnimation.delegate = self;
    
    [self.lineChartLayer addAnimation:pathAnimation forKey:@"strokeEnd"];
    
}

/** 动画结束 */
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    CALayer *pointLayer = [CALayer layer];
    
    pointLayer.frame = CGRectMake(MGWidth / 2.0 - 3.5, -3.5, 7, 7);
    pointLayer.backgroundColor = [UIColor whiteColor].CGColor;
    pointLayer.cornerRadius = 3.5;
    pointLayer.masksToBounds = YES;
    
    pointLayer.shadowOffset =  CGSizeMake(10, 10);
    pointLayer.shadowOpacity = 0.8;
    pointLayer.shadowColor =  [UIColor blueColor].CGColor;
    
    [self.layer addSublayer:pointLayer];
}


- (void)setWaveAmplitude:(float)waveAmplitude
{
    amplitude = waveAmplitude;
    
    [self setNeedsDisplay];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self animationWaterWave];
}

- (CGFloat)amplitudeMin
{
    return amplitude_min;
}
- (CGFloat)amplitudeSpan
{
    return amplitude_span;
}

- (CGPoint)keyPointWith:(double)viewX originX:(double)originX
{
    return CGPointMake(viewX, [self columnYPoint:viewX - originX]);
}

- (double)columnYPoint:(double)viewX
{
    //三角正弦函数
    double result = amplitude * sin((2 * M_PI / term) * viewX + phasePosition);
    
    return result + position;
}
//四舍五入
- (int)roundingWithCount:(CGFloat)value
{
    int tempInt = (int)value;
    
    CGFloat tempDouble = tempInt + 0.5;
    
    if( value > tempDouble )
    {
        return tempInt + 1;
        
    } else {
        return tempInt;
    }
    
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    term = self.bounds.size.width / cycle;
    
}
- (void)removeFromSuperview
{
    [super removeFromSuperview];
    
    waving = NO;
}


@end
