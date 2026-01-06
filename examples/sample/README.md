# Simple CityHash Vendor Example

This example demonstrates how to use CityHash as a vendor library in your C3 project.

## Project Structure

```
examples/simple/
├── main.c3          # Example code
├── project.json     # Project configuration with vendor dependency
└── README.md        # This file
```

## Running the Example

### From the example directory:

```bash
$ cd examples/simple
$ c3c build
$ ./build/simple_example
```

### Expected Output:

```
=== CityHash Vendor Example ===

Text: 'Hello, C3 Vendor!'
Hash: 0x...

Hash with seed 0xDEADBEEF: 0x...

128-bit hash: 0x...

=== Hashing Multiple Strings ===
[0] 'apple' -> 0x...
[1] 'banana' -> 0x...
[2] 'cherry' -> 0x...
[3] 'date' -> 0x...
[4] 'elderberry' -> 0x...

✓ CityHash vendor library working correctly!
```

## Key Points

1. **Dependency Declaration**: The `project.json` includes CityHash as a dependency:
   ```json
   "dependencies": {
     "cityhash": {
       "path": "../../"
     }
   }
   ```

2. **Import Statement**: Simply import the module:
   ```c3
   import cityhash;
   ```

3. **Usage**: Use the hash functions directly:
   ```c3
   ulong hash = cityhash::CityHash64(text.ptr, text.len);
   ```

## Adapting for Your Project

To use this in your own project:

1. Change the dependency path to match your structure:
   ```json
   "cityhash": {
     "path": "./vendor/cityhash"
   }
   ```

2. Or use a Git URL if published:
   ```json
   "cityhash": {
     "git": "https://github.com/nomota/cityhash-c3.git"
   }
   ```

3. Copy the import and usage patterns from `main.c3`

## See Also

- [../../VENDOR.md](../../VENDOR.md) - Comprehensive vendor guide
- [../../README.md](../../README.md) - Full library documentation
- [../../QUICKSTART.md](../../QUICKSTART.md) - Quick start guide
