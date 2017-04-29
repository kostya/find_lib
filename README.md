# find_lib

Find dynamic libary in system paths, multiplatform (to use dlopen and dlsym).

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  find_lib:
    github: kostya/find_lib
```

## Usage

```crystal
require "find_lib"

p FindLib.find("icutu") # => ["/usr/lib/libicutu.so.48"]
p FindLib.find(["icui18n", "icutu"]) # => ["/usr/lib/libicui18n.so.48", "/usr/lib/libicutu.so.48"]
```
