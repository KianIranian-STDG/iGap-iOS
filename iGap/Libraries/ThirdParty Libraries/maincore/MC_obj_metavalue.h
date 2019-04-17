//
//  MC_obj_metavalue.h
//  maincore
//
//  Created by Amir Soleimani on 8/1/17.
//  Copyright © 2017 amir soleimani. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MC_obj_metavalue : NSObject  {
    NSString *_Meta;
    NSString *_Value;
}

@property (nonatomic, copy) NSString *Meta;
@property (nonatomic, copy) NSString *Value;

- (id)initWithMeta:(NSString*)Meta value:(NSString*)Value;

@end
