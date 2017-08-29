//
//  heartView.m
//  fitness
//
//  Created by 李帅 on 2016/11/23.
//  Copyright © 2016年 YunXiang. All rights reserved.
//

#import "heartView.h"

@interface heartView()
{
    NSTimer *_timer;//定时器
    BOOL isStart;
}
@property (nonatomic,strong) CAShapeLayer *shapeLayer;
@property (nonatomic,weak)CALayer * animationLayer;
@end

@implementation heartView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customView];
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumes) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}
- (void)resumes{
    
    if (self.animationLayer) {
        [self.animationLayer removeFromSuperlayer];
        [self setNeedsDisplay];
    }
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)customView
{
    CGFloat endAngle = M_PI_4;
    CGFloat radius = MIN(self.bounds.size.width * 0.25, self.bounds.size.height * 0.5) - 10;
    CGPoint center1 = CGPointMake(self.bounds.size.width * 0.5 + radius, self.bounds.size.height * 0.35);
    CGPoint center2 = CGPointMake(self.bounds.size.width * 0.5 - radius, self.bounds.size.height * 0.35);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center1 radius:radius startAngle:-M_PI endAngle:endAngle clockwise:1];
    [path addLineToPoint:CGPointMake(center1.x - radius, center1.y + radius * tan((M_PI - endAngle)*0.5))];
    [path addArcWithCenter:center2 radius:radius startAngle:M_PI - endAngle endAngle:0 clockwise:1];
    [path addClip];
    [path setLineWidth:1];
    [path setLineCapStyle:kCGLineCapRound];
     [[UIColor clearColor] setStroke];
    [path stroke];
    
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.frame = CGRectMake(0, 0, self.frame.size.width/2, self.frame.size.height/2);//设置shapeLayer的尺寸和位置
    self.shapeLayer.fillColor = [[UIColor redColor] colorWithAlphaComponent:1].CGColor;//填充颜色为ClearColor
    //设置线条的宽度和颜色
    //    self.shapeLayer.lineWidth = 1.0f;
    self.shapeLayer.strokeColor = [UIColor clearColor].CGColor;
    //让贝塞尔曲线与CAShapeLayer产生联系
    self.shapeLayer.path = path.CGPath;
    //添加并显示
    [self.layer addSublayer:self.shapeLayer];
}
- (void)animate:(BOOL)animate
{
    isStart = animate;
    if (animate) {
        if (!_timer) {
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(reDraw:) userInfo:nil repeats:NO] ;
        }else{
            [_timer invalidate];
            _timer = nil;
            [self.animationLayer removeFromSuperlayer];
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(reDraw:) userInfo:nil repeats:NO] ;
        }
    }else{
        [_timer invalidate];
        _timer = nil;
        [self.animationLayer removeFromSuperlayer];
        
    }
}
- (void)reDraw:(NSTimer*)t
{
    [self.animationLayer removeFromSuperlayer];
    [self setNeedsDisplay];
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if (isStart) {
        [[UIColor clearColor] setFill];
        UIRectFill(rect);
        NSInteger pulsingCount = 2;//雷达上波纹的条数
        double animationDuration = 3;//一组动画持续的时间，直接决定了动画运行快慢。
        
        CALayer * animationLayer = [[CALayer alloc]init];
        self.animationLayer = animationLayer;
        for (int i = 0; i < pulsingCount; i++) {
            CGFloat endAngle = M_PI_4;
            CGFloat radius = MIN(self.bounds.size.width * 0.4, self.bounds.size.height * 0.5) ;
            CGPoint center1 = CGPointMake(self.bounds.size.width * 0.5 + radius, self.bounds.size.height * 0.1 );
            CGPoint center2 = CGPointMake(self.bounds.size.width * 0.5 - radius, self.bounds.size.height * 0.1 );
            UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center1 radius:radius startAngle:-M_PI endAngle:endAngle clockwise:1];
            [path addLineToPoint:CGPointMake(center1.x - radius, center1.y + radius * tan((M_PI - endAngle)*0.5))];
            [path addArcWithCenter:center2 radius:radius startAngle:M_PI - endAngle endAngle:0 clockwise:1];
            [path addClip];
            [path setLineWidth:1];
            [path setLineCapStyle:kCGLineCapRound];
            // 设置描边色
            [[UIColor clearColor] setStroke];
            // 设置填充色
//            [[UIColor colorWithHex:0XFE6969] setFill];
            [path stroke];
            
            CAShapeLayer *shaperLayer = [CAShapeLayer layer];
            shaperLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);//设置shapeLayer的尺寸和位置

            shaperLayer.fillColor = [[UIColor redColor] colorWithAlphaComponent:1].CGColor;//填充颜色为ClearColor
            //设置线条的宽度和颜色
            //    self.shapeLayer.lineWidth = 1.0f;
            shaperLayer.strokeColor = [UIColor clearColor].CGColor;
            //让贝塞尔曲线与CAShapeLayer产生联系
            shaperLayer.path = path.CGPath;
   
            CAMediaTimingFunction * defaultCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            
            CAAnimationGroup * animationGroup = [[CAAnimationGroup alloc]init];
            animationGroup.fillMode = kCAFillModeBoth;
            //因为雷达中每个圈圈的大小不一致，故需要他们在一定的相位差的时刻开始运行。
            animationGroup.beginTime = CACurrentMediaTime() + (double)i * animationDuration/(double)pulsingCount;
            animationGroup.duration = animationDuration;//每个圈圈从生成到消失使用时常，也即动画组每轮动画持续时常
            animationGroup.repeatCount = HUGE_VAL;//表示动画组持续时间为无限大，也即动画无限循环。
            animationGroup.timingFunction = defaultCurve;
            
            //雷达圆圈初始大小以及最终大小比率。
            CABasicAnimation * scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            scaleAnimation.autoreverses = NO;
            scaleAnimation.fromValue = [NSNumber numberWithDouble:0.35];
            scaleAnimation.toValue = [NSNumber numberWithDouble:1.0];
            
            //雷达圆圈在n个运行阶段的透明度，n为数组长度。
            CAKeyframeAnimation * opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
            //雷达运行四个阶段不同的透明度。
            opacityAnimation.values = @[[NSNumber numberWithDouble:1.0],[NSNumber numberWithDouble:0.5],[NSNumber numberWithDouble:0.3],[NSNumber numberWithDouble:0.0]];
            //雷达运行的不同的四个阶段，为0.0表示刚运行，0.5表示运行了一半，1.0表示运行结束。
            opacityAnimation.keyTimes = @[[NSNumber numberWithDouble:0.0],[NSNumber numberWithDouble:0.25],[NSNumber numberWithDouble:0.5],[NSNumber numberWithDouble:1.0]];
            //将两组动画（大小比率变化动画，透明度渐变动画）组合到一个动画组。
            animationGroup.animations = @[scaleAnimation,opacityAnimation];
            
            [shaperLayer addAnimation:animationGroup forKey:@"pulsing"];
            [animationLayer addSublayer:shaperLayer];
        }
        [self.layer addSublayer:self.animationLayer];
        //以下部分为雷达中心的图。雷达圈圈也是从该图中心发出。
        CALayer * thumbnailLayer = [[CALayer alloc]init];
        thumbnailLayer.backgroundColor = [UIColor whiteColor].CGColor;
        CGRect thumbnailRect = CGRectMake(0, 0, 0, 0);
        thumbnailLayer.frame = thumbnailRect;
        thumbnailLayer.masksToBounds = YES;
        thumbnailLayer.borderColor = [UIColor whiteColor].CGColor;
        [self.layer addSublayer:thumbnailLayer];
    }

}


@end
