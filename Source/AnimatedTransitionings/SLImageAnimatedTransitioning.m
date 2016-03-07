//
//  SLImageAnimatedTransitioning.m
//  Calico
//
//  Created by LingFeng-Li on 3/3/16.
//  Copyright © 2016 Soul-Beats. All rights reserved.
//

#import "SLImageAnimatedTransitioning.h"

@implementation SLImageAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.26;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *containerView = [transitionContext containerView];
    
    CGRect finalFrameForToVC = [transitionContext finalFrameForViewController:toVC];
    toView.frame = finalFrameForToVC;
    [toView layoutIfNeeded];
    
    UIImageView *fromImageView = nil;
    if ([fromVC conformsToProtocol:@protocol(SLTransitioningDelegate)] && [fromVC respondsToSelector:@selector(transitioningInfoAsFrom:context:)]) {
        fromImageView = [[(id<SLTransitioningDelegate>)fromVC transitioningInfoAsFrom:self context:transitionContext] valueForKey:SLImageAnimatedTransitioningInfoImageViewKey];
    }
    UIImageView *toImageView = nil;
    NSValue *endFrameForIV = nil;
    if ([toVC conformsToProtocol:@protocol(SLTransitioningDelegate)] && [toVC respondsToSelector:@selector(transitioningInfoAsTo:context:)]) {
        toImageView = [[(id<SLTransitioningDelegate>)toVC transitioningInfoAsTo:self context:transitionContext] valueForKey:SLImageAnimatedTransitioningInfoImageViewKey];
        endFrameForIV = [[(id<SLTransitioningDelegate>)toVC transitioningInfoAsTo:self context:transitionContext] valueForKey:SLImageAnimatedTransitioningInfoEndFrameForImageViewKey];
    }
    
    if (fromImageView && toImageView && fromImageView.superview && toImageView.superview && endFrameForIV) {
        if (self.operation == UINavigationControllerOperationPush || self.operation == UINavigationControllerOperationPop) {
            CGFloat maskViewAlpha = 0.2;
            UIView *maskViewForFromView = [[UIView alloc] init];
            maskViewForFromView.backgroundColor = [UIColor blackColor];
            maskViewForFromView.frame = fromView.bounds;
            [fromView addSubview:maskViewForFromView];
            maskViewForFromView.alpha = 0.0;
            
            UIView *maskViewForToView = [[UIView alloc] init];
            maskViewForToView.backgroundColor = [UIColor blackColor];
            maskViewForToView.frame = toView.bounds;
            [toView addSubview:maskViewForToView];
            maskViewForToView.alpha = maskViewAlpha;
            
            if (self.operation == UINavigationControllerOperationPush) {
                CGRect frame = toView.frame;
                frame.origin.x = fromView.frame.origin.x + fromView.frame.size.width;
                toView.frame = frame;
                [containerView addSubview:toView];
            } else if (self.operation == UINavigationControllerOperationPop) {
                CGRect frame = toView.frame;
                frame.origin.x = fromView.frame.origin.x - frame.size.width / 3.0;
                toView.frame = frame;
                [containerView insertSubview:toView belowSubview:fromView];
            }
            
            UIImageView *imageView = [self copyOfImageView:toImageView];
            imageView.frame = [containerView convertRect:fromImageView.frame fromView:fromImageView.superview] ;
            [containerView addSubview:imageView];
            
            fromImageView.hidden = YES;
            toImageView.hidden = YES;
            
            [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations: ^{
                maskViewForFromView.alpha = maskViewAlpha;
                maskViewForToView.alpha = 0.0;
                
                toView.frame = finalFrameForToVC;
                
                if (self.operation == UINavigationControllerOperationPush) {
                    CGRect frame = fromView.frame;
                    frame.origin.x = frame.origin.x - frame.size.width / 3.0;
                    fromView.frame = frame;
                } else if (self.operation == UINavigationControllerOperationPop) {
                    CGRect frame = fromView.frame;
                    frame.origin.x = frame.origin.x + frame.size.width;
                    fromView.frame = frame;
                }
                
                imageView.frame = [containerView convertRect:[endFrameForIV CGRectValue] fromView:toImageView.superview];
            } completion:^(BOOL finished) {
                [maskViewForFromView removeFromSuperview];
                [maskViewForToView removeFromSuperview];
                
                fromImageView.hidden = NO;
                toImageView.hidden = NO;
                [imageView removeFromSuperview];
                [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
            }];
        } else {
            [super animateTransition:transitionContext];
        }
    } else {
        [super animateTransition:transitionContext];
    }
}

- (UIImageView *)copyOfImageView:(UIImageView *)imageView {
    UIImageView *dummyImageView = [[UIImageView alloc] init];
    dummyImageView.contentMode = imageView.contentMode;
    dummyImageView.image = imageView.image;
    dummyImageView.clipsToBounds = imageView.clipsToBounds;
    dummyImageView.layer.cornerRadius = imageView.layer.cornerRadius;
    dummyImageView.layer.borderColor = imageView.layer.borderColor;
    dummyImageView.layer.borderWidth = imageView.layer.borderWidth;
    return dummyImageView;
}
@end
