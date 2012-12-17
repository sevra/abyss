#import <Foundation/Foundation.h>
#import <curses.h>
#import <lua.h>
#import <lauxlib.h>
#import <lualib.h>

#import <unistd.h>

#import "system.h"
#import "display.h"

static const char *key = "system";

void error(lua_State *L, const char *fmt, ...) {
   va_list argp;
   va_start(argp, fmt);
   vfprintf(stderr, fmt, argp);
   va_end(argp);
   lua_close(L);
   exit(EXIT_FAILURE);
}

static int l_create(lua_State *L) {
   int i, n;
   double a[8]; // mass, density, x, y, z, i, j, k

   luaL_checktype(L, 1, LUA_TTABLE);
   
   n = lua_objlen(L, 1);
   for(i = 1; i <= n; i++) {
      lua_rawgeti(L, 1, i);
      a[i-1] = lua_tonumber(L, -1);
   }

   lua_pushlightuserdata(L, (void *)&key);
   lua_gettable(L, LUA_REGISTRYINDEX);
   System *system = (System *)lua_topointer(L, -1);
   [system addEntityWithMass:a[0] density:a[1]
                         atX:a[2] y:a[3] z:a[4]
                     movingI:a[5] j:a[6] k:a[7]];
   return 0;
}

int main(int argc, char **argv) {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];

   System *system = [[System new] autorelease];
   Curses *curses = [[[Curses alloc] initWithSystem:system] autorelease];

   lua_State *L = luaL_newstate();
   luaL_openlibs(L);

   lua_pushlightuserdata(L, (void *)&key);
   lua_pushlightuserdata(L, (void *)system);
   lua_settable(L, LUA_REGISTRYINDEX);

   lua_pushcfunction(L, l_create);
   lua_setglobal(L, "create");

   if(luaL_loadfile(L, "rc.lua") || lua_pcall(L, 0, 0, 0)) {
      [pool drain];
      error(L, "%s", lua_tostring(L, -1));
   }

   [system compensateSystemVelocity];

   while(1) {
      usleep(100000);
      [system getForces];
      [system applyForces];
      [curses display];
      if([curses handleInput])
         break;
   }

   [pool drain];
	return 0;
}
