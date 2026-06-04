#!/usr/bin/env python3
"""
check-localizations.py — localized-string hygiene for ThePandaApp.

A lightweight take on the reference app's "Loki" CLI (which uses swift-syntax). Our `localize("…")`
keys are always string literals, so a regex scan is reliable and needs no build step.

It reports three classes of problem:

  1. MISSING      — a key referenced in Swift via `localize("…")` / `"…".localized()` that is not
                    defined in any `.strings` table (the app would show the raw key). Treated as an
                    ERROR by default.
  2. ORPHAN       — a key defined in a `.strings` table that nothing references. Dead copy to prune.
  3. UNTRANSLATED — a key present in the base locale (en) of a table but missing from another
                    locale of the same table (e.g. defined in en but not fr). Reported per locale.

Brand awareness: for each brand the available keys are `Shared` ∪ `<Brand>`; a key that exists for
some brands but not another is reported as a per-brand gap.

Usage:
    scripts/check-localizations.py                 # scan from repo root
    scripts/check-localizations.py --strict        # any finding -> non-zero exit (good for CI)
    scripts/check-localizations.py --base fr        # treat fr as the base locale for translations

Exit code: non-zero if MISSING keys are found (or, with --strict, if any finding at all).
"""

from __future__ import annotations
import argparse
import os
import re
import sys
from collections import defaultdict

# "<key>" = "<value>";   (key may contain escaped chars)
KEY_RE = re.compile(r'^\s*"((?:[^"\\]|\\.)*)"\s*=', re.MULTILINE)
# localize("key")  or  "key".localized()
REF_RE = re.compile(r'localize\(\s*"((?:[^"\\]|\\.)*)"|"((?:[^"\\]|\\.)*)"\s*\.localized\(')

EXCLUDED_DIR_PARTS = {".build", "build", "DerivedData", "Pods", "__Snapshots__", ".git"}


def strip_comments(src: str) -> str:
    """Remove // and /* */ comments while preserving string literals — so a `localize("…")` shown
    in a doc comment, or a `//` inside a "https://…" string, doesn't skew the scan."""
    out: list[str] = []
    i, n = 0, len(src)
    in_str = False
    while i < n:
        c = src[i]
        nxt = src[i + 1] if i + 1 < n else ""
        if in_str:
            out.append(c)
            if c == "\\":               # keep escaped char as-is
                if nxt:
                    out.append(nxt)
                i += 2
                continue
            if c == '"':
                in_str = False
            i += 1
        elif c == '"':
            in_str = True
            out.append(c)
            i += 1
        elif c == "/" and nxt == "/":
            while i < n and src[i] != "\n":
                i += 1
        elif c == "/" and nxt == "*":
            i += 2
            while i < n and not (src[i] == "*" and i + 1 < n and src[i + 1] == "/"):
                i += 1
            i += 2
        else:
            out.append(c)
            i += 1
    return "".join(out)


def find_files(root: str, suffix: str) -> list[str]:
    out: list[str] = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in EXCLUDED_DIR_PARTS]
        for name in filenames:
            if name.endswith(suffix):
                out.append(os.path.join(dirpath, name))
    return out


def parse_keys(path: str) -> set[str]:
    with open(path, encoding="utf-8") as f:
        return set(KEY_RE.findall(strip_comments(f.read())))


def parse_refs(path: str) -> set[str]:
    with open(path, encoding="utf-8") as f:
        return {a or b for a, b in REF_RE.findall(strip_comments(f.read()))}


def locale_of(strings_path: str) -> str:
    # …/<locale>.lproj/<Table>.strings
    for part in strings_path.split(os.sep):
        if part.endswith(".lproj"):
            return part[: -len(".lproj")]
    return "unknown"


def scope_of(strings_path: str, config_root: str) -> str:
    # First path component under the config root, e.g. "Shared" or "ThePandaApp".
    rel = os.path.relpath(strings_path, config_root)
    return rel.split(os.sep)[0]


def main() -> int:
    ap = argparse.ArgumentParser(description="Check localized-string hygiene.")
    ap.add_argument("--source-root", default=".", help="Root to scan for .swift references.")
    ap.add_argument("--config-root", default="Configuration", help="Root holding the .strings tables.")
    ap.add_argument("--base", default="en", help="Base locale to compare translations against.")
    ap.add_argument("--strict", action="store_true", help="Any finding causes a non-zero exit.")
    args = ap.parse_args()

    # --- Gather strings: keys per (scope, locale) and which file defines each base key. ---
    keys_by_scope_locale: dict[tuple[str, str], set[str]] = defaultdict(set)
    file_of_base_key: dict[str, str] = {}
    locales_by_scope: dict[str, set[str]] = defaultdict(set)

    for path in find_files(args.config_root, ".strings"):
        scope, locale = scope_of(path, args.config_root), locale_of(path)
        keys = parse_keys(path)
        keys_by_scope_locale[(scope, locale)] |= keys
        locales_by_scope[scope].add(locale)
        if locale == args.base:
            for k in keys:
                file_of_base_key.setdefault(k, os.path.relpath(path))

    scopes = sorted(locales_by_scope.keys())
    brands = [s for s in scopes if s != "Shared"]
    shared_base = keys_by_scope_locale.get(("Shared", args.base), set())
    defined_base_all = {k for (s, loc), ks in keys_by_scope_locale.items() if loc == args.base for k in ks}

    # --- Gather references from Swift. ---
    referenced: set[str] = set()
    for path in find_files(args.source_root, ".swift"):
        referenced |= parse_refs(path)

    # --- 1. MISSING (referenced but undefined anywhere). ---
    missing = sorted(referenced - defined_base_all)

    # Per-brand gaps: defined for some brand but not this one.
    brand_gaps: dict[str, list[str]] = {}
    for brand in brands:
        available = shared_base | keys_by_scope_locale.get((brand, args.base), set())
        gap = sorted((referenced & defined_base_all) - available)
        if gap:
            brand_gaps[brand] = gap

    # --- 2. ORPHAN (defined but never referenced). ---
    orphans = sorted(defined_base_all - referenced)

    # --- 3. UNTRANSLATED (in base locale of a table, missing from another locale). ---
    untranslated: dict[tuple[str, str], list[str]] = {}
    for scope in scopes:
        base_keys = keys_by_scope_locale.get((scope, args.base), set())
        for locale in sorted(locales_by_scope[scope] - {args.base}):
            missing_tr = sorted(base_keys - keys_by_scope_locale.get((scope, locale), set()))
            if missing_tr:
                untranslated[(scope, locale)] = missing_tr

    # --- Report. ---
    print(f"Scanned {len(defined_base_all)} base keys ('{args.base}') across scopes {scopes}; "
          f"{len(referenced)} referenced keys in Swift.\n")

    def section(title: str, items: list[str], hint: str) -> None:
        print(f"{title}: {len(items)}")
        for k in items:
            loc = f"  (defined in {file_of_base_key.get(k, '?')})" if k in file_of_base_key else ""
            print(f"  - {k}{loc}")
        if items:
            print(f"  → {hint}")
        print()

    section("MISSING (referenced in code, not defined)", missing,
            "add these keys to a .strings table.")
    section("ORPHAN (defined, never referenced)", orphans,
            "remove these unused keys.")

    if brand_gaps:
        print("BRAND GAPS (defined for some brands, missing for another):")
        for brand, gap in brand_gaps.items():
            print(f"  [{brand}] missing {len(gap)}: {', '.join(gap)}")
        print()

    other_locales = {loc for s in scopes for loc in locales_by_scope[s]} - {args.base}
    if other_locales:
        total_untr = sum(len(v) for v in untranslated.values())
        print(f"UNTRANSLATED (in '{args.base}', missing in another locale): {total_untr}")
        for (scope, locale), keys in sorted(untranslated.items()):
            print(f"  [{scope} / {locale}] missing {len(keys)}: {', '.join(keys)}")
        print()
    else:
        print(f"UNTRANSLATED: skipped — only the base locale '{args.base}' exists.\n")

    # --- Verdict. ---
    findings = bool(missing) or bool(orphans) or bool(brand_gaps) or bool(untranslated)
    if not findings:
        print("✅ All good — no missing, orphan, or untranslated keys.")
        return 0

    fail = bool(missing) or bool(brand_gaps) or (args.strict and findings)
    print("❌ Failing." if fail else "⚠️  Warnings only (run with --strict to fail on these).")
    return 1 if fail else 0


if __name__ == "__main__":
    sys.exit(main())
