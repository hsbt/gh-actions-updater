# GitHub Actions Updater

A GitHub CLI extension to update GitHub Actions in your workflow files from hash-based versions to the latest releases, or migrate tag-based versions to hash-based versions.

## Installation

Install this extension using the GitHub CLI:

```bash
gh extension install hsbt/gh-actions-updater
```

Or install locally from this directory:

```bash
gh extension install .
```

## Usage

Update all workflow files in `.github/workflows/`:

```bash
gh actions-updater
```

Convert tag-based versions to hash-based versions:

```bash
gh actions-updater --migrate
```

### Options

- `-f, --file FILE`: Specify workflow file(s) to update (can be used multiple times)
- `-a, --action ACTION`: Target specific action(s) to update (can be used multiple times)
- `-m, --migrate`: Convert tag-based versions to hash-based versions
- `-n, --dry-run`: Show what would be done without making changes
- `-v, --verbose`: Show more detailed output
- `-h, --help`: Show help message

### Examples

Update specific workflow file:
```bash
gh actions-updater -f .github/workflows/ci.yml
```

Update specific action only:
```bash
gh actions-updater -a actions/checkout
```

Convert tag-based versions to hash-based versions:
```bash
gh actions-updater --migrate
```

Convert specific action from tag to hash:
```bash
gh actions-updater --migrate -a ruby/setup-ruby
```

Dry run to see what would be updated:
```bash
gh actions-updater --dry-run
```

Dry run migration to see what would be converted:
```bash
gh actions-updater --migrate --dry-run
```

Update with verbose output:
```bash
gh actions-updater --verbose
```

## Migration Examples

The `--migrate` option converts tag-based versions to hash-based versions for improved security and reproducibility.

### Before Migration
```yaml
uses: actions/checkout@v4
uses: ruby/setup-ruby@v1
uses: actions/setup-node@v3.8.1
```

### After Migration
```yaml
uses: actions/checkout@abc123def456789... # v4.1.0
uses: ruby/setup-ruby@def456abc123789... # v1.2.3
uses: actions/setup-node@789abc123def456... # v3.8.1
```

Note: For major version tags like `v1`, the tool automatically finds the latest patch version in that series (e.g., `v1.2.3` if that's the latest `v1.x.y` release).

## Features

- **Update hash-based versions**: Automatically detects GitHub Actions using hash-based versions (SHA commits) and updates them to the latest release
- **Migrate tag to hash**: Convert tag-based versions (like `v1`, `v1.2.3`) to hash-based versions with comments
- **Smart major version handling**: For major version tags like `v1`, automatically finds the latest patch version in that series (e.g., `v1.2.3`)
- **Preserves comments**: Updates workflow files while preserving existing comments
- **Selective targeting**: Can target specific workflow files or actions
- **Dry-run mode**: Preview changes before applying them
- **Detailed output**: Provides progress information and verbose logging

## Authentication

The extension uses GitHub CLI's built-in authentication. Make sure you're authenticated with the GitHub CLI:

```bash
gh auth login
```

The tool will automatically use your GitHub CLI credentials for API access.

## Requirements

- Ruby 2.7 or later
- GitHub CLI (`gh`)
- Internet connection to fetch latest action versions
