//
//  Phone.h
//  PlivoLogin
//
//  Created by Iwan BK on 10/7/13.
//  Copyright (c) 2013 Plivo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlivoEndpoint.h"
#import "PlivoRest.h"

@interface Phone : NSObject

/**
 * Create Plivo endpoint.
 * We need to specify 3 things:
 * - username
 * - password
 * - alias
 */
- (void)createEndpointWithUsername:(NSString *)username andPassword:(NSString *)password andAlias:(NSString *)alias;

/**
 * Login to plivo with specified username and password
 */
- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password;

/**
 * Delete plivo endpoint that generated before
 */
- (void)deleteEndpoint:(NSString *)endpointId;

/**
 * logout our phone from plivo
 */
- (void)logout;

/**
 * Set delegate of plivo endpoint object
 */
- (void)setDelegate:(id)delegate;

/* make call with extra headers */
- (PlivoOutgoing *)callWithDest:(NSString *)dest andHeaders:(NSDictionary *)headers;

/* send keepalive data to plivo server*/
- (void)keepAlive;

@end
