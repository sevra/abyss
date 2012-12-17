#import "system.h"

struct entity * create_entity(double mass, double density, 
                              double x, double y, double z, 
                              double i, double j, double k) {
   struct entity *ent = malloc(sizeof(*ent));
   memset(ent, 0, sizeof(*ent));
   ent->mass = mass;
   ent->density = density;
   ent->pos = (struct vector) { .i = x, .j = y, .k = z };
   ent->vel = (struct vector) { .i = i, .j = j, .k = k };
   ent->autofree = NO;
   return ent;
}

inline void vset(struct vector *a, double scalar) {
   a->i = a->j = a->k = scalar;
}

inline void vaddv(struct vector *a, struct vector *b, struct vector *res) {
   res->i = a->i + b->i;
   res->j = a->j + b->j;
   res->k = a->k + b->k;
}

inline void vsubv(struct vector *a, struct vector *b, struct vector *res) {
   res->i = a->i - b->i;
   res->j = a->j - b->j;
   res->k = a->k - b->k;
}

inline void vmul(struct vector *a, double scalar, struct vector *res) {
   res->i = a->i * scalar;
   res->j = a->j * scalar;
   res->k = a->k * scalar;
}

inline void vdiv(struct vector *a, double scalar, struct vector *res) {
   res->i = a->i / scalar;
   res->j = a->j / scalar;
   res->k = a->k / scalar;
}

inline double vpows(struct vector *a, double scalar) {
   return pow(a->i, scalar) + pow(a->j, scalar) + pow(a->k, scalar);
}

inline struct vector * vabs(struct vector *a) {
   a->i = fabs(a->i);
   a->j = fabs(a->j);
   a->k = fabs(a->k);
   return a;
}

inline void vclone(struct vector *a, struct vector *res) {
   res->i = a->i;
   res->j = a->j;
   res->k = a->k;
}

@implementation System
	@synthesize gravity;

	- (id) initWithGravity:(double)G {
		if((self = [super init]))
         self->gravity = G;
		
		return self;
	}

	- (id) init {
		return [self initWithGravity:0.5];
	}

   - (void) dealloc {
      struct entity *u = (struct entity *)self->head;
      while(u) {
         free([self removeLink:(struct link *)u]);
         u = (struct entity *)self->head;
      }
      [super dealloc];
   }

   - (void) addEntityWithMass:(double)m density:(double)d
                      atX:(double)x y:(double)y z:(double)z 
                      movingI:(double)i j:(double)j k:(double)k {
      struct entity *ent = create_entity(m, d, x, y, z, i, j, k);
      ent->autofree = YES;
      [self addEntity:ent];
   }

   - (void) addEntity:(struct entity *)ent {
      [self appendLink:(struct link *)ent];
      [self updateSysVel:ent];
   }

	- (void) getForces {
		struct entity *u, *v;
		u = (struct entity *)self->head;
		
		while(u) {
			v = (struct entity *)self->head;
			while(v) {
				if(u == v) {
               v = (struct entity *)v->link.next;
					continue;
            }
            
            struct vector delta, rsq;
            vsubv(&v->pos, &u->pos, &delta); // u - v
            vclone(&delta, &rsq);
            vmul(&delta, self->gravity * v->mass, &delta); // Gm(u - v)
            vdiv(&delta, vpows(vabs(&rsq), 3), &delta); // Gm(u - v) / |u - v|^3
            vaddv(&u->accel, &delta, &u->accel);
            v = (struct entity *)v->link.next;
			}
         u = (struct entity *)u->link.next;
		}
	}

   - (void) applyForces {
      struct entity *u;
      u = (struct entity *)self->head;
      while(u) {
         vaddv(&u->vel, &u->accel, &u->vel);
         vset(&u->accel, 0);
         vaddv(&u->pos, &u->vel, &u->pos);
         u = (struct entity *)u->link.next;
      }
   }

   - (void) updateSysVel:(struct entity *)ent {
      struct vector tmp;
      self->mass += ent->mass;
      vmul(&ent->vel, ent->mass/self->mass, &tmp);
      vaddv(&self->vel, &tmp, &self->vel);
   }

   - (void) compensateSystemVelocity {
      struct entity *u;
      u = (struct entity *)self->head;
      while(u) {
         vsubv(&u->vel, &self->vel, &u->vel);
         u = (struct entity *)u->link.next;
      }
   }
@end
