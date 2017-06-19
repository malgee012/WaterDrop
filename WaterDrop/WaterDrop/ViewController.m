//
//  ViewController.m
//  WaterDrop
//
//  Created by acmeway on 2017/6/6.
//  Copyright © 2017年 acmeway. All rights reserved.
//

#import "ViewController.h"
#import "MGWaterDorpView.h"

@interface ViewController ()

@property (nonatomic, weak)  MGWaterDorpView *waterDropView ;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithHex:@"FF8854"];
    
    
    UILabel * progressLbl = [[UILabel alloc] initWithFrame:CGRectMake(30, 420, kScreenWidth - 30, 20)];
    progressLbl.text = @"水深";
    [self.view addSubview:progressLbl];
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(20, 450, kScreenWidth - 20 * 2, 30)];
    slider.tag = 1;
    [self.view addSubview:slider];
    
    UILabel * waveAmplitudeLbl = [[UILabel alloc] initWithFrame:CGRectMake(30, 500, kScreenWidth - 30, 20)];
    waveAmplitudeLbl.text = @"振幅";
    [self.view addSubview:waveAmplitudeLbl];
    
    UISlider *slider2 = [[UISlider alloc] initWithFrame:CGRectMake(20, 540, kScreenWidth - 20 * 2, 30)];
    slider2.tag = 2;
    [self.view addSubview:slider2];

    [slider addTarget:self action:@selector(slideView:) forControlEvents:UIControlEventValueChanged];
    [slider2 addTarget:self action:@selector(slideView:) forControlEvents:UIControlEventValueChanged];
    
    UIButton * btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 600, kScreenWidth, 40)];
    [btn setTitle:@"开始动画" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
    [self.view addSubview:btn];
    
    [btn addTarget:self action:@selector(clickBtn) forControlEvents:UIControlEventTouchUpInside];
    
    
    MGWaterDorpView *waterDropView = [[MGWaterDorpView alloc] initWithFrame:CGRectMake((kScreenWidth - 140 - 70 *2 ) / 2.0,
                                                                                       200,
                                                                                       140 + 70 *2 ,
                                                                                       170 + 3)];
    
    self.waterDropView = waterDropView;
    

    waterDropView.backgroundColor = [UIColor colorWithHex:@"FF8854"];
    
    [self.view addSubview:waterDropView];
    
    
    
}
- (void)slideView:(UISlider *)slider
{
    if (slider.tag == 1)
    {
        
        self.waterDropView.progress = slider.value;
    }
    else
    {
        
        self.waterDropView.waveAmplitude = self.waterDropView.amplitudeMin + (double)slider.value * self.waterDropView.amplitudeSpan;
    }
    
}

- (void)clickBtn
{
    [self.waterDropView startDrawPath];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
