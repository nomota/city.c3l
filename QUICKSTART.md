# CityHash C3 - Quick Start Guide

## Prerequisites

1. **C3 Compiler**: Install from [c3-lang.org](https://c3-lang.org/)
2. **x86-64 System**: Recommended for best performance
3. **SSE4.2 Support**: Optional, for CityHashCrc variants

Check your CPU for SSE4.2 support:
```bash
# Linux
$ grep -o 'sse4_2' /proc/cpuinfo | head -1

# macOS
$ sysctl -a | grep SSE4.2
```

## 5-Minute Quick Start

### 1. Build Everything
```bash
$ chmod +x build.sh
$ ./build.sh all
```

### 2. Run Examples
```bash
$ ./cityhash_example
```

### 3. Run Tests
```bash
$ ./cityhash_test
```

## Basic Usage

### Simple Hash (64-bit)
```c3
import cityhash;
import std::io;

fn void main() {
    String text = "Hello, World!";
    ulong hash = cityhash::CityHash64(text.ptr, text.len);
    io::printfn("Hash: 0x%016llx", hash);
}
```

Save as `myhash.c3` and compile:
```bash
$ c3c compile cityhash.c3 myhash.c3 -o myhash
$ ./myhash
```

### Hash with Seed
```c3
import cityhash;

fn ulong hash_with_salt(String text, String salt) {
    // Use salt as seed
    ulong seed = cityhash::CityHash64(salt.ptr, salt.len);
    return cityhash::CityHash64WithSeed(text.ptr, text.len, seed);
}
```

### 128-bit Hash
```c3
import cityhash;

fn uint128 hash_large_data(char* data, usz len) {
    return cityhash::CityHash128(data, len);
}

fn void print_hash128(uint128 hash) {
    ulong low = cityhash::uint128_low64!(hash);
    ulong high = cityhash::uint128_high64!(hash);
    io::printfn("0x%016llx%016llx", high, low);
}
```

## Common Use Cases

### 1. Hash Table Key
```c3
struct MyHashTable {
    // ... your hash table implementation
}

fn usz hash_key(String key) {
    ulong hash = cityhash::CityHash64(key.ptr, key.len);
    return (usz)(hash & 0x7FFFFFFF); // Fit to table size
}
```

### 2. File Checksum
```c3
import std::io;

fn ulong hash_file(String filepath) {
    File? file = file::open(filepath, "rb");
    if (catch err = file) {
        return 0;
    }
    
    char[] buffer = mem::new_array(char, 8192);
    defer mem::free(buffer);
    
    ulong hash = 0;
    while (true) {
        usz bytes_read = (usz)file.read(buffer)!!;
        if (bytes_read == 0) break;
        
        hash ^= cityhash::CityHash64(&buffer[0], bytes_read);
    }
    
    file.close()!!;
    return hash;
}
```

### 3. Consistent Hashing
```c3
fn uint get_server_for_key(String key, uint server_count) {
    ulong hash = cityhash::CityHash64(key.ptr, key.len);
    return (uint)(hash % server_count);
}
```

### 4. Cache Key Generation
```c3
fn String generate_cache_key(String user_id, String resource, long timestamp)
{
    DString builder;
    builder.new_init();
    builder.appendf("%s:%s:%d", user_id, resource, timestamp);
    
    ulong hash = cityhash::CityHash64(builder.str_view().ptr, builder.len());
    
    String result = builder.str_view().copy();
    builder.free();
    
    return result;
}
```

## Performance Tips

1. **Choose the Right Function**
   - Strings < 64 bytes: Use `CityHash64`
   - Strings 64-2000 bytes: Use `CityHash64`
   - Strings > 2000 bytes: Use `CityHash128`
   - Very long strings + SSE4.2: Use `CityHashCrc128`

2. **Minimize Copies**
   ```c3
   // Good: Hash directly
   ulong hash = cityhash::CityHash64(data.ptr, data.len);
   
   // Bad: Unnecessary copy
   char[] copy = data.copy();
   ulong hash = cityhash::CityHash64(&copy[0], copy.len);
   ```

3. **Reuse Seeds**
   ```c3
   // Calculate seed once
   const ulong MY_SEED = 0x1234567890ABCDEF;
   
   fn ulong hash_with_app_seed(String s) {
       return cityhash::CityHash64WithSeed(s.ptr, s.len, MY_SEED);
   }
   ```

## Building Options

### Static Library
```bash
$ ./build.sh lib          # Without SSE4.2
$ ./build.sh lib-sse      # With SSE4.2
```

### Link Against Your Project
```bash
$ c3c compile myapp.c3 -l cityhash -L .
```

### Single File Compile
```bash
$ c3c compile cityhash.c3 myapp.c3 -o myapp
```

## Troubleshooting

### Linker Errors
If you get undefined reference errors:
```bash
# Make sure to link against libc
$ c3c compile cityhash.c3 myapp.c3 -o myapp --linker-args "-lc"
```

### SSE4.2 Not Available
If compilation fails with SSE4.2 errors:
```bash
# Build without SSE4.2
$ c3c compile cityhash.c3 myapp.c3 -o myapp
# Don't import cityhashcrc module
```

### Big-Endian Systems
The code should work on big-endian systems, but hash values will differ from x86-64. This is expected behavior to maintain performance.

## Integration Examples

### As Git Submodule
```bash
$ git submodule add https://github.com/yourusername/cityhash-c3.git deps/cityhash
```

In your project:
```c3
import cityhash;  // From deps/cityhash/cityhash.c3
```

### project.json
```json
{
  "dependencies": {
    "cityhash": {
      "path": "./deps/cityhash"
    }
  }
}
```

## What's Next?

- Read [README.md](README.md) for detailed documentation
- Check [example.c3](example.c3) for more examples
- Run [test.c3](test.c3) to verify installation
- See original [CityHash documentation](https://github.com/google/cityhash)

## Common Questions

**Q: Can I use this for cryptography?**  
A: No! CityHash is NOT cryptographically secure. Use a proper crypto library for security purposes.

**Q: Will hash values be the same as the C version?**  
A: Yes, for the same input on the same architecture, hash values should match the original C implementation.

**Q: Is it thread-safe?**  
A: Yes, all functions are stateless and thread-safe.

**Q: What about performance compared to C?**  
A: Performance should be nearly identical since C3 compiles to native code similar to C.

## Support

For bugs or questions:
- Check the examples in this repository
- Review the original CityHash documentation
- Open an issue on the project repository

Happy hashing! 🚀
