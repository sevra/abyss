#import <Foundation/Foundation.h>
#import <curses.h>

#import "system.h"

#define rrot() (18)
#define rrad() (M_PI/rrot())

@protocol Display
	- (void) display;
	- (void) clear;
@end


@interface Curses : NSObject <Display> {
	WINDOW *win;
	int mx, my, cx, cy, itheta, iphi;
   double theta, phi;
   // theta = rotation about z-axis
   // phi = rotation about x-axis

   System *system;
   float scale;
   struct entity *following;
}

	@property (readwrite, nonatomic, retain) System *system;
	@property (readwrite, nonatomic) int mx, my, cx, cy;
	@property (readwrite, nonatomic) float scale;
	@property (readwrite, nonatomic) struct entity *following;

   - (id) init;
   - (id) initWithSystem:(System *)sys;
   - (void) getMaxYX;
	- (void) display;
	- (void) clear;
   - (bool) handleInput;
@end

