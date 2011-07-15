//
//  HelloWorldScene.m
//  soccer
//
//  Created by Doug Molinuex on 6/28/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// Importing Chipmunk headers
#import "chipmunk.h"

// HelloWorld Layer
@interface HelloWorld : CCLayer
{
	// declare space
	cpSpace *space;
	
	// create the ball
	CCSprite *ball;
	
	// create the ball
	CCSprite *goal;
	
	// declare the ball's coordinates
	CGPoint *ballLocation;
	
	// create the user's players
	NSMutableArray *players;
	
	// create the opposition players
	NSMutableArray *oppPlayers;
	
	// get the size of the screen
	CGSize winSize;
	
	// declare player reference integer
	int playerRef;
	
	// whether the scene is ready for an action
	BOOL action;
	
	// declare boolean that determines whether or not a player is in possession
	BOOL playerHasPossession;
	
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;
-(void) step: (ccTime) dt;
-(void)moveBall:(CGPoint)location;
-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;

@end
