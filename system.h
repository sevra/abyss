#import <math.h>

#import "linkedlist.h"

struct vector {
	double i, j, k;
};

struct entity {
	struct link link;

	double mass, density;
	struct vector accel, vel, pos;
   BOOL autofree;
};

struct entity * create_entity(double mass, double density, 
                              double x, double y, double z, 
                              double i, double j, double k);

@protocol PhysicsEngine
   - (void) getForces;
	- (void) applyForces;
@end

@interface System : LinkedList <PhysicsEngine> {
	double gravity, mass;
   struct vector vel;
}
	@property (readwrite, nonatomic) double gravity;

	- (id) init;
	- (id) initWithGravity:(double)gravity;
   - (void) addEntity:(struct entity *)ent;
   - (void) addEntityWithMass:(double)mass density:(double)density
                      atX:(double)x y:(double)y z:(double)z 
                      movingI:(double)i j:(double)j k:(double)k;
	- (void) getForces;
   - (void) applyForces;
   - (void) updateSysVel:(struct entity *)ent;
   - (void) compensateSystemVelocity;
@end
