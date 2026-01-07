// cityhashcrc.c3
//
// CityHashCrc implementation in C3 (requires SSE4.2)
// Translated from cityhash-c
// Copyright (c) 2011-2012, Alexander Nusov
// Original copyright (c) 2011 Google, Inc.
//
// This file declares the subset of the CityHash functions that require
// _mm_crc32_u64(). See the CityHash README for details.
//
// Functions in the CityHash family are not suitable for cryptography.

module cityhash;

import cityhash;
import std::io;

// Note: This module requires SSE4.2 support
// Compile with: -target x86_64 --feature sse4.2

$if env::X86_64 && env::SSE4_2:

// Intrinsic function declarations for SSE4.2 CRC32 instructions
extern fn ulong @crc32_u64(ulong crc, ulong value) @builtin;

// Requires len >= 240
fn void city_hash_crc256_long(char* s, usz len, uint seed, ulong* result)
{
    ulong a = cityhash::fetch64(s + 56) + cityhash::K0;
    ulong b = cityhash::fetch64(s + 96) + cityhash::K0;
    ulong c = result[0] = cityhash::hash_len16(b, len);
    ulong d = result[1] = cityhash::fetch64(s + 120) * cityhash::K0 + len;
    ulong e = cityhash::fetch64(s + 184) + seed;
    ulong f = seed;
    ulong g = 0;
    ulong h = 0;
    ulong i = 0;
    ulong j = 0;
    ulong t = c + d;
    
    // 240 bytes of input per iter
    usz iters = len / 240;
    len -= iters * 240;
    
    while (iters > 0) {
        // Macro-like inline block repeated 6 times
        for (int chunk_idx = 0; chunk_idx < 6; chunk_idx++) {
            ulong multiplier = (chunk_idx % 2 == 0) ? 1 : cityhash::K0;
            int z = (chunk_idx % 2 == 0) ? 1 : 0;
            
            ulong old_a = a;
            a = cityhash::rotate(b, 41 ^ z) * multiplier + cityhash::fetch64(s);
            b = cityhash::rotate(c, 27 ^ z) * multiplier + cityhash::fetch64(s + 8);
            c = cityhash::rotate(d, 41 ^ z) * multiplier + cityhash::fetch64(s + 16);
            d = cityhash::rotate(e, 33 ^ z) * multiplier + cityhash::fetch64(s + 24);
            e = cityhash::rotate(t, 25 ^ z) * multiplier + cityhash::fetch64(s + 32);
            t = old_a;
            
            f = @crc32_u64(f, a);
            g = @crc32_u64(g, b);
            h = @crc32_u64(h, c);
            i = @crc32_u64(i, d);
            j = @crc32_u64(j, e);
            s += 40;
        }
        iters--;
    }
    
    while (len >= 40) {
        ulong old_a = a;
        a = cityhash::rotate(b, 41) * cityhash::K0 + cityhash::fetch64(s);
        b = cityhash::rotate(c, 27) * cityhash::K0 + cityhash::fetch64(s + 8);
        c = cityhash::rotate(d, 41) * cityhash::K0 + cityhash::fetch64(s + 16);
        d = cityhash::rotate(e, 33) * cityhash::K0 + cityhash::fetch64(s + 24);
        e = cityhash::rotate(t, 25) * cityhash::K0 + cityhash::fetch64(s + 32);
        t = old_a;
        
        f = @crc32_u64(f, a);
        g = @crc32_u64(g, b);
        h = @crc32_u64(h, c);
        i = @crc32_u64(i, d);
        j = @crc32_u64(j, e);
        s += 40;
        len -= 40;
    }
    
    if (len > 0) {
        s = s + len - 40;
        ulong old_a = a;
        a = cityhash::rotate(b, 41) * cityhash::K0 + cityhash::fetch64(s);
        b = cityhash::rotate(c, 27) * cityhash::K0 + cityhash::fetch64(s + 8);
        c = cityhash::rotate(d, 41) * cityhash::K0 + cityhash::fetch64(s + 16);
        d = cityhash::rotate(e, 33) * cityhash::K0 + cityhash::fetch64(s + 24);
        e = cityhash::rotate(t, 25) * cityhash::K0 + cityhash::fetch64(s + 32);
        t = old_a;
        
        f = @crc32_u64(f, a);
        g = @crc32_u64(g, b);
        h = @crc32_u64(h, c);
        i = @crc32_u64(i, d);
        j = @crc32_u64(j, e);
    }
    
    j += i << 32;
    a = cityhash::hash_len16(a, j);
    h += g << 32;
    b += h;
    c = cityhash::hash_len16(c, f) + i;
    d = cityhash::hash_len16(d, e + result[0]);
    j += e;
    i += cityhash::hash_len16(h, t);
    e = cityhash::hash_len16(a, d) + j;
    f = cityhash::hash_len16(b, c) + a;
    g = cityhash::hash_len16(j, i) + c;
    result[0] = e + f + g + h;
    a = cityhash::shift_mix((a + g) * cityhash::K0) * cityhash::K0 + b;
    result[1] += a + result[0];
    a = cityhash::shift_mix(a * cityhash::K0) * cityhash::K0 + c;
    result[2] = a + result[1];
    a = cityhash::shift_mix((a + e) * cityhash::K0) * cityhash::K0;
    result[3] = a + result[2];
}

// Requires len < 240
fn void city_hash_crc256_short(char* s, usz len, ulong* result)
{
    char[240] buf;
    libc::memcpy(&buf, s, len);
    libc::memset(&buf[len], 0, 240 - len);
    city_hash_crc256_long(&buf, 240, ~(uint)len, result);
}

fn void city_hash_crc256(char* s, usz len, ulong* result)
{
    if (len >= 240) {
        city_hash_crc256_long(s, len, 0, result);
    } else {
        city_hash_crc256_short(s, len, result);
    }
}

fn uint128 city_hash_crc128_with_seed(char* s, usz len, uint128 seed)
{
    if (len <= 900) {
        return cityhash::city_hash128_with_seed(s, len, seed);
    } else {
        ulong[4] result;
        city_hash_crc256(s, len, &result);
        ulong u = cityhash::uint128_high64!(seed) + result[0];
        ulong v = cityhash::uint128_low64!(seed) + result[1];
        ulong first = cityhash::hash_len16(u, v + result[2]);
        ulong second = cityhash::hash_len16(cityhash::rotate(v, 32), u * cityhash::K0 + result[3]);
        return ((uint128)second << 64) | (uint128)first;
    }
}

fn uint128 city_hash_crc128(char* s, usz len)
{
    if (len <= 900) {
        return cityhash::city_hash128(s, len);
    } else {
        ulong[4] result;
        city_hash_crc256(s, len, &result);
        return ((uint128)result[3] << 64) | (uint128)result[2];
    }
}

$else

$endif
