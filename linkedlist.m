#import "linkedlist.h"

void swapptr(void **var1, void **var2, void **temp) {
	*temp = *var1;
	*var1 = *var2;
	*var2 = *temp;
   *temp = NULL;
}

enum EXTREMITY {
	HEAD = 1,
	TAIL = 2,
};

@implementation LinkedList
	@synthesize head, tail;
	@synthesize length;

	- (id) init {
		// Initialize a linked list
		if((self = [super init])) {
			self->head = NULL;
			self->tail = NULL;
			self->length = 0;
		}
		return self;
	}

	- (void) manage:(struct link *)link {
		// Take ownership of a link
		if(link->owner)
			[NSException raise:@"LinkedList mnager conflict"
							 format:@"Link is aleady managed."];
         /*
			 *[NSException raise:@"LinkedList mnager conflict"
			 *             format:@"Link is aleady managed by %@", link->owner];
          */
		link->owner = self;

		self->length++;
	}

	- (BOOL) managing:(struct link *)link {
		// YES if link belongs to this linked list else NO
		return link->owner == self;
	}

	- (struct link *) disown:(struct link *)existing {
		// Disown a link and set its prev, next and owner to NULL
		if(![self managing:existing])
			[NSException raise:@"LinkedList mnager conflict"
							 format:@"Link not owned by manager %@", self];
		existing->prev = NULL;
		existing->next = NULL;
		existing->owner = NULL;

		self->length--;

		return existing;
	}

	- (BOOL) isLink:(struct link *)existing extremity:(enum EXTREMITY)extremity {
		// Check if link is EXTREMITY (HEAD or TAIL)
		if(![self managing:existing])
			[NSException raise:@"LinkedList mnager conflict"
							 format:@"Link not owned by manager %@", self];
		switch(extremity) {
			case HEAD:
				if(existing == self->head)
					return YES;
				return NO;
			case TAIL:
				if(existing == self->tail)
					return YES;
				return NO;
		}
	}

	- (BOOL) isHead:(struct link *)existing {
		return [self isLink:existing extremity:HEAD];
	}

	- (BOOL) isTail:(struct link *)existing {
		return [self isLink:existing extremity:TAIL];
	}

	- (void) addFirst:(struct link *)link {
		NSLog(@"added first link\n");

		link->prev = self->head;
		link->next = self->tail;

		self->head = link;
		self->tail = link;
		
		[self manage:link];
	}

	- (struct link *) removeLast {
		NSLog(@"removed last link\n");

		struct link *existing = self->head;

		self->head = NULL;
		self->tail = NULL;

		return [self disown:existing];
	}

	- (BOOL) isValidIndex:(int)index {
		if((index >= 0) && (index < self->length))
			return YES;
		return NO;
	}

	- (struct link *) linkAt:(int)index {
		if(![self isValidIndex:index])
			[NSException raise:@"Invalid list index"
							 format:@"Index %d out of range, greater than %d", index, self->length - 1];

		struct link *link = NULL;
		int i, dir = self->length/2 - index;
		NSLog(@"dir:%d", dir);

		NSLog(@"Traversing from %s\n", (dir > 0 ? "head" : "tail"));

		if(dir > 0) {
			link = self->head;
			i = index;
		}
		else {
			link = self->tail;
			i = (self->length - 1) - index;
		}

		while(i) {
			if(dir > 0)
				link = link->next;
			else
				link = link->prev;
			i--;
		}
		return link;
	}

	- (void) insertLink:(struct link *)link {
		if(![self isValidIndex:0])
			return [self addFirst:link];

		NSLog(@"Inserting link");

		link->next = self->head;
		link->prev = NULL;

		self->head->prev = link;
		self->head = link;

		[self manage:link];
	}

	- (void) appendLink:(struct link *)link {
		if(![self isValidIndex:self->length - 1])
			return [self addFirst:link];

		NSLog(@"Appending link");

		link->prev = self->tail;
		link->next = NULL;

		self->tail->next = link;
		self->tail = link;

		[self manage:link];
	}

	- (void) addLink:(struct link *)link before:(BOOL)before existingLink:(struct link *)existing {
		if(![self managing:existing])
			[NSException raise:@"LinkedList mnager conflict"
							 format:@"Existing link not owned by manager %@", self];

		if(before) {
			if(existing == self->head)
				return [self insertLink:link];

			existing->prev->next = link;
			link->prev = existing->prev;

			existing->prev = link;
			link->next = existing;
		} else {
			if(existing == self->tail)
				return [self appendLink:link];

			existing->next->prev = link;
			link->next = existing->next;

			existing->next = link;
			link->prev = existing;
		}

		[self manage:link];
	}

	- (void) addLink:(struct link *)link beforeLink:(struct link *)existing {
		[self addLink:link before:true existingLink:existing];
	}
	
	- (void) addLink:(struct link *)link afterLink:(struct link *)existing {
		[self addLink:link before:false existingLink:existing];
	}

	- (void) addLink:(struct link *)link beforeLinkAt:(int)index {
		[self addLink:link beforeLink:[self linkAt:index]];
	}

	- (void) addLink:(struct link *)link afterLinkAt:(int)index {
		[self addLink:link afterLink:[self linkAt:index]];
	}

	- (struct link *) removeLink:(struct link *)existing {
		if(![self managing:existing])
			[NSException raise:@"LinkedList mnager conflict"
							 format:@"Link not owned by manager %@", self];

		if(self->length == 1)
			return [self removeLast];

		if(existing->prev) {
			existing->prev->next = existing->next;
			
			if(existing == self->tail)
				self->tail = existing->prev;
		}

		if(existing->next) {
			existing->next->prev = existing->prev;
			
			if(existing == self->head)
				self->head = existing->next;
		}

		return [self disown:existing];
	}

	- (struct link *) removeLinkAt:(int)index {
		return [self removeLink:[self linkAt:index]];
	}

	- (int) isLink:(struct link *)linkA adjacentToLink:(struct link *)linkB {
		if(!([self managing:linkA] && [self managing:linkB]))
			[NSException raise:@"LinkedList mnager conflict"
							 format:@"One or more links not owned by manager %@", self];

		if(linkB == linkA->prev)
			return -1;
		else if(linkB == linkA->next)
			return 1;
		else
			return 0;
	}
   
	// TODO this should be factored
	- (void) swapLink:(struct link *)linkA withLink:(struct link *)linkB {
		struct link *temp, *_head, *_tail;
		switch([self isLink:linkA adjacentToLink:linkB]) {
			case -1: // left adjacency
				swapptr(&linkA, &linkB, &temp);
			case 1: // right adjacency
				if(linkA->prev)
					linkA->prev->next = linkB;
				linkA->next = linkB->next;

				if(linkB->next)
					linkB->next->prev = linkA;
				linkB->prev = linkA->prev;

				linkA->prev = linkB;
				linkB->next = linkA;
				break;
			case 0: // not adjacent
				if(linkA->next)
					linkA->next->prev = linkB;
				
				if(linkA->prev)
					linkA->prev->next = linkB;

				if(linkB->next)
					linkB->next->prev = linkA;
				
				if(linkB->prev)
					linkB->prev->next = linkA;

				swapptr(&linkA->next, &linkB->next, &temp);
				swapptr(&linkA->prev, &linkB->prev, &temp);
		}
		
		_head = _tail = NULL;

		if(linkA == self->head)
			_head = linkB;
		else if(linkB == self->head)
			_head = linkA;

		if(linkA == self->tail)
			_tail = linkB;
		else if(linkB == self->tail)
			_tail = linkA;
		
		if(_head)
			self->head = _head;
		
		if(_tail)
			self->tail = _tail;
	}

	- (void) swapLinkAt:(int)indexA withLinkAt:(int)indexB {
		[self swapLink:[self linkAt:indexA] withLink:[self linkAt:indexB]];
	}

	- (void) shiftBy:(int)count {
		self->head->prev = self->tail;
		self->tail->next = self->head;

		struct link *current = (count > 0 ? self->head : self->tail);
		int i = (count > self->length ? count % self->length : count);
		
		while(i != 0) {
			if(count > 0) {
				current = current->next;
				i--;
			} else {
				current = current->prev;
				i++;
			}
		}

		if(count > 0) {
			self->head = current;
			self->tail = current->prev;
			current->prev->next = NULL;
			current->prev = NULL;
		} else {
			self->tail = current;
			self->head = current->next;
			current->next->prev = NULL;
			current->next = NULL;
		}
	}
@end

/* vim: set foldenable foldmethod=indent foldlever=3: */
