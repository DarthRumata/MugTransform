//
//  YALEllipseTransformView.h
//  BCMeshTransformViewDemo
//
//  Created by Stanislav on 11/13/15.
//  Copyright © 2015 Bartosz Ciechanowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YALEllipseTransformView : UIView

- (void)renderWithImage: (UIImage *)coverImage doubleSided: (BOOL)doubleSided insets: (UIEdgeInsets)insets;
- (instancetype)initWithFrame: (CGRect)frame productImage: (UIImage *)productImage productRealSize: (CGSize)productSize;
- (void)flip;

@end
