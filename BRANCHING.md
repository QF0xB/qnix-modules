# Branching Strategy

This document outlines the branching strategy for `qnix-modules`.

## Branch Structure

### `main` - Stable Releases
- **Purpose**: Production-ready, stable releases
- **Usage**: Servers and production systems
- **Workflow**: 
  - Only merged from `dev` after testing
  - Tagged with version numbers: `vYEAR.MONTH.DAY.ITERATION` (e.g., `v2025.01.15.1`)
  - Published to FlakeHub
- **Stability**: High - changes are tested and reviewed

### `dev` - Development Branch
- **Purpose**: Bleeding-edge development
- **Usage**: Clients (laptops, desktops) that want latest features
- **Workflow**:
  - Default branch for active development
  - Merged from feature branches
  - Regularly synced to `main` for releases
- **Stability**: Medium - may have breaking changes

### `scaffold` - Empty Template
- **Purpose**: Clean starting point with no modules
- **Usage**: For users who want to start from scratch
- **Workflow**: 
  - Rarely updated (only when structure changes)
  - Contains only the module structure, loaders, and tools
- **Stability**: Static - structure template only

### Feature Branches (Optional)
- **Naming**: `feature/name` or `fix/name`
- **Purpose**: Isolated development for new features or fixes
- **Workflow**:
  - Created from `dev`
  - Merged back to `dev` when complete
  - Deleted after merge

## Workflow Examples

### Adding a New Module

```bash
# Start from dev branch
git checkout dev
git pull origin dev

# Create feature branch (optional, or work directly on dev)
git checkout -b feature/new-module

# Create the module (Automatically runs tools/module-update.py)
./tools/gen-module.sh b new-module desktop

# Verify non-broken
nix eval .#checks

# Commit and push
git add .
git commit -m "module/add: init of new-module"
git push origin feature/new-module

# Merge to dev (or if working directly on dev, just push)
git checkout dev
git merge feature/new-module
git push origin dev
```

### Creating a Release

```bash
# Ensure dev is stable and tested
git checkout dev
git pull origin dev

# Merge dev to main
git checkout main
git merge dev
git push origin main

# Create version tag
VERSION="v$(date +%Y.%m.%d.1)"  # e.g., v2025.01.15.1
git tag -a "$VERSION" -m "Release $VERSION"
git push origin "$VERSION"

# Publish to FlakeHub (if configured)
# The tag will be available on FlakeHub automatically
```

### Updating Scaffold Branch

```bash
# Only when structure/tools change
git checkout scaffold
git merge main  # or cherry-pick specific commits
# Remove all modules, keep only structure
# ... manually clean up modules/ ...
git commit -m "Update scaffold structure"
git push origin scaffold
```

## Version Tagging

Releases are tagged with the format: `vYEAR.MONTH.DAY.ITERATION`

- **YEAR.MONTH.DAY**: Date of release
- **ITERATION**: Increment if multiple releases on same day (1, 2, 3, ...)

Examples:
- `v2025.01.15.1` - First release on January 15, 2025
- `v2025.01.15.2` - Second release on the same day

## Branch Protection (Recommended)

Current protections:
- **main**: Require PR reviews, require status checks

## Summary

```
main (stable) ←─── dev (development) ←─── feature/* (optional)
    ↓                    ↓
  Tags              Active work
FlakeHub            Clients use (for Testing)
```

**Default branch**: `dev` (for active development)  
**Release branch**: `main` (for stable releases)  
**Template branch**: `scaffold` (for clean starts)

