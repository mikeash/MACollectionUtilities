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
	__block NSInteger sum = 0;
    
    TEST_ASSERT([[array ma_map: ^(id obj) { return [obj stringByAppendingString: @".0"]; }] isEqual: 
                 ARRAY(@"1.0", @"2.0", @"3.0")]);
    TEST_ASSERT([[array ma_select: ^BOOL (id obj) { return [obj intValue] < 1; }] isEqual: ARRAY()]);
    TEST_ASSERT([[array ma_select: ^BOOL (id obj) { return [obj intValue] < 3; }] isEqual: ARRAY(@"1", @"2")]);
    TEST_ASSERT([[array ma_select: ^BOOL (id obj) { return [obj intValue] < 4; }] isEqual: array]);
    TEST_ASSERT([[array ma_match: ^BOOL (id obj) { return [obj intValue] > 1; }] isEqual: @"2"]);
    TEST_ASSERT([array ma_match: ^BOOL (id obj) { return [obj intValue] < 1; }] == nil);
	
	[array ma_do: ^void (id obj) { sum += [obj integerValue]; }];
	TEST_ASSERT(sum == 6);
}

static void TestArrayMacros(void)
{
    NSArray *array = ARRAY(@"1", @"2", @"3");
	__block NSInteger sum = 0;

    TEST_ASSERT([MAP(array, [obj stringByAppendingString: @".0"]) isEqual:
                 ARRAY(@"1.0", @"2.0", @"3.0")]);
    TEST_ASSERT([SELECT(array, [obj intValue] < 1) isEqual: ARRAY()]);
    TEST_ASSERT([SELECT(array, [obj intValue] < 3) isEqual: ARRAY(@"1", @"2")]);
    TEST_ASSERT([SELECT(array, [obj intValue] < 4) isEqual: array]);
    TEST_ASSERT([SELECT(array, obj) isEqual: array]);
    
    TEST_ASSERT([REJECT(array, [obj intValue] >= 1) isEqual: ARRAY()]);
    TEST_ASSERT([REJECT(array, [obj intValue] >= 3) isEqual: ARRAY(@"1", @"2")]);
    TEST_ASSERT([REJECT(array, [obj intValue] < 1) isEqual: array]);
    TEST_ASSERT([REJECT(array, !obj) isEqual: array]);
    
    TEST_ASSERT([MATCH(array, [obj intValue] > 1) isEqual: @"2"]);
    TEST_ASSERT(MATCH(array, [obj intValue] < 1) == nil);
	
	DO(array, sum += [obj integerValue]);
	TEST_ASSERT (sum == 6);
}

static void TestEach(void)
{
    NSArray *array1 = ARRAY(@"1", @"2", @"3");
    NSArray *array2 = ARRAY(@"4", @"5", @"6");
    
    NSArray *together = MAP(array1, [obj stringByAppendingString: EACH(array2)]);
    TEST_ASSERT([together isEqual: ARRAY(@"14", @"25", @"36")]);
    
    NSArray *filtered = SELECT(array1, [obj intValue] * 2 < [EACH(array2) intValue]);
    TEST_ASSERT([filtered isEqual: ARRAY(@"1", @"2")]);
}

static void TestSetMethods(void)
{
    NSSet *set = SET(@"1", @"2", @"3");
    
    TEST_ASSERT([[set ma_map: ^(id obj) { return [obj stringByAppendingString: @".0"]; }] isEqual: 
                 SET(@"1.0", @"2.0", @"3.0")]);
    TEST_ASSERT([[set ma_select: ^BOOL (id obj) { return [obj intValue] < 1; }] isEqual: SET()]);
    TEST_ASSERT([[set ma_select: ^BOOL (id obj) { return [obj intValue] < 3; }] isEqual: SET(@"1", @"2")]);
    TEST_ASSERT([[set ma_select: ^BOOL (id obj) { return [obj intValue] < 4; }] isEqual: set]);
    TEST_ASSERT([SET(@"2", @"3") containsObject: [set ma_match: ^BOOL (id obj) { return [obj intValue] > 1; }]]);
    TEST_ASSERT([set ma_match: ^BOOL (id obj) { return [obj intValue] < 1; }] == nil);
}

static void TestSetMacros(void)
{
    NSSet *set = SET(@"1", @"2", @"3");
    
    TEST_ASSERT([MAP(set, [obj stringByAppendingString: @".0"]) isEqual: 
                 SET(@"1.0", @"2.0", @"3.0")]);
    TEST_ASSERT([SELECT(set, [obj intValue] < 1) isEqual: SET()]);
    TEST_ASSERT([SELECT(set, [obj intValue] < 3) isEqual: SET(@"1", @"2")]);
    TEST_ASSERT([SELECT(set, [obj intValue] < 4) isEqual: set]);
    TEST_ASSERT([SELECT(set, obj) isEqual: set]);
    
    TEST_ASSERT([REJECT(set, [obj intValue] >= 1) isEqual: SET()]);
    TEST_ASSERT([REJECT(set, [obj intValue] >= 3) isEqual: SET(@"1", @"2")]);
    TEST_ASSERT([REJECT(set, [obj intValue] < 1) isEqual: set]);
    TEST_ASSERT([REJECT(set, !obj) isEqual: set]);
    
    TEST_ASSERT([SET(@"2", @"3") containsObject: MATCH(set, [obj intValue] > 1)]);
    TEST_ASSERT(MATCH(set, [obj intValue] < 1) == nil);
}

static void TestReduce(void)
{
    NSArray *array = ARRAY(@"hel", @"lo ", @"wor", @"ld");
    NSString *result = [array ma_reduce: @"" block: ^(id a, id b) { return [a stringByAppendingString: b]; }];
    TEST_ASSERT([result isEqualToString: @"hello world"]);
    
    result = REDUCE(array, @"", [a stringByAppendingString: b]);
    TEST_ASSERT([result isEqualToString: @"hello world"]);
}

static void TestSorting(void)
{
    NSArray *array = ARRAY(@"one", @"three", @"four", @"eleven", @"seventeen");
    NSArray *result = SORTED(array, [a length] > [b length]);
    TEST_ASSERT([result isEqual: ARRAY(@"seventeen", @"eleven", @"three", @"four", @"one")]);
    
    NSSet *set = SET(@"one", @"three", @"four", @"eleven", @"seventeen");
    result = SORTED(set, [a length] > [b length]);
    TEST_ASSERT([result isEqual: ARRAY(@"seventeen", @"eleven", @"three", @"four", @"one")]);
}

int main(int argc, char **argv)
{
    WithPool(^{
        TEST(TestCreation);
        TEST(TestArrayMethods);
        TEST(TestArrayMacros);
        TEST(TestEach);
        TEST(TestSetMethods);
        TEST(TestSetMacros);
        TEST(TestReduce);
        TEST(TestSorting);
        
        NSString *message;
        if(gFailureCount)
            message = [NSString stringWithFormat: @"FAILED: %d total assertion failure%s", gFailureCount, gFailureCount > 1 ? "s" : ""];
        else
            message = @"SUCCESS";
        NSLog(@"Tests complete: %@", message);
    });
    return 0;
}
