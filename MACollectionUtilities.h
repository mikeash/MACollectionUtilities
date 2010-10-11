//
//  MACollectionUtilities.h
//  MACollectionUtilities
//
//  Created by Michael Ash on 10/11/10.
//  Copyright 2010 Michael Ash. All rights reserved.
//

#import <Foundation/Foundation.h>


#define IDARRAY(...) ((id[]){ __VA_ARGS__ })
#define IDCOUNT(...) (sizeof(IDARRAY(__VA_ARGS__)) / sizeof(id))

// this is key/object order, not object/key order, thus all the fuss
#define DICT(...) MADictionaryWithKeysAndObjects(IDARRAY(__VA_ARGS__), IDCOUNT(__VA_ARGS__) / 2)

#define ARRAY(...) ([NSArray arrayWithObjects: IDARRAY(__VA_ARGS__) count: IDCOUNT(__VA_ARGS__)])
#define SET(...) ([NSSet setWithObjects: IDARRAY(__VA_ARGS__) count: IDCOUNT(__VA_ARGS__)])

static inline NSDictionary *MADictionaryWithKeysAndObjects(id *keysAndObjs, NSUInteger count)
{
    id keys[count];
    id objs[count];
    for(NSUInteger i = 0; i < count; i++)
    {
        keys[i] = keysAndObjs[i * 2];
        objs[i] = keysAndObjs[i * 2 + 1];
    }
    
    return [NSDictionary dictionaryWithObjects: objs forKeys: keys count: count];
}
