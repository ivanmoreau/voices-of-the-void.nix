# Voices of the void game packaged as a Nix package

This is a Nix package for the game Voices of the void.

## How to install

Download the latest release from the Itch.io and put it in the `/tmp` directory.

Then run the flake as usual:

```bash
nix run github:ivanmoreau/voices-of-the-void.nix
```

## Disclaimer

The game doen't work in macOS. I don't know why. The image is not rendering (everything in 3D space is black).