printf
=======

C printf for Haxe.

See [cplusplus.com](http://www.cplusplus.com/reference/clibrary/cstdio/printf/) for a complete reference.

## New features

### Variable number of arguments

If there is more than one argument (or if the only argument passed is not an array), `Printf` will use the arguments as is:
````As3
Printf.format("This is %s", "acceptable");
Printf.format("This is also %s", ["acceptable"]);
````
### Numbered parameters
Arguments can now be accessed by number via the following format:

`%[argnumber$][flags][width][.precision][length]specifier`

_Note: The number 1 refers to the first argument, not 0:_

````As3
Printf.format("%s is %d years old, and his name is %1$s", ["Joe", 32]);
````

### Named parameters
Arguments can now be specified as named properties of an object using the following format:

`%(name)`

_Named arguments will always refer to the first parameter._

_Named Parameters can even be used in conjunction with other argument types:_
 
````As3
Printf.format("%(name) is %(age), and wants to be a %2$s", {name:"Joe", age:32}, "Programmer");
````

### Compile-time checks

If the format string is inline, several checks can be done at compile time, and they can issue an error or warning during the compile.

#### Format string verification

An incorrect format string will throw an error:
````As3
Printf.format("%m", 3); // Compile-time error: invalid format specifier
````

#### Not enough arguments

Compilation will fail if there are not enough arguments passed for the number of specifiers given:
````As3
Printf.format("%s %s %s", "bob", "joe"); //compile-time error: Not enough arguments
````

#### Width and precision

Widths and precisions are checked at compile time when possible:
````As3
Printf.format("Age/3 = %.*f", 10.1, 2); //compile-time error: precision must be an integer
Printf.format("Age/3 = %*f", 10.1, 4); //compile-time error: width must be an integer
````

#### Number types

The value's type is checked whenever possible:
````As3
Printf.format("%f", "5"); //compile-time error: the value must be a number
Printf.format("%d", 4.1); //complile-time error: the value must be an integer
````

#### Flag mis-matches (warning)
A compiler warning will be issued for flag combinations that don't make sense:
````As3
Printf.format("% +f", 3.1); //compile-time warning: ` ' flag ignored with '+' flag in printf format
````

#### Unused arguments (warning)
If compiled with `-D verbose', a compiler warning will be issued for arguments that are left unused:
````As3
Printf.format("%s", "first", "second"); //compile-time warning: unused parameters
````

## Changelog

### 1.0.2-beta (released 2013-11-05)

 * fixed: fix cpp compile error

### 1.0.1-beta (released 2013-11-04)

 * fixed: double minus for %f

### 1.0.0-beta (released 2013-07-08)

 * Initial release.