# CityHash C3 Implementation

This is a C3 language port of Google's CityHash, a family of fast hash functions for strings. The original implementation was in C++ and this is based on the C port by Alexander Nusov.

## About CityHash

CityHash provides hash functions for byte arrays (strings). On x86-64 hardware, CityHash64() is faster than other high-quality hash functions due to higher instruction-level parallelism.

**Important**: Functions in the CityHash family are **NOT suitable for cryptography**.

## Installation

### Using C3 Vendor (Recommended)

Add CityHash to your project using the C3 vendor system:

```bash
# From Git repository (once published)
c3c vendor fetch cityhash --url https://github.com/nomota/cityhash-c3.git

# Or add to your project.json
{
  "dependencies": {
    "cityhash": {
      "git": "https://github.com/nomota/cityhash-c3.git",
      "tag": "v1.0.0"
    }
  }
}
```

### Manual Installation

1. Copy the library files to your project:
```bash
$ mkdir -p vendor/cityhash
$ cp cityhash.c3 cityhash.c3i manifest.json vendor/cityhash/
```

2. Add to your `project.json`:
```json
{
  "dependencies": {
    "cityhash": {
      "path": "./vendor/cityhash"
    }
  }
}
```

3. Import in your code:
```c3
import cityhash;
```

For detailed vendor usage, see [VENDOR.md](VENDOR.md).

## Features

- **CityHash64**: Fast 64-bit hash function
- **CityHash128**: 128-bit hash function, optimized for strings > 2000 bytes
- **CityHashCrc**: Variants using SSE4.2 CRC32 instructions (requires SSE4.2 support)

## Files

- `cityhash.c3` - Main CityHash implementation (64-bit and 128-bit variants)
- `cityhashcrc.c3` - CRC-based variants requiring SSE4.2 (optional)
- `example.c3` - Example usage and test cases
- `project.json` - C3 project configuration

## Key Differences from C

The C3 implementation includes several modernizations:

1. **Module System**: Uses C3's module system instead of header files
2. **Type Safety**: Better type checking with C3's type system
3. **Conditional Compilation**: Uses C3's compile-time conditionals (`$if`)
4. **Improved Macros**: Uses C3's macro system instead of C preprocessor
5. **Native uint128**: Uses C3's built-in `uint128` type
6. **Better Error Handling**: Cleaner error handling for unsupported features

## API Functions

### CityHash64
```c3
fn ulong cityhash::CityHash64(char* buf, usz len);
fn ulong cityhash::CityHash64WithSeed(char* buf, usz len, ulong seed);
fn ulong cityhash::CityHash64WithSeeds(char* buf, usz len, ulong seed0, ulong seed1);
```

### CityHash128
```c3
fn uint128 cityhash::CityHash128(char* s, usz len);
fn uint128 cityhash::CityHash128WithSeed(char* s, usz len, uint128 seed);
```

### CityHashCrc (requires SSE4.2)
```c3
fn uint128 city::CityHashCrc128(char* s, usz len);
fn uint128 cityhash::CityHashCrc128WithSeed(char* s, usz len, uint128 seed);
fn void cityhash::CityHashCrc256(char* s, usz len, ulong* result);
```

## Usage Example

```c3
import cityhash;
import std::io;

fn void main()
{
    String text = "Hello, World!";
    
    // 64-bit hash
    ulong hash64 = cityhash::CityHash64(text.ptr, text.len);
    io::printfn("Hash64: 0x%016llx", hash64);
    
    // 128-bit hash
    uint128 hash128 = cityhash::CityHash128(text.ptr, text.len);
    ulong low = cityhash::uint128_low64!(hash128);
    ulong high = cityhash::uint128_high64!(hash128);
    io::printfn("Hash128: 0x%016llx%016llx", high, low);
}
```

## Building

### Basic Build (without SSE4.2)
```bash
$ c3c compile cityhash.c3 example.c3 -o cityhash_example
```

### Build with SSE4.2 Support
```bash
$ c3c compile cityhash.c3 cityhashcrc.c3 example.c3 -o cityhash_example --target x86_64 --feature sse4.2
```

### Using as a Library
```bash
$ c3c compile cityhash.c3 --lib
```

## Project Structure

```
.
├── cityhash.c3       # Main hash functions
├── cityhashcrc.c3    # SSE4.2 optimized variants
├── example.c3        # Usage examples
├── project.json      # C3 project file
└── README.md         # This file
```

## Performance Characteristics

- **CityHash64**: 
  - Optimized for strings of any length
  - Best for general-purpose hashing on x86-64
  - High instruction-level parallelism
  
- **CityHash128**: 
  - Better than CityHash64 for strings > 2000 bytes
  - Returns 128-bit hash for better collision resistance
  
- **CityHashCrc128/256**: 
  - Requires SSE4.2 (available on most modern Intel/AMD CPUs)
  - Fastest for very long strings (> 900 bytes)
  - Uses hardware CRC32 instructions

## Platform Support

- **Primary Platform**: x86-64 with little-endian byte order
- **Big-Endian**: Should work but not extensively tested
- **SSE4.2**: Optional, required only for CityHashCrc variants

## Endianness Handling

The implementation includes automatic byte-swapping for big-endian platforms, maintaining consistent hash values across different architectures.

## Limitations

1. **Not Cryptographic**: Do not use for security purposes
2. **Not for Signatures**: Hash values can change between versions
3. **Little-Endian Optimized**: Best performance on little-endian systems
4. **Requires Aligned Access**: May be slower on platforms with strict alignment

## License

MIT License (same as original CityHash)

Copyright (c) 2011 Google, Inc.  
Copyright (c) 2011-2012 Alexander Nusov (C port)  
Copyright (c) 2025 (C3 port)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

## Credits

- **Original Authors**: Geoff Pike and Jyrki Alakuijala (Google)
- **C Port**: Alexander Nusov
- **C3 Port**: Nomota Hiongun Kim (hiongun@gmail.com)

## References

- [Original CityHash Repository](https://github.com/google/cityhash)
- [C3 Language](https://c3-lang.org/)
- [CityHash Paper](https://arxiv.org/abs/1612.06793)
