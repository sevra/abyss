#import <Foundation/Foundation.h>

struct link {
	struct link *next, *prev;
	id owner;
};

@interface LinkedList : NSObject {
	struct link *head, *tail;
	int length;
}
	@property (readonly) struct link *head, *tail;
	@property (readonly) int length;

	- (id) init;

	- (BOOL) isHead:(struct link *)existing;
	- (BOOL) isTail:(struct link *)existing;

	- (struct link *) linkAt:(int)index;
	
	- (void) insertLink:(struct link *)link;
	- (void) appendLink:(struct link *)link;

	- (void) addLink:(struct link *)link beforeLink:(struct link *)existing;
	- (void) addLink:(struct link *)link beforeLinkAt:(int)index;

	- (void) addLink:(struct link *)link afterLink:(struct link *)existing;
	- (void) addLink:(struct link *)link afterLinkAt:(int)index;

	- (struct link*) removeLink:(struct link *)existing;
	- (struct link*) removeLinkAt:(int)index;

	- (void) swapLink:(struct link *)linkA withLink:(struct link *)linkB;
	- (void) swapLinkAt:(int)indexA withLinkAt:(int)indexB;

	- (void) shiftBy:(int)count;
@end
