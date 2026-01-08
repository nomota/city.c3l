# CityHash C3 Implementation

This is a C3 language port of Google's CityHash, a family of fast hash functions for strings. The original implementation was in C++ and this is based on the C port by Alexander Nusov.

## About CityHash

CityHash provides hash functions for byte arrays (strings). On x86-64 hardware, `city::hash64()` is faster than other high-quality hash functions due to higher instruction-level parallelism.

**Important**: Functions in the CityHash family are **NOT suitable for cryptography**.

## Installation

### Using C3 library manager (Recommended)

Add CityHash to your project using the C3 library manager:

```bash
# Install "c3l" library manager
$ git clone https://github.com/konimarti/c3l
$ cd c3l
$ sudo make install

# At your C3 project dir (initiated by "c3c init")
$ c3l fetch https://github.com/nomota/city.c3l
# This command downloads CityHash library into ./lib dir as a zip compressed file
# This command adds dependancy in project.json
```

### Import in your code:
```c3
import city;
```

## Features

- **city::hash64**: Fast 64-bit hash function
- **city::hash128**: 128-bit hash function, optimized for strings > 2000 bytes
- **city::hash128_crc**: Variants using SSE4.2 CRC32 instructions (requires SSE4.2 support)

## Files

- `city.c3` - Main CityHash implementation (64-bit and 128-bit variants)
- `citycrc.c3` - CRC-based variants requiring SSE4.2 (optional)
- `example.c3` - Example usage and test cases
- `project.json` - C3 project configuration
-`manifest.json`

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
fn ulong city::hash64(char* buf, usz len);
fn ulong city::hash64_with_seed(char* buf, usz len, ulong seed);
fn ulong city::hash64_with_seeds(char* buf, usz len, ulong seed0, ulong seed1);
```

### CityHash128
```c3
fn uint128 city::hash128(char* s, usz len);
fn uint128 city::hash128_with_seed(char* s, usz len, uint128 seed);
```

### CityHashCrc (requires SSE4.2)
```c3
fn uint128 city::hash128_crc(char* s, usz len);
fn uint128 city::hash128_crc_with_seed(char* s, usz len, uint128 seed);
fn void city::hash256_crc(char* s, usz len, ulong* result);
```

## Usage Example

```c3
import city;
import std::io;

fn void main()
{
    String text = "Hello, World!";
    
    // 64-bit hash
    ulong hash64 = city::hash64(text.ptr, text.len);
    io::printfn("Hash64: 0x%016x", hash64);
    
    // 128-bit hash
    uint128 hash128 = city::hash128(text.ptr, text.len);
    ulong low = city::uint128_low64(hash128);
    ulong high = city::uint128_high64(hash128);
    io::printfn("Hash128: 0x%016llx%016x", high, low);
}
```

## Building

### Basic Build (without SSE4.2)
```bash
$ c3c compile city.c3 example.c3
```

### Build with SSE4.2 Support
```bash
$ c3c compile city.c3 citycrc.c3 example.c3 --target x86_64 --feature sse4.2
```

## Project Structure

```
.
├── city.c3           # Main hash functions
├── citycrc.c3        # SSE4.2 optimized variants
├── example.c3        # Usage examples
├── manifest.json     # C3 project file
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

## Credits

- **Original Authors**: Geoff Pike and Jyrki Alakuijala (Google)
- **C Port**: Alexander Nusov
- **C3 Port**: Nomota Hiongun Kim (hiongun@gmail.com)

## References

- [Original CityHash Repository](https://github.com/google/cityhash)
- [C3 Language](https://c3-lang.org/)
- [CityHash Paper](https://arxiv.org/abs/1612.06793)
