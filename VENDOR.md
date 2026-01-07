# CityHash C3 - Vendor Installation Guide

This guide shows how to use CityHash as a C3 vendor library.

## Installation Methods

### Method 1: Direct Vendor Fetch (Recommended)

If this library is published to a Git repository:

```bash
# Add to your project
$ c3c vendor fetch cityhash --url https://github.com/nomota/cityhash-c3.git

# Or with specific version
$ c3c vendor fetch cityhash --url https://github.com/nomota/cityhash-c3.git --tag v1.0.0
```

### Method 2: Local Vendor

1. Clone or copy this library to your project:
```bash
$ mkdir -p vendor
$ cd vendor
$ git clone https://github.com/nomota/cityhash-c3.git cityhash
# Or copy the files manually
```

2. Your project structure should look like:
```
your-project/
├── vendor/
│   └── cityhash/
│       ├── manifest.json
│       ├── cityhash.c3
│       ├── cityhash.c3i
│       └── cityhashcrc.c3
├── src/
│   └── main.c3
└── project.json
```

### Method 3: Add to project.json

Add to your `project.json`:

```json
{
  "dependencies": {
    "cityhash": {
      "path": "./vendor/cityhash"
    }
  }
}
```

Or for remote:

```json
{
  "dependencies": {
    "cityhash": {
      "git": "https://github.com/nomota/cityhash-c3.git",
      "tag": "v1.0.0"
    }
  }
}
```

## Usage in Your Project

### Basic Import

```c3
module myapp;

import cityhash;
import std::io;

fn void main()
{
    String text = "Hello from vendor!";
    ulong hash = cityhash::CityHash64(text.ptr, text.len);
    io::printfn("Hash: 0x%016llx", hash);
}
```

### Compile Your Project

```bash
# C3 will automatically include vendor libraries
$ c3c compile src/main.c3

# Or with project.json
$ c3c build
```

## Complete Example Project

### Directory Structure
```
my-project/
├── vendor/
│   └── cityhash/           # CityHash library
├── src/
│   └── main.c3             # Your code
└── project.json
```

### project.json
```json
{
  "name": "my-app",
  "version": "1.0.0",
  "authors": ["Your Name"],
  "langrev": "1",
  "targets": {
    "my-app": {
      "type": "executable"
    }
  },
  "dependencies": {
    "cityhash": {
      "path": "./vendor/cityhash"
    }
  }
}
```

### src/main.c3
```c3
module myapp;

import cityhash;
import std::io;

fn void main()
{
    // Use CityHash64
    String data = "Sample data to hash";
    ulong hash64 = cityhash::CityHash64(data.ptr, data.len);
    io::printfn("CityHash64: 0x%016llx", hash64);
    
    // Use CityHash128
    uint128 hash128 = cityhash::CityHash128(data.ptr, data.len);
    ulong low = cityhash::uint128_low64!(hash128);
    ulong high = cityhash::uint128_high64!(hash128);
    io::printfn("CityHash128: 0x%016llx%016llx", high, low);
    
    // Hash with seed
    ulong seed = 0x12345678;
    ulong hash_seeded = cityhash::CityHash64WithSeed(data.ptr, data.len, seed);
    io::printfn("With seed: 0x%016llx", hash_seeded);
}
```

### Build and Run
```bash
$ c3c build
$ ./build/my-app
```

## Advanced Usage

### Using SSE4.2 Optimizations

If you want to use the CRC variants (requires SSE4.2):

```c3
module myapp;

import cityhash;
import cityhashcrc;  // Add this for CRC variants
import std::io;

fn void main()
{
    String data = "Large data for CRC hashing";
    
    // Regular hash
    uint128 hash = cityhash::CityHash128(data.ptr, data.len);
    
    // CRC-optimized hash (faster for long strings)
    uint128 hash_crc = cityhashcrc::CityHashCrc128(data.ptr, data.len);
    
    // 256-bit CRC hash
    ulong[4] result;
    cityhashcrc::CityHashCrc256(data.ptr, data.len, &result);
}
```

Compile with SSE4.2:
```bash
$ c3c build --target x86_64 --feature sse4.2
```

## Vendor Commands

### Update Library
```bash
$ c3c vendor update cityhash
```

### Remove Library
```bash
$ c3c vendor remove cityhash
```

### List Installed Libraries
```bash
$ c3c vendor list
```

### Check for Updates
```bash
$ c3c vendor outdated
```

## Troubleshooting

### Library Not Found
```bash
# Make sure vendor directory exists
$ ls vendor/cityhash/

# Verify manifest.json
$ cat vendor/cityhash/manifest.json

# Try explicit path in project.json
```

### Compilation Errors
```bash
# Clean build
$ c3c clean

# Rebuild with verbose output
$ c3c build --debug-log

# Check C3 version
$ c3c --version
```

### SSE4.2 Not Available
If you get SSE4.2 errors:
- Don't import `cityhashcrc` module
- Only use basic `cityhash` functions
- Or compile without SSE4.2 features

## Version Compatibility

- **C3 Version**: Requires C3 0.6.0 or later
- **Platform**: Works on all platforms (optimized for x86-64)
- **SSE4.2**: Optional, only for CRC variants

## Publishing Your Own Fork

To publish this library for easy vendor access:

1. **Create Git Repository**
   ```bash
   $ git init
   $ git add .
   $ git commit -m "Initial CityHash C3 library"
   ```

2. **Push to GitHub**
   ```bash
   $ git remote add origin https://github.com/nomota/cityhash-c3.git
   $ git push -u origin main
   ```

3. **Tag Version**
   ```bash
   $ git tag v1.0.0
   $ git push origin v1.0.0
   ```

4. **Users Can Now Fetch**
   ```bash
   $ c3c vendor fetch cityhash --url https://github.com/YOUR_NAME/cityhash-c3.git
   ```

## Example Projects Using This Library

```
examples/
├── simple/          # Basic usage
├── hashtable/       # Hash table implementation
├── checksum/        # File checksum tool
└── benchmark/       # Performance tests
```

See the `examples/` directory for complete working examples.

## Support

For vendor-specific issues:
1. Check C3 vendor documentation: https://c3-lang.org/
2. Verify manifest.json format
3. Ensure compatible C3 version
4. Check directory structure

For CityHash functionality:
- See main [README.md](README.md)
- Check [QUICKSTART.md](QUICKSTART.md)
- Run included tests: `c3c run test.c3`

## Quick Reference

```bash
# Install
$ c3c vendor fetch cityhash --url <git-url>

# Use in code
import cityhash;
ulong hash = cityhash::CityHash64(data, len);

# Build project
$ c3c build

# Update
$ c3c vendor update cityhash

# Remove
$ c3c vendor remove cityhash
```

Happy hashing with C3 vendor! 🚀
