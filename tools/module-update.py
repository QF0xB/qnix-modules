#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
from pathlib import Path
from typing import Dict, Any, List, Tuple, Optional


DEFAULT_CATEGORIES = ["core", "desktop", "server", "pentesting"]


def is_hidden_or_legacy(name: str) -> bool:
    return name.startswith(".") or name in {"legacy", "_archive", "__pycache__"}


def detect_module(module_dir: Path) -> Dict[str, Any]:
    """
    Detect presence of nixos/home/options submodules in a module directory.
    """
    nixos = (module_dir / "nixos" / "module.nix").is_file()
    home = (module_dir / "home" / "module.nix").is_file()
    options = (module_dir / "options" / "options.nix").is_file()

    return {
        "nixos": nixos,
        "home": home,
        "options": options,
    }


def scan_modules(root: Path, categories: List[str]) -> Dict[str, Dict[str, Any]]:
    """
    Returns { category: { moduleName: {nixos,home}, ... }, ... }
    Note: options/options.nix is assumed to always exist, so not tracked.
    Special case: 'qnix' module is in modules/qnix/ (no category).
    """
    modules_root = root / "modules"
    if not modules_root.is_dir():
        raise SystemExit(f"Error: expected directory {modules_root} to exist.")

    out: Dict[str, Dict[str, Any]] = {}
    
    # Note: qnix module is NOT included in module-index.nix
    # It's handled separately in loaders and only appears in documentation

    # Scan category directories
    for cat in categories:
        cat_dir = modules_root / cat
        if not cat_dir.is_dir():
            # Allow missing categories; keep output deterministic (empty attrset)
            out[cat] = {}
            continue

        cat_out: Dict[str, Any] = {}
        for entry in sorted(cat_dir.iterdir(), key=lambda p: p.name):
            if not entry.is_dir():
                continue
            name = entry.name
            if is_hidden_or_legacy(name):
                continue

            info = detect_module(entry)

            # Include modules that have nixos, home, or just options (like qnix)
            # Options should always exist, but include even if only options exist
            if info["nixos"] or info["home"] or info["options"]:
                # Only store nixos and home flags - category/name are keys, options always exists
                cat_out[name] = {
                    "nixos": info["nixos"],
                    "home": info["home"],
                }

        out[cat] = cat_out

    return out


def extract_option_info(options_file: Path) -> List[Dict[str, Any]]:
    """
    Extract option information from a Nix options file using regex.
    Returns list of option info dicts.
    Handles both flat and nested options, including submodules.
    """
    if not options_file.is_file():
        return []
    
    try:
        content = options_file.read_text(encoding="utf-8")
    except Exception:
        return []
    
    options = []
    
    def extract_from_body(option_body: str) -> Dict[str, Any]:
        """Helper to extract type, default, and description from option body."""
        # Extract type (handles types.bool, types.str, types.nullOr, types.listOf, etc.)
        type_match = re.search(r'type\s*=\s*(?:lib\.)?types\.(\w+)', option_body)
        if not type_match:
            # Try nullOr pattern: type = lib.types.nullOr lib.types.str
            nullor_match = re.search(r'type\s*=\s*(?:lib\.)?types\.nullOr\s+(?:lib\.)?types\.(\w+)', option_body)
            if nullor_match:
                opt_type = f"nullOr {nullor_match.group(1)}"
            else:
                # Try listOf pattern
                listof_match = re.search(r'type\s*=\s*(?:lib\.)?types\.listOf\s+(?:lib\.)?types\.(\w+)', option_body)
                if listof_match:
                    opt_type = f"listOf {listof_match.group(1)}"
                else:
                    # Try attrsOf pattern
                    attrs_match = re.search(r'type\s*=\s*(?:lib\.)?types\.attrsOf\s*\([^)]*types\.(\w+)', option_body)
                    if attrs_match:
                        opt_type = f"attrsOf {attrs_match.group(1)}"
                    else:
                        opt_type = None
        else:
            opt_type = type_match.group(1)
        
        # Extract default (handles various formats)
        default_match = re.search(r'default\s*=\s*([^;]+);', option_body, re.DOTALL)
        default_val = default_match.group(1).strip() if default_match else None
        if default_val:
            # Clean up default value
            default_val = default_val.replace('\n', ' ').strip()
            default_val = re.sub(r'\s+', ' ', default_val)
            # Handle common Nix values
            if default_val in ['true', 'false', 'null']:
                pass  # Keep as is
            elif default_val.startswith('[') and default_val.endswith(']'):
                # List - truncate if too long
                if len(default_val) > 50:
                    default_val = default_val[:47] + "...]"
            elif len(default_val) > 50:
                default_val = default_val[:47] + "..."
        
        # Extract description (handles both single and double quotes, multiline)
        desc_match = re.search(r'description\s*=\s*["\']([^"\']+)["\']', option_body, re.DOTALL)
        if not desc_match:
            # Try multiline with escaped quotes
            desc_match = re.search(r'description\s*=\s*["\']((?:[^"\'\\]|\\.)+)["\']', option_body, re.DOTALL)
        description = desc_match.group(1).strip() if desc_match else None
        if description:
            # Unescape common sequences
            description = description.replace('\\"', '"').replace("\\'", "'")
        
        return {
            "type": opt_type or "unknown",
            "default": default_val or "none",
            "description": description or "No description",
        }
    
    # Pattern to match mkOption calls (handles lib.mkOption, mkOption)
    # Matches: optionName = (lib.)?mkOption { ... }
    option_pattern = r'(\w+)\s*=\s*(?:lib\.)?mkOption\s*\{([^}]+)\}'
    
    # Pattern for mkEnableOption with string: optionName = mkEnableOption "description" // { default = ...; }
    enable_option_pattern = r'(\w+)\s*=\s*(?:lib\.)?mkEnableOption\s*["\']([^"\']+)["\']'
    
    # Find all mkEnableOption calls with string descriptions
    for match in re.finditer(enable_option_pattern, content, re.MULTILINE):
        option_name = match.group(1)
        description = match.group(2).strip()
        
        # Look for default value after the mkEnableOption call
        # Pattern: // { default = ...; }
        after_match = content[match.end():match.end()+300]  # Check next 300 chars
        default_match = re.search(r'//\s*\{\s*default\s*=\s*([^;]+);', after_match, re.MULTILINE)
        default_val = default_match.group(1).strip() if default_match else "false"
        
        options.append({
            "name": option_name,
            "type": "bool",
            "default": default_val,
            "description": description,
        })
    
    # Find all mkOption calls at top level
    for match in re.finditer(option_pattern, content, re.MULTILINE | re.DOTALL):
        option_name = match.group(1)
        option_body = match.group(2)
        
        # Skip if we already found this as an enable option
        if any(opt["name"] == option_name for opt in options):
            continue
        
        info = extract_from_body(option_body)
        options.append({
            "name": option_name,
            **info
        })
    
    # Handle nested options in submodules
    # Pattern: sectionName = { optionName = mkOption { ... }; }
    # This handles cases like: root = { enable = ...; password = ...; }
    nested_section_pattern = r'(\w+)\s*=\s*\{'
    pos = 0
    while True:
        match = re.search(nested_section_pattern, content[pos:], re.MULTILINE)
        if not match:
            break
        
        section_start = pos + match.start()
        section_name = match.group(1)
        
        # Find the matching closing brace for this section
        brace_count = 0
        section_end = section_start + match.end()
        for i, char in enumerate(content[section_start + match.end():], start=section_start + match.end()):
            if char == '{':
                brace_count += 1
            elif char == '}':
                if brace_count == 0:
                    section_end = i + 1
                    break
                brace_count -= 1
        
        section_body = content[section_start + match.end():section_end - 1]
        
        # Find mkOption/mkEnableOption calls within this section
        for nested_match in re.finditer(option_pattern, section_body, re.MULTILINE | re.DOTALL):
            nested_option_name = nested_match.group(1)
            nested_option_body = nested_match.group(2)
            full_name = f"{section_name}.{nested_option_name}"
            
            # Skip if already found
            if any(opt["name"] == full_name for opt in options):
                continue
            
            info = extract_from_body(nested_option_body)
            options.append({
                "name": full_name,
                **info
            })
        
        # Also check for mkEnableOption in nested sections
        for nested_match in re.finditer(enable_option_pattern, section_body, re.MULTILINE):
            nested_option_name = nested_match.group(1)
            description = nested_match.group(2).strip()
            full_name = f"{section_name}.{nested_option_name}"
            
            # Skip if already found
            if any(opt["name"] == full_name for opt in options):
                continue
            
            # Look for default
            after_match = section_body[nested_match.end():nested_match.end()+300]
            default_match = re.search(r'//\s*\{\s*default\s*=\s*([^;]+);', after_match, re.MULTILINE)
            default_val = default_match.group(1).strip() if default_match else "false"
            
            options.append({
                "name": full_name,
                "type": "bool",
                "default": default_val,
                "description": description,
            })
        
        pos = section_end
    
    # Handle deeply nested options (like openssh.authorizedKeys.keys)
    # Pattern: section.subsection.option = mkOption { ... }
    deep_nested_pattern = r'(\w+)\.(\w+)\.(\w+)\s*=\s*(?:lib\.)?mkOption\s*\{([^}]+)\}'
    for match in re.finditer(deep_nested_pattern, content, re.MULTILINE | re.DOTALL):
        section = match.group(1)
        subsection = match.group(2)
        option = match.group(3)
        option_body = match.group(4)
        full_name = f"{section}.{subsection}.{option}"
        
        # Skip if already found
        if any(opt["name"] == full_name for opt in options):
            continue
        
        info = extract_from_body(option_body)
        options.append({
            "name": full_name,
            **info
        })
    
    return options


def extract_module_docs(module_dir: Path, category: str, module_name: str) -> Dict[str, Any]:
    """
    Extract documentation from a module directory.
    """
    options_file = module_dir / "options" / "options.nix"
    options = extract_option_info(options_file) if options_file.exists() else []
    
    return {
        "category": category,
        "name": module_name,
        "options": options,
        "has_nixos": (module_dir / "nixos" / "module.nix").is_file(),
        "has_home": (module_dir / "home" / "module.nix").is_file(),
    }


def render_modules_md(index: Dict[str, Dict[str, Any]], root: Path) -> str:
    """
    Render MODULES.md documentation from module index and option files.
    """
    lines: List[str] = []
    lines.append("# QNix Modules Documentation")
    lines.append("")
    lines.append("> **Note**: This file is auto-generated by `tools/module-update.py`. Do not edit manually.")
    lines.append("")
    lines.append("## Overview")
    lines.append("")
    lines.append("This document lists all available modules and their options. Modules are organized by category:")
    lines.append("")
    lines.append("- **core**: Core system modules (always loaded)")
    lines.append("- **desktop**: Desktop-specific modules")
    lines.append("- **server**: Server-specific modules")
    lines.append("- **pentesting**: Pentesting-specific modules")
    lines.append("")
    
    # Collect all module docs (including qnix for documentation)
    modules_root = root / "modules"
    all_module_docs: List[Dict[str, Any]] = []
    
    # Add qnix module docs (not in index, but needed for documentation)
    qnix_dir = modules_root / "qnix"
    if qnix_dir.is_dir():
        docs = extract_module_docs(qnix_dir, "", "qnix")
        all_module_docs.append(docs)
    
    # Add other modules from index
    for cat in sorted(index.keys()):
        cat_modules = index[cat]
        for mod_name in sorted(cat_modules.keys()):
            module_dir = modules_root / cat / mod_name
            if module_dir.is_dir():
                docs = extract_module_docs(module_dir, cat, mod_name)
                all_module_docs.append(docs)
    
    # Render qnix first, then category modules
    # Render qnix module first (not in index, but in docs)
    qnix_doc = next((m for m in all_module_docs if m["name"] == "qnix"), None)
    if qnix_doc:
        lines.append("## Core Configuration")
        lines.append("")
        lines.append("These modules define the core QNix configuration options.")
        lines.append("")
        lines.append("### `qnix`")
        lines.append("")
        
        # Options
        if qnix_doc["options"]:
            lines.append("#### Options")
            lines.append("")
            lines.append("| Option | Type | Default | Description |")
            lines.append("|--------|------|---------|-------------|")
            
            for opt in qnix_doc["options"]:
                opt_name = f"`qnix.{opt['name']}`"
                opt_type = opt.get("type", "unknown")
                opt_default = opt.get("default", "none")
                opt_desc = opt.get("description", "No description")
                
                # Escape pipe characters in description
                opt_desc = opt_desc.replace("|", "\\|")
                
                lines.append(f"| {opt_name} | `{opt_type}` | `{opt_default}` | {opt_desc} |")
            
            lines.append("")
        lines.append("")
    
    # Render category modules
    for cat in sorted(index.keys()):
        cat_modules = index[cat]
        if not cat_modules:
            continue
        
        lines.append(f"## {cat.capitalize()} Modules")
        lines.append("")
        
        for mod_name in sorted(cat_modules.keys()):
            module_doc = next((m for m in all_module_docs if m["category"] == cat and m["name"] == mod_name), None)
            if not module_doc:
                continue
                
            info = cat_modules[mod_name]
            lines.append(f"### `{mod_name}`")
            lines.append("")
            
            # Module type badges
            badges = []
            if info["nixos"]:
                badges.append("NixOS")
            if info["home"]:
                badges.append("Home Manager")
            if badges:
                lines.append(f"**Type**: {', '.join(badges)}")
                lines.append("")
            
            # Options
            if module_doc["options"]:
                lines.append("#### Options")
                lines.append("")
                lines.append("| Option | Type | Default | Description |")
                lines.append("|--------|------|---------|-------------|")
                
                for opt in module_doc["options"]:
                    # qnix module options are at qnix.* (not qnix.qnix.*)
                    if cat == "" and mod_name == "qnix":
                        opt_name = f"`qnix.{opt['name']}`"
                    else:
                        opt_name = f"`qnix.{mod_name}.{opt['name']}`"
                    opt_type = opt.get("type", "unknown")
                    opt_default = opt.get("default", "none")
                    opt_desc = opt.get("description", "No description")
                    
                    # Escape pipe characters in description
                    opt_desc = opt_desc.replace("|", "\\|")
                    
                    lines.append(f"| {opt_name} | `{opt_type}` | `{opt_default}` | {opt_desc} |")
                
                lines.append("")
            else:
                lines.append("#### Options")
                lines.append("")
                # qnix module doesn't have enable option (it's always loaded)
                if not (cat == "" and mod_name == "qnix"):
                    lines.append(f"- `qnix.{mod_name}.enable` (bool, default: `false`) - Enable this module")
                lines.append("")
        
        lines.append("")
    
    lines.append("---")
    lines.append("")
    lines.append("*Generated by `tools/module-update.py`*")
    
    return "\n".join(lines)


def nix_bool(v: bool) -> str:
    return "true" if v else "false"


def nix_escape_str(s: str) -> str:
    # Minimal string escaping for Nix strings in double quotes.
    return s.replace("\\", "\\\\").replace('"', '\\"')


def render_nix(index: Dict[str, Dict[str, Any]]) -> str:
    """
    Renders a Nix attrset that is pleasant to diff.
    """
    lines: List[str] = []
    lines.append("{")
    lines.append("  # Generated by tools/module-update.py; do not edit by hand.")
    lines.append("  # Structure: <category>.<module> = { nixos, home };")
    lines.append("  # Note: options/options.nix is assumed to always exist")
    lines.append("")

    for cat in index.keys():
        lines.append(f"  {cat} = {{")
        cat_modules = index[cat]
        for mod_name in cat_modules.keys():
            info = cat_modules[mod_name]
            lines.append(f'    {mod_name} = {{')
            lines.append(f"      nixos = {nix_bool(bool(info['nixos']))};")
            lines.append(f"      home = {nix_bool(bool(info['home']))};")
            lines.append("    };")
        lines.append("  };")
        lines.append("")

    lines.append("}")
    return "\n".join(lines)


def main() -> None:
    ap = argparse.ArgumentParser(description="Generate module-index.nix and MODULES.md from modules/<category>/<name>/ layout.")
    ap.add_argument("--root", default=".", help="Repo root (default: .)")
    ap.add_argument(
        "--categories",
        default=",".join(DEFAULT_CATEGORIES),
        help=f"Comma-separated categories to scan (default: {','.join(DEFAULT_CATEGORIES)})",
    )
    ap.add_argument("--out", default="module-index.nix", help="Output file for module-index.nix (default: module-index.nix)")
    ap.add_argument("--docs-out", default="MODULES.md", help="Output file for MODULES.md (default: MODULES.md)")
    ap.add_argument("--json", action="store_true", help="Also emit module-index.json next to nix output")
    ap.add_argument("--no-docs", action="store_true", help="Skip generating MODULES.md")
    args = ap.parse_args()

    root = Path(args.root).resolve()
    cats = [c.strip() for c in args.categories.split(",") if c.strip()]
    out_path = (root / args.out).resolve()
    docs_path = (root / args.docs_out).resolve()

    index = scan_modules(root, cats)
    nix_text = render_nix(index)

    out_path.write_text(nix_text + "\n", encoding="utf-8")
    print(f"Wrote {out_path}")

    if not args.no_docs:
        docs_text = render_modules_md(index, root)
        docs_path.write_text(docs_text + "\n", encoding="utf-8")
        print(f"Wrote {docs_path}")

    if args.json:
        json_path = out_path.with_suffix(".json")
        json_path.write_text(json.dumps(index, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        print(f"Wrote {json_path}")


if __name__ == "__main__":
    main()
