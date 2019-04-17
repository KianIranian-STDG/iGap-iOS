//
//  obj_cell.h
//  timeline
//
//  Created by Amir Soleimani on 6/18/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MC_obj_cell : NSObject {
    float _Height;
    id _View;
}


@property (nonatomic, assign) float Height;
@property (nonatomic, strong) id View;

- (id)initWithHeight:(float)Height view:(id)View;

@end
