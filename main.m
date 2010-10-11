//
//  untitled.m
//  MACollectionUtilities
//
//  Created by Michael Ash on 10/11/10.
//  Copyright 2010 Michael Ash. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MACollectionUtilities.h"


static void WithPool(void (^block)(void))
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    block();
    [pool release];
}

static int gFailureCount;

static void Test(void (*func)(void), const char *name)
{
    WithPool(^{
        int failureCount = gFailureCount;
        NSLog(@"Testing %s", name);
        func();
        NSLog(@"%s: %s", name, failureCount == gFailureCount ? "SUCCESS" : "FAILED");
    });
}

#define TEST(func) Test(func, #func)

#define TEST_ASSERT(cond, ...) do { \
        if(!(cond)) { \
            gFailureCount++; \
            NSString *message = [NSString stringWithFormat: @"" __VA_ARGS__]; \
            NSLog(@"%s:%d: assertion failed: %s %@", __func__, __LINE__, #cond, message); \
        } \
    } while(0)

static void TestCreation(void)
{
    TEST_ASSERT([DICT(@"a", @"b", @"c", @"d") isEqual: ([NSDictionary dictionaryWithObjectsAndKeys: @"b", @"a", @"d", @"c", nil])]);
    TEST_ASSERT([ARRAY(@"a", @"b", @"c", @"d") isEqual: ([NSArray arrayWithObjects: @"a", @"b", @"c", @"d", nil])]);
    TEST_ASSERT([SET(@"a", @"b", @"c", @"d") isEqual: ([NSSet setWithObjects: @"a", @"b", @"c", @"d", nil])]);
}

static void TestArrayMethods(void)
{
    NSArray *array = ARRAY(@"1", @"2", @"3");
    
    TEST_ASSERT([[array ma_map: ^(id obj) { return [obj stringByAppendingString: @".0"]; }] isEqual: 
                 ARRAY(@"1.0", @"2.0", @"3.0")]);
    TEST_ASSERT([[array ma_select: ^BOOL (id obj) { return [obj intValue] < 1; }] isEqual: ARRAY()]);
    TEST_ASSERT([[array ma_select: ^BOOL (id obj) { return [obj intValue] < 3; }] isEqual: ARRAY(@"1", @"2")]);
    TEST_ASSERT([[array ma_select: ^BOOL (id obj) { return [obj intValue] < 4; }] isEqual: array]);
}

static void TestArrayMacros(void)
{
    NSArray *array = ARRAY(@"1", @"2", @"3");
    
    TEST_ASSERT([MAP(array, [obj stringByAppendingString: @".0"]) isEqual: 
                 ARRAY(@"1.0", @"2.0", @"3.0")]);
    TEST_ASSERT([SELECT(array, [obj intValue] < 1) isEqual: ARRAY()]);
    TEST_ASSERT([SELECT(array, [obj intValue] < 3) isEqual: ARRAY(@"1", @"2")]);
    TEST_ASSERT([SELECT(array, [obj intValue] < 4) isEqual: array]);
}

int main(int argc, char **argv)
{
    WithPool(^{
        TEST(TestCreation);
        TEST(TestArrayMethods);
        TEST(TestArrayMacros);
        
        NSString *message;
        if(gFailureCount)
            message = [NSString stringWithFormat: @"FAILED: %d total assertion failure%s", gFailureCount, gFailureCount > 1 ? "s" : ""];
        else
            message = @"SUCCESS";
        NSLog(@"Tests complete: %@", message);
    });
    return 0;
}
