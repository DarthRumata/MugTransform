//
//  Crop.h
//  BCMeshTransformViewDemo
//
//  Created by Stanislav on 11/12/15.
//  Copyright © 2015 Bartosz Ciechanowski. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Crop)

- (UIImage *)cropRectImage: (CGRect)cropRect;

@end
