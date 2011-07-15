//
//  HelloWorldScene.m
//  soccer
//
//  Created by Doug Molineux on 6/28/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// Import the interfaces
#import "HelloWorldScene.h"

enum {
	kTagBatchNode = 1,
};

static void
eachShape(void *ptr, void* unused)
{
	cpShape *shape = (cpShape*) ptr;
	CCSprite *sprite = shape->data;
	if( sprite ) {
		cpBody *body = shape->body;
		
		// TIP: cocos2d and chipmunk uses the same struct to store it's position
		// chipmunk uses: cpVect, and cocos2d uses CGPoint but in reality the are the same
		// since v0.7.1 you can mix them if you want.		
		[sprite setPosition: body->p];
		
		[sprite setRotation: (float) CC_RADIANS_TO_DEGREES( -body->a )];
	}
}

// HelloWorld implementation
@implementation HelloWorld

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorld *layer = [HelloWorld node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void) addGk:(NSString *)playerTexture
{
	// create a player sprite
	CCSprite *currentPlayer = [CCSprite spriteWithFile:playerTexture rect:CGRectMake(0, 0, 40, 40)];
	
	// declare users x coordinate
	int posx;
	
	// declare users y coordinate
	int posy = 15+(winSize.height/2 - currentPlayer.contentSize.height/2);
	
	// set both gks positions
	if(playerTexture == @"player.png")
		posx = currentPlayer.contentSize.width/2 + 70;
	else if(playerTexture == @"oppPlayer.png") 
		posx = winSize.width - (currentPlayer.contentSize.width/2 + 70);
		
	// set the position of the player providing coordinates
	currentPlayer.position = ccp(posx, posy);

	// add the current player (just created) and add it to the players or the opp players array	
	if(playerTexture == @"player.png")
		[players addObject: currentPlayer];
	else if(playerTexture == @"oppPlayer.png") 
		[oppPlayers addObject: currentPlayer];
	
	
}

-(void) flanksOfFour:(int)number withArg2:(int)widthOffset
{
	// create a player sprite
	CCSprite *currentPlayer = [CCSprite spriteWithFile:@"player.png" rect:CGRectMake(0, 0, 40, 40)];
	
	// set the position of the player providing coordinates
	currentPlayer.position = ccp(currentPlayer.contentSize.width/2 + widthOffset, number*(winSize.height/5));
	
	// add the current player (just created) and add it to the players array
	[players addObject: currentPlayer];
}

-(void) addDef:(int) number
{		
	// create a flank of four for the defense
	[self flanksOfFour:number withArg2:240];
}

-(void) addMid:(int) number
{
	// compensate to be same y-coord as def
	number = number - 4;
	
	// create a flank of four for the midfield
	[self flanksOfFour:number withArg2:365];
}

-(void) addAtt:(int) number
{
	
	// compensate for the increased number; need to same be y-coordinate as as cm and cb
	number = number - 7;
	
	//NSLog(@"%@", [NSNumber numberWithInt:number]);
	
	// create a player sprite
	CCSprite *currentPlayer = [CCSprite spriteWithFile:@"player.png" rect:CGRectMake(0, 0, 40, 40)];
	
	if(number == 3) {
	
		// set the position of the player providing coordinates
		currentPlayer.position = ccp(winSize.width/2, winSize.height/2);
	
	} else {
		
		// set the position of the player providing coordinates
		currentPlayer.position = ccp(currentPlayer.contentSize.width/2 + 480, number*(winSize.height/5));
	
	}
		
	// add the current player (just created) and add it to the players array
	[players addObject: currentPlayer];
	
}

-(void) initializePitch {
	

	// get the size of the screen and assign it to winSize
	winSize = [[CCDirector sharedDirector] winSize];
	
	CCSprite *bg = [CCSprite spriteWithFile:@"soccer_field.jpg"];
	bg.position = ccp(winSize.width/2, winSize.height/2);
	[self addChild:bg z:0];
	//[self addChild:[MenuLayer node] z:1];
	
	self.isTouchEnabled = YES;
	self.isAccelerometerEnabled = YES;
	
	//CGSize wins = [[CCDirector sharedDirector] winSize];
	cpInitChipmunk();
	
	//cpBody *staticBody = cpBodyNew(INFINITY, INFINITY);
	space = cpSpaceNew();
	cpSpaceResizeStaticHash(space, 400.0f, 40);
	cpSpaceResizeActiveHash(space, 100, 600);
	
	space->gravity = ccp(0, 0);
	space->elasticIterations = space->iterations;
	
	// beginning of the player creation
	
	// create the players array; this is also declared in the header file
	players = [[NSMutableArray alloc] init];
	
	// loop 11 times for 11 players
	for(int i = 0; i <= 10; i++) {
		
		// check to see the player index; find out which position we're at
		if(i == 0) {
			
			// add the user's player
			[self addGk:@"player.png"];
			
			// add the opposition player
			[self addGk:@"oppPlayer.png"];
			
		}
		else if(i > 0 && i < 5)
			[self addDef:i];
		else if(i > 4 && i < 9)
			[self addMid:i];
		else if(i > 8 && i < 11)
			[self addAtt:i];
		
	}
	
	// add each player to the pitch
	for (id object in players) {
		
		[self addChild:object];
	}
	
	// create the ball sprite; set position and size
	ball = [CCSprite spriteWithFile:@"ball.png" rect:CGRectMake(0, 0, 20, 20)];
	
	// set the position of the ball providing the coordinates
	ball.position = ccp(winSize.width/2, winSize.height/2);
	
	// add the ball to the playing area
	[self addChild:ball];
	
	// end of the player creation
	
	// create the goal sprite; set position and size
	goal = [CCSprite spriteWithFile:@"goal.png" rect:CGRectMake(0, 0, 22, 53)];
	
	// set the position of the ball providing the coordinates
	goal.position = ccp(62, winSize.height/2);
	
	// add the ball to the playing area
	[self addChild:goal];
	
	[self schedule:@selector(update:)];
	
}

-(id) init
{
	

	
	action = NO;
	
	playerHasPossession = YES;
	
	//t[[TextureMgr sharedTextureMgr] addImage: @"playerWithPossession.png"];
	
	if( (self=[super init])) {
		
		[self initializePitch];
					
		
	}
	
	return self;
}

-(void) onEnter
{
	[super onEnter];
	
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 60)];
}

-(void) step: (ccTime) delta
{
	int steps = 2;
	CGFloat dt = delta/(CGFloat)steps;
	
	for(int i=0; i<steps; i++){
		cpSpaceStep(space, dt);
	}
	cpSpaceHashEach(space->activeShapes, &eachShape, nil);
	cpSpaceHashEach(space->staticShapes, &eachShape, nil);
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event  
{
	UITouch  *theTouch = [touches anyObject];
    CGPoint touchLocation = [theTouch locationInView:[theTouch view] ];
    CGFloat x = touchLocation.x;
    CGFloat y = touchLocation.y;
	printf("move x=%f,y=%f",x,y); 
	
	/*
	
	for(CCSprite *currentPlayer in players ) {
	
		if(touchLocation.x >= (currentPlayer.position.x - currentPlayer.contentSize.height/2) &&
		   touchLocation.x <= (currentPlayer.position.x + currentPlayer.contentSize.height/2) &&
		   touchLocation.y >= (currentPlayer.position.y - currentPlayer.contentSize.width/2) &&
		   touchLocation.y <= (currentPlayer.position.y + currentPlayer.contentSize.width/2)) {
			
			NSLog(@"player1 has been clicked");
			
			[self movePlayer:touchLocation withArg2:currentPlayer];
			
		} 
		
	}
	 */
	
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	
	if (playerHasPossession) {
		
		action = NO;
		
		for( UITouch *touch in touches ) {
			
			CGPoint location = [touch locationInView: [touch view]];
			
			location = [[CCDirector sharedDirector] convertToGL: location];
			
			[self moveBall:location];
			
			//[self movePlayer:location];
			
		}
	}
	
}

- (void)moveBall:(CGPoint)location {

    // Create the actions 
    id actionMove = [CCMoveTo actionWithDuration:0.4 position:ccp(location.x, location.y)];
    id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)];
	
    [ball runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];

}

- (void)movePlayer:(CGPoint)currentLocation withArg2:(CCSprite*)playerHolder {
	
	/* 
	 
	 if(location.x >= (player1.position.x - player1.contentSize.height/2) &&
	   location.x <= (player1.position.x + player1.contentSize.height/2) &&
	   location.y >= (player1.position.y - player1.contentSize.width/2) &&
	   location.y <= (player1.position.y + player1.contentSize.width/2)) {
		
		NSLog(@"player1 has been clicked");
		
	} else { 
	 
	 */
		
	// Create the actions 
	id actionMove = [CCMoveTo actionWithDuration:0.4 position:ccp(currentLocation.y, currentLocation.x)];
	id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(playerMoveFinished:)];

	[playerHolder runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
		
	//}
}

-(void)spriteMoveFinished:(id)sender {
	
	action = YES;
	
	//[self movePlayer:ball.position];
	
}

-(void)playerMoveFinished:(id)sender {
	
	//[self movePlayer:ball.position];
	
	//[self moveBall:location];
	
}

- (void)update:(ccTime)dt {
	
	if(ball.position.x >= (goal.position.x - goal.contentSize.width/2) &&
	   ball.position.x <= (goal.position.x + goal.contentSize.width/2) &&
	   ball.position.y >= (goal.position.y - goal.contentSize.height/2) &&
	   ball.position.y <= (goal.position.y + goal.contentSize.height/2)) {
		
		//NSLog(@"GOAL!!");
		
		[self initializePitch];
		
		CCParticleSystem *rain = [[CCParticleExplosion alloc] init]; 
		
		rain.texture = [[CCTextureCache sharedTextureCache] addImage:@"particle.png"];
		rain.position = ccp(winSize.width/2, winSize.height/2);

		rain.duration = 5;
		
		[self addChild:rain];
		
		//rain.autoRemoveOnFinish = YES;
		
		
	} 

	//NSLog(@"%d", playerHasPossession);
	
	// setting the distance array
	NSMutableArray *distances = [[NSMutableArray alloc] init];
	
	// declare counter
	int c = 0;
	
	// get the distance between each player and the ball; add it to distance array
	for(CCSprite *currentPlayer in players ) {
		
		// distance formula - to get distance between player and ball
		CGFloat dx = ball.position.x - currentPlayer.position.x;
		CGFloat dy = ball.position.y - currentPlayer.position.y;
		CGFloat distance = sqrt(dx*dx + dy*dy);
		
		// add the distance to the distances array
		[distances addObject:[NSNumber numberWithFloat:distance]];
		
		c++;
		 
	}
	
	// declare the closest distance nsnumber
	NSNumber *closestDistance = [NSNumber numberWithFloat:0];
	
	// declare the player reference integer
	playerRef = 0;
	
	// reset counter
	c = 0;
	
	// this is to see if a player has the ball
	for(CCSprite *currentPlayer in players ) {
		
		// set the playerHasPossession Boolean
		if(ball.position.x >= (currentPlayer.position.x - currentPlayer.contentSize.height/2) &&
		   ball.position.x <= (currentPlayer.position.x + currentPlayer.contentSize.height/2) &&
		   ball.position.y >= (currentPlayer.position.y - currentPlayer.contentSize.width/2) &&
		   ball.position.y <= (currentPlayer.position.y + currentPlayer.contentSize.width/2)) {
			
			playerHasPossession = YES;
			break;
			
		}
		else {
			playerHasPossession = NO;
		}
	}
	
	for(NSNumber *distance in distances ) {
		
		// if closest distance is 0 then it must be the distance must be closest
		if([closestDistance floatValue] == 0) {
			
			// closest player found
			closestDistance = distance;
			
			// set the player reference as thee counter
			playerRef = c;
			
		}
		else {
			
			// check to see if current player is any closer
			if ([closestDistance floatValue] > [distance floatValue]) {
				
				// closer distance has been found
				closestDistance = distance;
				
				// save the player reference from the count
				playerRef = c;
				
			}
			
		}
		
		// increment counter
		c++;
		
	}
	
	int playerPointer = 0;
	
	// this generates random movement for each player
	int moveForward = (arc4random() % 150);
	
	// out of 11 guarantees one will move each time
	int moveBackward = (arc4random() % 150);
	
	for(CCSprite *currentPlayer in players ) {
		
		if (playerPointer == playerRef) {
			
			[currentPlayer setTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerWithPossession.png"]];
			
			if (action == YES) {
				id actionMove = [CCMoveTo actionWithDuration:0.4 position:ccp(ball.position.x, ball.position.y)];
				id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(playerMoveFinished:)];
				
				[currentPlayer runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
			}
			
		} else {
			[currentPlayer setTexture:[[CCTextureCache sharedTextureCache] addImage:@"player.png"]];
		}
		
		if (playerPointer == moveForward) {
			
			// Create the actions 
			id actionMove = [CCMoveTo actionWithDuration:0.4 position:ccp(currentPlayer.position.x+5, currentPlayer.position.y+1)];
			id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(playerMoveFinished:)];
			
			[currentPlayer runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];

		}
		
		if (playerPointer == moveBackward) {
			
			// Create the actions 
			id actionMove = [CCMoveTo actionWithDuration:0.4 position:ccp(currentPlayer.position.x-5, currentPlayer.position.y+1)];
			id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(playerMoveFinished:)];
			
			[currentPlayer runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
			
		}

		playerPointer++;
	}
	
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
	static float prevX=0, prevY=0;
	
#define kFilterFactor 0.05f
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
	prevX = accelX;
	prevY = accelY;
	
	CGPoint v = ccp( accelX, accelY);
	
	space->gravity = ccpMult(v, 200);
}
@end
