MACollectionUtilities
---------------------

MACollectionUtilities is a set of Smalltalk-inspired methods and macros on Cocoa collection classes, taking advantage of blocks. It is released under a BSD license.


Convenience Creators
--------------------

MACollectionUtilities includes three macros to simplify creating arrays, sets, and dictionaries. These macros give you something similar to the collection literals found in other languages, rather than the unwieldy `[NSArray arrayWithObjects:...]` syntax that Cocoa provides.

* `ARRAY(a, b, c)` - Create an `NSArray` that holds objects a, b, and c.
* `SET(a, b, c)` - Like `ARRAY`, but creates an `NSSet`.
* `DICT(a, b, c, d)` - Create an `NSDictionary` that holds `a -> b` and `c -> d`.

Note that `DICT` uses the IMO much more sensible key/value order instead of Cocoa's standard value/key order. Be aware.

Also note that these macros do not need, and you should not place, a `nil` at the end. They can detect the end of their arguments without your help.


Methods
-------

Methods are provided on `NSArray` and `NSSet` to do mapping, filtering, and matching. When used on `NSArray`, the resulting array is in the same order as the original, and matching always finds the first object. `NSSet` is unordered and so is the result, and which matching object is found is undefined. These category methods are prefixed with `ma_` to avoid conflicts with other category methods.

* `ma_map:` - Call the block once for each object in the collection, and use the return values to create a new collection. Note that block *must not* return `nil`.
* `ma_select:` - Call the block once for each object in the collection. Use the objects where the block returns `YES` to create a new collection.
* `ma_match:` - Search for an object in the collection for which the block returns `YES` and return it.


Helper macros
-------------

To simplify the use of the above methods, helper macros are provided. These macros take a collection as their first parameter and an expression as their second. The expression is used to create a block which is passed to the appropriate method. The parameter `obj` is implicitly created by the macros and can be used in the expression to refer to the individual objects.

* The `MAP`, `SELECT`, and `MATCH` macros all correspond to the methods of the same names.
* The `REJECT` macro is equivalent to a `SELECT` except that it selects objects for which the expression is *false*.


Examples
--------

Take an array of strings and append a suffix:

    NSArray *newArray = MAP(stringArray, [obj stringByAppendingString: suffix]);

Append a prefix instead:

    NSArray *newArray = MAP(stringArray, [prefix stringByAppendingString: obj]);

Find text files in a directory:

    NSArray *files = SELECT([[NSFileManager defaultManager] contentsOfDirectoryAtPath: path error: NULL],
                            [[obj pathExtension] isEqual: @"txt"]);

Find image files:

    NSSet *extensions = SET(@"jpg", @"jpeg", @"tiff", @"png", @"pdf");
    NSArray *files = SELECT([[NSFileManager defaultManager] contentsOfDirectoryAtPath: path error: NULL],
                            [extensions containsObject: [obj pathExtension]]);

Find the first string that starts with an asterisk:

    NSString *asteriskString = MATCH(stringArray, [obj hasPrefix: @"*"]);


Parallel Enumeration
--------------------

Sometimes it's useful to work on multiple arrays in parallel. For example, imagine that you have two arrays of strings and you want to create a third array that contains the contents of the two arrays combined into a single string. With MACollectionUtilities this is extremely easy:

    NSArray *first = ARRAY(@"alpha", @"air", @"bicy");
    NSArray *second = ARRAY(@"bet", @"plane", @"cle");
    NSArray *words = MAP(first, [obj stringByAppendingString: EACH(second)]);
    // words now contains alphabet, airplane, bicycle

The `EACH` macro depends on context set up by the other macros. You can *only* use it with the macros, not with the methods.

You can use multiple arrays with multiple `EACH` macros to enumerate several collections in parallel:

    NSArray *result = MAP(objects, [obj performSelector: NSSelectorFromString(EACH(selectorNames))
                                             withObject: EACH(firstArguments)
                                             withObject: EACH(secondArguments)];

The `EACH` macro works by creating and tracking an `NSEnumerator` internally. It lazily creates the enumerator on the first use, and then uses `nextObject` at each call. Thus if your arrays are not the same length, it will begin to return `nil`, watch out.
