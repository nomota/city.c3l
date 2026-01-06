// test.c3
//
// Unit tests for CityHash C3 implementation

module test;

import cityhash;
import std::io;

// Known test vectors from the original CityHash implementation
struct TestVector
{
    String input;
    ulong expected_hash64;
    uint128 expected_hash128;
}

fn bool test_cityhash64()
{
    io::printfn("\n=== Testing CityHash64 ===");
    bool all_passed = true;
    
    // Test empty string
    String empty = "";
    ulong hash_empty = cityhash::CityHash64(empty.ptr, empty.len);
    io::printfn("Empty string: 0x%016llx", hash_empty);
    
    // Test short strings
    String[5] test_strings = {
        "a",
        "ab",
        "abc",
        "Hello",
        "Hello, World!"
    };
    
    for (int i = 0; i < test_strings.len; i++) {
        String s = test_strings[i];
        ulong hash = cityhash::CityHash64(s.ptr, s.len);
        io::printfn("'%s' -> 0x%016llx", s, hash);
    }
    
    // Test longer strings
    String long_text = "The quick brown fox jumps over the lazy dog. " ++
                       "Pack my box with five dozen liquor jugs. " ++
                       "How vexingly quick daft zebras jump!";
    ulong hash_long = cityhash::CityHash64(long_text.ptr, long_text.len);
    io::printfn("Long text -> 0x%016llx", hash_long);
    
    return all_passed;
}

fn bool test_cityhash64_with_seed()
{
    io::printfn("\n=== Testing CityHash64WithSeed ===");
    bool all_passed = true;
    
    String text = "test";
    ulong seed1 = 0x0000000000000000;
    ulong seed2 = 0xFFFFFFFFFFFFFFFF;
    ulong seed3 = 0x1234567890ABCDEF;
    
    ulong hash1 = cityhash::CityHash64WithSeed(text.ptr, text.len, seed1);
    ulong hash2 = cityhash::CityHash64WithSeed(text.ptr, text.len, seed2);
    ulong hash3 = cityhash::CityHash64WithSeed(text.ptr, text.len, seed3);
    
    io::printfn("'%s' with seed 0x%016llx -> 0x%016llx", text, seed1, hash1);
    io::printfn("'%s' with seed 0x%016llx -> 0x%016llx", text, seed2, hash2);
    io::printfn("'%s' with seed 0x%016llx -> 0x%016llx", text, seed3, hash3);
    
    // Different seeds should produce different hashes
    if (hash1 == hash2 || hash1 == hash3 || hash2 == hash3) {
        io::printfn("WARNING: Different seeds produced same hash!");
        all_passed = false;
    } else {
        io::printfn("✓ Different seeds produce different hashes");
    }
    
    return all_passed;
}

fn bool test_cityhash128()
{
    io::printfn("\n=== Testing CityHash128 ===");
    bool all_passed = true;
    
    String[4] test_strings = {
        "",
        "a",
        "Hello, World!",
        "The quick brown fox jumps over the lazy dog"
    };
    
    for (int i = 0; i < test_strings.len; i++) {
        String s = test_strings[i];
        uint128 hash = cityhash::CityHash128(s.ptr, s.len);
        ulong low = cityhash::uint128_low64!(hash);
        ulong high = cityhash::uint128_high64!(hash);
        
        if (s.len == 0) {
            io::printfn("(empty) -> 0x%016llx%016llx", high, low);
        } else {
            io::printfn("'%s' -> 0x%016llx%016llx", s, high, low);
        }
    }
    
    return all_passed;
}

fn bool test_collision_resistance()
{
    io::printfn("\n=== Testing Collision Resistance ===");
    bool all_passed = true;
    
    // Test similar strings
    String[10] similar = {
        "hash",
        "Hash",
        "hahs",
        "hashing",
        "hashes",
        "hasher",
        "hashmap",
        "hashtable",
        "hashcode",
        "hashbrown"
    };
    
    ulong[10] hashes;
    for (int i = 0; i < similar.len; i++) {
        hashes[i] = cityhash::CityHash64(similar[i].ptr, similar[i].len);
    }
    
    // Check for collisions
    int collisions = 0;
    for (int i = 0; i < similar.len; i++) {
        for (int j = i + 1; j < similar.len; j++) {
            if (hashes[i] == hashes[j]) {
                io::printfn("COLLISION: '%s' and '%s' -> 0x%016llx", 
                           similar[i], similar[j], hashes[i]);
                collisions++;
                all_passed = false;
            }
        }
    }
    
    if (collisions == 0) {
        io::printfn("✓ No collisions found among %d similar strings", similar.len);
    } else {
        io::printfn("✗ Found %d collision(s)", collisions);
    }
    
    return all_passed;
}

fn bool test_consistency()
{
    io::printfn("\n=== Testing Hash Consistency ===");
    bool all_passed = true;
    
    String text = "consistency test";
    
    // Hash the same string multiple times
    ulong hash1 = cityhash::CityHash64(text.ptr, text.len);
    ulong hash2 = cityhash::CityHash64(text.ptr, text.len);
    ulong hash3 = cityhash::CityHash64(text.ptr, text.len);
    
    if (hash1 == hash2 && hash2 == hash3) {
        io::printfn("✓ Hash is consistent: 0x%016llx", hash1);
    } else {
        io::printfn("✗ Hash is NOT consistent!");
        io::printfn("  hash1: 0x%016llx", hash1);
        io::printfn("  hash2: 0x%016llx", hash2);
        io::printfn("  hash3: 0x%016llx", hash3);
        all_passed = false;
    }
    
    return all_passed;
}

fn bool test_length_sensitivity()
{
    io::printfn("\n=== Testing Length Sensitivity ===");
    bool all_passed = true;
    
    String base = "test";
    String[4] variations = {
        "tes",     // shorter
        "test",    // same
        "teste",   // longer by 1
        "tester"   // longer by 2
    };
    
    ulong[4] hashes;
    for (int i = 0; i < variations.len; i++) {
        hashes[i] = cityhash::CityHash64(variations[i].ptr, variations[i].len);
        io::printfn("'%s' (len=%d) -> 0x%016llx", 
                   variations[i], variations[i].len, hashes[i]);
    }
    
    // All should be different
    for (int i = 0; i < variations.len; i++) {
        for (int j = i + 1; j < variations.len; j++) {
            if (hashes[i] == hashes[j]) {
                io::printfn("✗ Collision between '%s' and '%s'", 
                           variations[i], variations[j]);
                all_passed = false;
            }
        }
    }
    
    if (all_passed) {
        io::printfn("✓ Different lengths produce different hashes");
    }
    
    return all_passed;
}

fn void main()
{
    io::printfn("========================================");
    io::printfn("CityHash C3 Implementation - Test Suite");
    io::printfn("========================================");
    
    bool all_passed = true;
    
    all_passed &= test_cityhash64();
    all_passed &= test_cityhash64_with_seed();
    all_passed &= test_cityhash128();
    all_passed &= test_collision_resistance();
    all_passed &= test_consistency();
    all_passed &= test_length_sensitivity();
    
    io::printfn("\n========================================");
    if (all_passed) {
        io::printfn("✓ ALL TESTS PASSED");
    } else {
        io::printfn("✗ SOME TESTS FAILED");
    }
    io::printfn("========================================");
}
