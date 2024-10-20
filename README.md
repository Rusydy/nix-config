<!-- markdownlint-disable MD029 -->
# NIX Configuration

This is my Nix configuration. It is a work in progress. It aims to be a complete configuration for my personal use both on my Macbook and on my Linux servers.

> The CentOS configuration is not yet complete. Expect some errors.

## Installation

### MacOS

1. Install Nix

  ```sh
  sh <(curl -L https://nixos.org/nix/install)
  ```
  
2. Initialize Flakes

  ```sh
  mkdir ~/nix && cd ~/nix
  nix flake init -t nix-darwin --experimental-features "nix-command flakes"
  ```

### CentOS

1. Install Nix

  ```sh
  sh <(curl -L https://nixos.org/nix/install) --daemon
  . ~/.nix-profile/etc/profile.d/nix.sh
  ```

2. Initialize Flakes

  ```sh
  mkdir ~/nix && cd ~/nix
  nix flake init -t nixos --experimental-features "nix-command flakes"
  ```

## Rebuiding the configuration

for Macbook:

```sh
darwin-rebuild switch --flake ~/nix#MacOS
```

for Linux (CentOS):

```sh
nix develop --flake ~/nix#CentOS
```
