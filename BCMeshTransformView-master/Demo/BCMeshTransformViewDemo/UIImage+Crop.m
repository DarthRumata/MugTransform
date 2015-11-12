//
//  Crop.m
//  BCMeshTransformViewDemo
//
//  Created by Stanislav on 11/12/15.
//  Copyright © 2015 Bartosz Ciechanowski. All rights reserved.
//

#import "UIImage+Crop.h"

@implementation UIImage (Crop)

- (UIImage *)cropRectImage: (CGRect)cropRect {
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, cropRect);
    
    // Create new cropped UIImage
    return [[UIImage alloc] initWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
}

@end
