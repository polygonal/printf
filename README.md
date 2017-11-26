# printf

C printf for Haxe.

See [cplusplus.com](http://www.cplusplus.com/reference/clibrary/cstdio/printf/) for a complete reference.

## Additional features

### Binary format

`%b` converts a given integer into binary format (same flags as for integers):

````Haxe
Printf.format("%b", [7]); //outputs "111"
Printf.format("%#b", [0x100]); //outputs "0b100000000"
````

## Changelog

### 1.1 (wip)

- various fixes and optimizations.

### 1.0.2-beta (released 2013-11-05)

- fixed: fix cpp compile error

### 1.0.1-beta (released 2013-11-04)

- fixed: double minus for %f

### 1.0.0-beta (released 2013-07-08)

- Initial release.