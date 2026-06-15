# Homebrew Cask Distribution

Wane is a macOS GUI app, so Homebrew support should be published as a Cask.

## Tap Repository

Create a separate GitHub repository:

```text
08820048/homebrew-wane
```

Copy this repository's `Casks/wane.rb` file into that tap repository with the
same path:

```text
homebrew-wane/
└── Casks/
    └── wane.rb
```

Homebrew expects custom tap repositories to use the `homebrew-` prefix. Users
install from `08820048/homebrew-wane` by omitting that prefix in the tap name.

## User Install Command

After the tap repository exists:

```sh
brew tap 08820048/wane
brew install --cask wane
```

Users can update with:

```sh
brew update
brew upgrade --cask wane
```

## Release Asset Requirement

The current cask points to:

```text
https://github.com/08820048/Wane/releases/latest/download/Wane.dmg
```

Each GitHub Release must upload a notarized direct-download artifact named:

```text
Wane.dmg
```

The cask currently uses:

```ruby
version :latest
sha256 :no_check
```

That keeps the cask simple while the release pipeline is still being built.
For a stricter public cask, switch to versioned releases and replace
`:no_check` with the release artifact checksum:

```sh
shasum -a 256 Wane.dmg
```

## Validation

In the tap repository:

```sh
brew audit --cask wane
brew install --cask ./Casks/wane.rb
```

For local testing from this source repository:

```sh
brew install --cask ./Casks/wane.rb
```

This only works after a GitHub Release exists with the `Wane.dmg` asset.
