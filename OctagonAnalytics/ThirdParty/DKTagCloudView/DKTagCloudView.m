//
//  DKTagCloudView.m
//  DKTagCloudViewDemo
//
//  Created by ZhangAo on 14-11-18.
//  Copyright (c) 2014年 zhangao. All rights reserved.
//

#import "DKTagCloudView.h"

@interface DKTagCloudView ()

@property (nonatomic, strong) NSMutableArray *labels;

@end

@implementation DKTagCloudView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.userInteractionEnabled = YES;
    self.minFontSize = 14;
    self.maxFontSize = 60;
    self.font = [UIFont systemFontOfSize:rand() % self.maxFontSize + self.minFontSize];
    self.randomColors = @[
                          [UIColor blackColor],
                          [UIColor cyanColor],
                          [UIColor purpleColor],
                          [UIColor orangeColor],
                          [UIColor redColor],
                          [UIColor yellowColor],
                          [UIColor blueColor],
                          [UIColor grayColor],
                          [UIColor greenColor]
                          ];
}

- (UIColor *)randomColor {
    return self.randomColors[rand() % self.randomColors.count];
}

- (UIFont *)randomFont {
    return [self.font fontWithSize:rand() % self.maxFontSize + self.minFontSize];
//    return [UIFont systemFontOfSize:rand() % self.maxFontSize + self.minFontSize];
}

- (CGRect)randomFrameForLabel:(UILabel *)label {
    [label sizeToFit];
    CGFloat maxWidth = self.bounds.size.width - label.bounds.size.width;
    CGFloat maxHeight = self.bounds.size.height - label.bounds.size.height;
    if (maxWidth < 1) {
        maxWidth = 1;
    }
    
    if (maxHeight < 1) {
        maxHeight = 1;
    }

    return CGRectMake(random() % (NSInteger)maxWidth, random() % (NSInteger)maxHeight,
                      CGRectGetWidth(label.bounds), CGRectGetHeight(label.bounds));
}

- (BOOL)frameIntersects:(CGRect)frame {
    for (UILabel *label in self.labels) {
        if (CGRectIntersectsRect(frame, label.frame)) {
            return YES;
        }
    }
    return NO;
}

- (NSMutableArray *)labels {
    if (_labels == nil) {
        _labels = [NSMutableArray new];
    }
    return _labels;
}

- (void)generate {
    [self.labels makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.labels removeAllObjects];
    
    int i = 0;
    for (NSString *title in self.titls) {
        assert([title isKindOfClass:[NSString class]]);
        
        UILabel *label = [[UILabel alloc] init];
        label.tag = i++;
        label.text = title;
        label.textColor = [self randomColor];
        label.font = [self randomFont];
        
        do {
            CGFloat updatedFontSize = label.font.pointSize-1;
            if (updatedFontSize <= self.minFontSize) {
                updatedFontSize = self.minFontSize;
                break;
            }
            label.font = [label.font fontWithSize:updatedFontSize];
            label.frame = [self randomFrameForLabel:label];
        } while ([self frameIntersects:label.frame]);
        
        if ([self frameIntersects:label.frame]) {
            continue;
        }
        
        [self.labels addObject:label];
        [self addSubview:label];

        label.transform = CGAffineTransformMakeScale(0.1, 0.1);
        [UIView animateWithDuration:0.5 animations:^{
            label.transform = CGAffineTransformMakeScale(1.0, 1.0);

        } completion:nil];
        
        UITapGestureRecognizer *tagGestue = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        [label addGestureRecognizer:tagGestue];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        [label addGestureRecognizer:longPress];

        label.userInteractionEnabled = YES;
    }
}

- (void)handleGesture:(UIGestureRecognizer*)gestureRecognizer {
    UILabel *label = (UILabel *)gestureRecognizer.view;
    if (self.tagClickBlock) {
        self.tagClickBlock(label.text,label.tag);
    }
}

- (void)handleLongPress:(UIGestureRecognizer*)gestureRecognizer {
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan){
        UILabel *label = (UILabel *)gestureRecognizer.view;
        if (self.longPressBlock) {
            self.longPressBlock(label.text,label.tag);
        }
    }
}

@end
