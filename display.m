#import "display.h"

@implementation Curses
	@synthesize mx, my, cx, cy;
   @synthesize scale;
   @synthesize system;
   @synthesize following;

   - (id) init {
      if((self = [super init])) {
         initscr();
         cbreak();
         noecho();
         curs_set(false);
         nodelay(stdscr, true);
         keypad(stdscr, true);
         self->win = stdscr;
         [self getMaxYX];

         self->scale = 0.8;
         self->theta = 0;
         self->phi = 0;
         self->following = NULL;
      }
      return self;
   }

   - (id) initWithSystem:(System *)sys {
      if((self = [self init]))
         [self setSystem:sys];
      return self;
   }
	
   - (void) getMaxYX {
      getmaxyx(self->win, self->my, self->mx);
      self->cx = self->mx/2;
      self->cy = self->my/2;
   }

	- (void) clear {
      clear();
	}

   - (void) refresh {
      refresh();
   }

   - (void) dealloc {
      endwin();
      [super dealloc];
   }
   
   - (double) theta {
      return self->theta;
   }

   - (void) setTheta:(int) i {
      self->itheta = i;
      self->theta = i * rrad();
   }

   - (void) incThetaBy:(int) i {
      self->itheta = (self->itheta + i) % (rrot() * 2);
      self->theta = self->itheta * rrad();
   }
    
   - (double) phi {
      return self->phi;
   }

   - (void) setPhi:(int) i {
      self->iphi = i;
      self->phi = i * rrad();
   }

   - (void) incPhiBy:(int) i {
      self->iphi = (self->iphi + i) % (rrot() * 2);
      self->phi = self->iphi * rrad();
   }  

   - (double) xvar:(struct entity *)ent {
      return cos(theta) * ent->pos.i + sin(theta) * ent->pos.j;
   }

   - (double) yvar:(struct entity *)ent {
      return sin(phi) * ent->pos.k + cos(phi) * (cos(theta) * ent->pos.j - sin(theta) * ent->pos.i);
   }

   - (void) display {
      [self clear];
      mvprintw([self my] - 1, 0, "Phi: %dpi/%d -- Theta: %dpi/%d -- Scale: %.2f", self->iphi, rrot(), self->itheta, rrot(), self->scale);
      int count = 1;
      struct entity *u = (struct entity *)[[self system] head];
      while(u) {
         mvprintw(count, 0, "%d, Pos:< X:%010.4f, Y:%010.4f, Z:%010.4f > Vel:< I:%010.4f, J:%010.4f, K:%010.4f >",            count, u->pos.i, u->pos.j, u->pos.k, u->vel.i, u->vel.j, u->vel.k);
          mvprintw(cy - (([self yvar:u] + 1 - (following ? [self yvar:following] : 0)) / 1.75) * scale, 
                   cx + ([self xvar:u] - (following ? [self xvar:following] : 0)) * scale, 
                  "%d", count);
         u = (struct entity *)u->link.next;
         count += 1;
      }
      [self refresh];
   }

   - (bool) handleInput {
      switch(getch()) {
         case 'q':
            return 1;
         case KEY_RESIZE:
            [self getMaxYX];
            break;
         case 'h':
            [self incThetaBy:1];
            break;
         case 's':
            [self incThetaBy:-1];
            break;
         case 't':
            [self incPhiBy:1];
            break;
         case 'n':
            [self incPhiBy:-1];
            break;
         case KEY_LEFT:
            self->scale -= 0.05;
            break;
         case KEY_RIGHT:
            self->scale += 0.05;
            break;
         case KEY_DOWN:
            self->following = (struct entity *)( self->following ? 
               ( self->following->link.next ? self->following->link.next : NULL ) 
               : [[self system] head] );
            break;
         case KEY_UP:
            self->following = (struct entity *)( self->following ? 
               ( self->following->link.prev ? self->following->link.prev : NULL ) 
               : [[self system] tail] );
            break;
      }
      return 0;
   }

@end
