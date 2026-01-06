# Project Structure

```
cityhash-c3/
├── manifest.json              # C3 vendor manifest
├── project.json               # C3 project configuration
├── cityhash.c3                # Main CityHash implementation
├── cityhash.c3i               # Module interface file
├── cityhashcrc.c3             # SSE4.2 CRC variants
├── example.c3                 # Usage examples
├── test.c3                    # Unit tests
├── build.sh                   # Build script
├── README.md                  # Main documentation
├── VENDOR.md                  # Vendor system guide
├── QUICKSTART.md              # Quick start guide
├── STRUCTURE.md               # This file
└── examples/
    └── simple/
        ├── main.c3            # Simple vendor example
        ├── project.json       # Example project config
        └── README.md          # Example documentation
```

## File Descriptions

### Core Library Files

- **manifest.json** - C3 vendor system manifest declaring this as the "cityhash" library
- **project.json** - Project configuration for building the library
- **cityhash.c3** - Main implementation with CityHash64 and CityHash128 functions
- **cityhash.c3i** - Module interface exposing public API
- **cityhashcrc.c3** - Optional SSE4.2-optimized variants (CityHashCrc128, CityHashCrc256)

### Examples and Tests

- **example.c3** - Comprehensive examples showing all hash functions
- **test.c3** - Unit tests verifying correctness and consistency
- **examples/simple/** - Complete example project using vendor system

### Documentation

- **README.md** - Main documentation with installation and API reference
- **VENDOR.md** - Complete guide for using as a vendor library
- **QUICKSTART.md** - Quick start guide for common use cases
- **STRUCTURE.md** - This file, explaining project organization

### Build Tools

- **build.sh** - Shell script for building library, examples, and tests

## Usage Patterns

### As a Vendor Library

Users add this to their project using:

```bash
$ c3c vendor fetch cityhash --url <git-url>
```

Then import and use:

```c3
import cityhash;
ulong hash = cityhash::CityHash64(data, len);
```

### Direct Integration

Copy files to project and compile together:

```bash
c3c compile cityhash.c3 myapp.c3 -o myapp
```

### As a Static Library

Build and link separately:

```bash
./build.sh lib
c3c compile myapp.c3 -l cityhash -L .
```

## Vendor System Integration

The key files for vendor integration are:

1. **manifest.json** - Declares this library provides "cityhash"
2. **cityhash.c3i** - Defines the module interface
3. **project.json** - Specifies build configuration

When a user runs `c3c vendor fetch`, the C3 compiler:
1. Downloads these files
2. Reads manifest.json to identify the library
3. Uses cityhash.c3i to understand the API
4. Compiles cityhash.c3 when building user's project

## Module Organization

```
module cityhash
├── Public API (exported functions)
│   ├── CityHash64
│   ├── CityHash64WithSeed
│   ├── CityHash64WithSeeds
│   ├── CityHash128
│   └── CityHash128WithSeed
├── Helper Functions (inline, exported for advanced use)
│   ├── fetch64, fetch32
│   ├── rotate, shift_mix
│   └── hash_len16
└── Internal Functions (not exported)
    ├── hash_len0to16
    ├── hash_len17to32
    ├── hash_len33to64
    └── weak_hash_len32_with_seeds

module cityhashcrc (optional, requires SSE4.2)
├── Public API
│   ├── CityHashCrc128
│   ├── CityHashCrc128WithSeed
│   └── CityHashCrc256
└── Internal Functions
    ├── city_hash_crc256_long
    └── city_hash_crc256_short
```

## Building for Distribution

### Prepare for Publishing

1. Ensure all files are present
2. Update version in manifest.json and project.json
3. Test with example projects
4. Create git tag for version

### Publishing

```bash
git tag v1.0.0
git push origin v1.0.0
```

Users can then fetch with:

```bash
c3c vendor fetch cityhash --url <your-repo-url> --tag v1.0.0
```

## Customization

### Adding New Hash Functions

1. Add implementation to cityhash.c3
2. Declare in cityhash.c3i with @export
3. Update README.md with documentation
4. Add tests to test.c3
5. Add examples to example.c3

### Platform-Specific Optimizations

Use C3's conditional compilation:

```c3
$if env::X86_64:
    // x86-64 specific code
$elif env::ARM64:
    // ARM64 specific code
$else
    // Generic code
$endif
```

## Development Workflow

### Local Development

```bash
# Make changes to cityhash.c3
# Test immediately
./build.sh test
./cityhash_test

# Try examples
./build.sh example
./cityhash_example
```

### Testing as Vendor Library

```bash
# Build example project
./build.sh vendor-example

# Or manually
cd examples/simple
c3c build
./build/simple_example
```

### Release Process

1. Update version numbers
2. Run all tests
3. Build all targets
4. Update CHANGELOG
5. Create git tag
6. Push to repository

## Dependencies

### C3 Language

- Minimum version: 0.6.0
- Uses: module system, uint128, conditional compilation

### System Requirements

- **Basic**: Any platform with C3 compiler
- **Optimized**: x86-64 with SSE4.2 (optional)

### External Libraries

None. This is a standalone library with no dependencies.

## File Sizes

Approximate sizes:

- cityhash.c3: ~14 KB
- cityhashcrc.c3: ~7 KB
- cityhash.c3i: ~1 KB
- example.c3: ~4 KB
- test.c3: ~7 KB
- Documentation: ~20 KB

Total: ~53 KB

## Performance Characteristics

- **Compilation**: Fast, single-pass
- **Binary Size**: ~10-15 KB compiled code
- **Runtime**: Near C performance (native code generation)

## Future Enhancements

Possible additions:

- ARM NEON optimizations
- RISC-V vector extensions
- Additional hash function variants
- Streaming API for large files
- Incremental hashing support

## Contributing

When contributing:

1. Maintain C3 style conventions
2. Update relevant documentation
3. Add tests for new features
4. Ensure vendor example still works
5. Update version numbers appropriately

## License

MIT License - see README.md for full text
