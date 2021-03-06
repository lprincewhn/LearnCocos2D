/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2009 Jason Booth
 * Copyright (c) 2013 Nader Eloshaiker
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */


/*
 * Elastic, Back and Bounce actions based on code from:
 * http://github.com/NikhilK/silverlightfx/
 *
 * by http://github.com/NikhilK
 */

#import "CCActionEase.h"

#ifndef M_PI_X_2
#define M_PI_X_2 (float)M_PI * 2.0f
#endif

#pragma mark EaseAction

//
// EaseAction
//
@implementation CCActionEase

@synthesize inner=_inner;

+(id) actionWithAction: (CCActionInterval*) action
{
	return [[self alloc] initWithAction: action];
}

-(id) initWithAction: (CCActionInterval*) action
{
	NSAssert( action!=nil, @"Ease: arguments must be non-nil");

	if( (self=[super initWithDuration: action.duration]) )
		_inner = action;

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone:zone] initWithAction:[_inner copy]];
	return copy;
}

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[_inner startWithTarget:_target];
}

-(void) stop
{
	[_inner stop];
	[super stop];
}

-(void) update: (CCTime) t
{
	[_inner update: t];
}

-(CCActionInterval*) reverse
{
	return [[self class] actionWithAction: [_inner reverse]];
}
@end


#pragma mark -
#pragma mark EaseRate

//
// EaseRateAction
//
@implementation CCActionEaseRate
@synthesize rate=_rate;
+(id) actionWithAction: (CCActionInterval*) action rate:(float)rate
{
	return [[self alloc] initWithAction: action rate:rate];
}

-(id) initWithAction: (CCActionInterval*) action rate:(float)rate
{
	if( (self=[super initWithAction:action ]) )
		self.rate = rate;

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone:zone] initWithAction:[_inner copy] rate:_rate];
	return copy;
}


-(CCActionInterval*) reverse
{
	return [[self class] actionWithAction: [_inner reverse] rate:1/_rate];
}
@end

//
// EeseIn
//
@implementation CCActionEaseIn
-(void) update: (CCTime) t
{
	[_inner update: powf(t,_rate)];
}
@end

//
// EaseOut
//
@implementation CCActionEaseOut
-(void) update: (CCTime) t
{
	[_inner update: powf(t,1/_rate)];
}
@end

//
// EaseInOut
//
@implementation CCActionEaseInOut
-(void) update: (CCTime) t
{
	t *= 2;
	if (t < 1) {
		[_inner update: 0.5f * powf (t, _rate)];
    }
	else {
		[_inner update: 1.0f - 0.5f * powf(2-t, _rate)];
    }
}

// InOut and OutIn are symmetrical
-(CCActionInterval*) reverse
{
	return [[self class] actionWithAction: [_inner reverse] rate:_rate];
}

@end

#pragma mark -
#pragma mark EaseElastic actions

//
// EaseElastic
//
@implementation CCActionEaseElastic

@synthesize period = _period;

+(id) actionWithAction: (CCActionInterval*) action
{
	return [[self alloc] initWithAction:action period:0.3f];
}

+(id) actionWithAction: (CCActionInterval*) action period:(float)period
{
	return [[self alloc] initWithAction:action period:period];
}

-(id) initWithAction: (CCActionInterval*) action
{
	return [self initWithAction:action period:0.3f];
}

-(id) initWithAction: (CCActionInterval*) action period:(float)period
{
	if( (self=[super initWithAction:action]) )
		_period = period;

	return self;
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAction *copy = [[[self class] allocWithZone:zone] initWithAction:[_inner copy] period:_period];
	return copy;
}

-(CCActionInterval*) reverse
{
	NSAssert(NO,@"Override me");
	return nil;
}

@end

//
// EaseElasticIn
//

@implementation CCActionEaseElasticIn
-(void) update: (CCTime) t
{
	CCTime newT = 0;
	if (t == 0 || t == 1)
		newT = t;

	else {
		float s = _period / 4;
		t = t - 1;
		newT = -powf(2, 10 * t) * sinf( (t-s) *M_PI_X_2 / _period);
	}
	[_inner update:newT];
}

- (CCActionInterval*) reverse
{
	return [CCActionEaseElasticOut actionWithAction: [_inner reverse] period:_period];
}

@end

//
// EaseElasticOut
//
@implementation CCActionEaseElasticOut

-(void) update: (CCTime) t
{
	CCTime newT = 0;
	if (t == 0 || t == 1) {
		newT = t;

	} else {
		float s = _period / 4;
		newT = powf(2, -10 * t) * sinf( (t-s) *M_PI_X_2 / _period) + 1;
	}
	[_inner update:newT];
}

- (CCActionInterval*) reverse
{
	return [CCActionEaseElasticIn actionWithAction: [_inner reverse] period:_period];
}

@end

//
// EaseElasticInOut
//
@implementation CCActionEaseElasticInOut
-(void) update: (CCTime) t
{
	CCTime newT = 0;

	if( t == 0 || t == 1 )
		newT = t;
	else {
		t = t * 2;
		if(! _period )
			_period = 0.3f * 1.5f;
		CCTime s = _period / 4;

		t = t -1;
		if( t < 0 )
			newT = -0.5f * powf(2, 10 * t) * sinf((t - s) * M_PI_X_2 / _period);
		else
			newT = powf(2, -10 * t) * sinf((t - s) * M_PI_X_2 / _period) * 0.5f + 1;
	}
	[_inner update:newT];
}

- (CCActionInterval*) reverse
{
	return [CCActionEaseElasticInOut actionWithAction: [_inner reverse] period:_period];
}

@end

#pragma mark -
#pragma mark EaseBounce actions

//
// EaseBounce
//
@implementation CCActionEaseBounce
-(CCTime) bounceTime:(CCTime) t
{
	if (t < 1 / 2.75) {
		return 7.5625f * t * t;
	}
	else if (t < 2 / 2.75) {
		t -= 1.5f / 2.75f;
		return 7.5625f * t * t + 0.75f;
	}
	else if (t < 2.5 / 2.75) {
		t -= 2.25f / 2.75f;
		return 7.5625f * t * t + 0.9375f;
	}

	t -= 2.625f / 2.75f;
	return 7.5625f * t * t + 0.984375f;
}
@end

//
// EaseBounceIn
//

@implementation CCActionEaseBounceIn

-(void) update: (CCTime) t
{
	CCTime newT = t;
	// prevents rounding errors
	if( t !=0 && t!=1)
		newT = 1 - [self bounceTime:1-t];

	[_inner update:newT];
}

- (CCActionInterval*) reverse
{
	return [CCActionEaseBounceOut actionWithAction: [_inner reverse]];
}

@end

@implementation CCActionEaseBounceOut

-(void) update: (CCTime) t
{
	CCTime newT = t;
	// prevents rounding errors
	if( t !=0 && t!=1)
		newT = [self bounceTime:t];

	[_inner update:newT];
}

- (CCActionInterval*) reverse
{
	return [CCActionEaseBounceIn actionWithAction: [_inner reverse]];
}

@end

@implementation CCActionEaseBounceInOut

-(void) update: (CCTime) t
{
	CCTime newT;
	// prevents possible rounding errors
	if( t ==0 || t==1)
		newT = t;
	else if (t < 0.5) {
		t = t * 2;
		newT = (1 - [self bounceTime:1-t] ) * 0.5f;
	} else
		newT = [self bounceTime:t * 2 - 1] * 0.5f + 0.5f;

	[_inner update:newT];
}
@end

#pragma mark -
#pragma mark Ease Back actions

//
// EaseBackIn
//
@implementation CCActionEaseBackIn

-(void) update: (CCTime) t
{
	CCTime overshoot = 1.70158f;
	[_inner update: t * t * ((overshoot + 1) * t - overshoot)];
}

- (CCActionInterval*) reverse
{
	return [CCActionEaseBackOut actionWithAction: [_inner reverse]];
}
@end

//
// EaseBackOut
//
@implementation CCActionEaseBackOut
-(void) update: (CCTime) t
{
	CCTime overshoot = 1.70158f;

	t = t - 1;
	[_inner update: t * t * ((overshoot + 1) * t + overshoot) + 1];
}

- (CCActionInterval*) reverse
{
	return [CCActionEaseBackIn actionWithAction: [_inner reverse]];
}
@end

//
// EaseBackInOut
//
@implementation CCActionEaseBackInOut

-(void) update: (CCTime) t
{
	CCTime overshoot = 1.70158f * 1.525f;

	t = t * 2;
	if (t < 1)
		[_inner update: (t * t * ((overshoot + 1) * t - overshoot)) / 2];
	else {
		t = t - 2;
		[_inner update: (t * t * ((overshoot + 1) * t + overshoot)) / 2 + 1];
	}
}
@end
