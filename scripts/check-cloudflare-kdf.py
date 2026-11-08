#!/usr/bin/env python3
"""Cloudflare Worker PBKDF2 policy preflight.

Detects literal values >100000 and rejects nonliteral iteration expressions
when the Worker uses PBKDF2. This is a *static* guard, not a substitute for
real workerd auth/session positive-path tests. Use --self-test in CI.
"""
from __future__ import annotations
import argparse
import pathlib
import re
import sys
import tempfile

LIMIT = 100_000
SOURCE_SUFFIXES = {".js", ".jsx", ".ts", ".tsx", ".mjs", ".cjs"}
IGNORE_PARTS = {"node_modules", "dist", "build", ".git", ".wrangler", "coverage"}
PBKDF2 = re.compile(r"\bPBKDF2\b", re.I)
ITER = re.compile(r"\biterations\s*:\s*([^,}\n]+)", re.I)
CONSTANT = re.compile(r"\b(?:const|let|var)\s+(\w+)\s*=\s*([\d_]+)\b")
ENV = re.compile(r"\b(?:process\.env|import\.meta\.env|env\.)")
CRYPTO = re.compile(r"\b(?:deriveBits|deriveKey|importKey)\s*\(")


def scan(path: pathlib.Path) -> list[str]:
    code = path.read_text(encoding="utf-8")
    if not PBKDF2.search(code):
        return []
    constants = {k: int(v.replace("_", "")) for k, v in CONSTANT.findall(code)}
    problems = []
    for m in ITER.finditer(code):
        expression = m.group(1).strip()
        if re.fullmatch(r"[\d_]+", expression):
            count = int(expression.replace("_", ""))
        elif expression in constants:
            count = constants[expression]
        else:
            problems.append(f"{path}: PBKDF2 iterations not statically provable: {expression[:65]}")
            continue
        if count > LIMIT:
            problems.append(f"{path}: PBKDF2 iterations {count} exceeds Worker preflight limit {LIMIT}")
    if not ITER.search(code):
        problems.append(f"{path}: PBKDF2 found without auditable literal iterations; review Worker KDF runtime")
    return problems


def inspect(root: pathlib.Path) -> list[str]:
    failures = []
    for path in root.rglob("*"):
        if path.is_file() and path.suffix in SOURCE_SUFFIXES and not (IGNORE_PARTS & set(path.parts)):
            failures.extend(scan(path))
    return failures


def self_test() -> None:
    fixtures = {
        "bad_210k.ts": ('const ITERATIONS = 210000;\ncrypto.subtle.deriveBits({name: "PBKDF2", iterations: ITERATIONS}, key, 256);', True),
        "bad_600k.ts": ('crypto.subtle.deriveBits({name: "PBKDF2", iterations: 600000}, key, 256);', True),
        "bad_env.ts": ('crypto.subtle.deriveBits({name: "PBKDF2", iterations: env.ROUNDS}, key, 256);', True),
        "good_100k.ts": ('crypto.subtle.deriveBits({name: "PBKDF2", iterations: 100000}, key, 256);', False),
        "good_scrypt.ts": ('const kdf = "scrypt";', False),
    }
    with tempfile.TemporaryDirectory() as tmp:
        for name, (source, must_fail) in fixtures.items():
            path = pathlib.Path(tmp) / name
            path.write_text(source, encoding="utf-8")
            got = bool(scan(path))
            if got != must_fail:
                raise AssertionError(f"{name}: expected reject={must_fail}, got={got}")
    print("PASS: PBKDF2 210k, 600k, dynamic env rejected; 100k and scrypt accepted")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("root", nargs="?", default=".")
    parser.add_argument("--self-test", action="store_true")
    args = parser.parse_args()
    if args.self_test:
        self_test()
        return 0
    errors = inspect(pathlib.Path(args.root))
    for error in errors:
        print("::error::" + error, file=sys.stderr)
    if errors:
        print(f"FAIL: {len(errors)} Cloudflare KDF policy violation(s)", file=sys.stderr)
        return 1
    print("PASS: no statically detected Worker PBKDF2 limit violations")
    return 0


if __name__ == "__main__":
    sys.exit(main())
