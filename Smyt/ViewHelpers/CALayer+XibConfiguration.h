//
//  UIViewController+CALayer_XibConfiguration_m.h
//  Tipper
//
//  Created by SongXujie on 2/02/2016.
//  Copyright © 2016 SK8 PTY LTD. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface CALayer(XibConfiguration)

// This assigns a CGColor to borderColor.
@property(nonatomic, assign) UIColor* borderUIColor;

@end
