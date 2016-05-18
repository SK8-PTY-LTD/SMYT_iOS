//
//  UIViewController+CALayer_XibConfiguration_m.m
//  Tipper
//
//  Created by SongXujie on 2/02/2016.
//  Copyright © 2016 SK8 PTY LTD. All rights reserved.
//

#import "CALayer+XibConfiguration.h"

@implementation CALayer(XibConfiguration)

-(void)setBorderUIColor:(UIColor*)color
{
    self.borderColor = color.CGColor;
}

-(UIColor*)borderUIColor
{
    return [UIColor colorWithCGColor:self.borderColor];
}

@end
