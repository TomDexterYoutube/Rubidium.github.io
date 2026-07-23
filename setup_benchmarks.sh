#!/usr/bin/env bash
# Creates two benchmark projects (fib-bench, sum-bench), each with the same
# program written in 5 languages: Rubidium, C, Rust, Python, Java.
#
# Rubidium uses Xeon's expected src/main.rub project layout.
#
# Usage: bash setup_benchmarks.sh

set -e
mkdir -p benchmarks
cd benchmarks

# ================= FIB(35) =================
mkdir -p fib-bench/src
cat > fib-bench/src/main.rub << 'EOF'
fn fib(n: i64) -> i64 {
    if n < 2 {
        return n
    }
    return fib(n - 1) + fib(n - 2)
}

fn main() {
    let result: i64 = fib(35)
    print(result)
}
EOF

cat > fib-bench/fib.c << 'EOF'
#include <stdio.h>

long fib(long n) {
    if (n < 2) return n;
    return fib(n - 1) + fib(n - 2);
}

int main() {
    printf("%ld\n", fib(35));
    return 0;
}
EOF

cat > fib-bench/fib.rs << 'EOF'
fn fib(n: i64) -> i64 {
    if n < 2 {
        return n;
    }
    fib(n - 1) + fib(n - 2)
}

fn main() {
    println!("{}", fib(35));
}
EOF

cat > fib-bench/fib.py << 'EOF'
def fib(n):
    if n < 2:
        return n
    return fib(n - 1) + fib(n - 2)

print(fib(35))
EOF

cat > fib-bench/Fib.java << 'EOF'
public class Fib {
    static long fib(long n) {
        if (n < 2) return n;
        return fib(n - 1) + fib(n - 2);
    }

    public static void main(String[] args) {
        System.out.println(fib(35));
    }
}
EOF

# ================= SUM OF 10M =================
mkdir -p sum-bench/src
cat > sum-bench/src/main.rub << 'EOF'
fn main() {
    let mut total: i64 = 0
    let mut i: i64 = 0

    while i < 10000000 {
        total = total + i
        i = i + 1
    }

    print(total)
}
EOF

cat > sum-bench/sum.c << 'EOF'
#include <stdio.h>

int main() {
    long total = 0;
    for (long i = 0; i < 10000000; i++) {
        total += i;
    }
    printf("%ld\n", total);
    return 0;
}
EOF

cat > sum-bench/sum.rs << 'EOF'
fn main() {
    let mut total: i64 = 0;
    for i in 0..10_000_000i64 {
        total += i;
    }
    println!("{}", total);
}
EOF

cat > sum-bench/sum.py << 'EOF'
total = 0
for i in range(10_000_000):
    total += i

print(total)
EOF

cat > sum-bench/Sum.java << 'EOF'
public class Sum {
    public static void main(String[] args) {
        long total = 0;
        for (long i = 0; i < 10_000_000; i++) {
            total += i;
        }
        System.out.println(total);
    }
}
EOF

echo "Created:"
echo "  benchmarks/fib-bench/  → src/main.rub, fib.c, fib.rs, fib.py, Fib.java"
echo "  benchmarks/sum-bench/  → src/main.rub, sum.c, sum.rs, sum.py, Sum.java"
echo ""
echo "===== BUILD ====="
echo "cd fib-bench"
echo "  gcc -O2 fib.c -o fib_c"
echo "  rustc -O fib.rs -o fib_rs"
echo "  javac Fib.java"
echo "  xeon build --release          # builds src/main.rub -> ./build/fib-bench"
echo "  # Python needs no build step"
echo ""
echo "cd ../sum-bench"
echo "  gcc -O2 sum.c -o sum_c"
echo "  rustc -O sum.rs -o sum_rs"
echo "  javac Sum.java"
echo "  xeon build --release          # builds src/main.rub -> ./build/sum-bench"
echo ""
echo "===== TIME (from inside each folder) ====="
echo "hyperfine './fib_c' './fib_rs' './build/fib-bench' 'python3 fib.py' 'java Fib'"
echo "hyperfine './sum_c' './sum_rs' './build/sum-bench' 'python3 sum.py' 'java Sum'"
echo ""
echo "Notes:"
echo "  - 'java Fib' includes JVM startup + JIT warmup in the timing, which isn't"
echo "    fully representative of steady-state Java performance, but it's the"
echo "    fairest simple comparison for a single-shot benchmark like this."
echo "  - If hyperfine isn't installed: sudo apt install hyperfine"
echo "    (or fall back to 'time <command>', run a few times each)."
