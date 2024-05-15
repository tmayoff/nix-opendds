# Use as a flake
 
[![FlakeHub](https://img.shields.io/endpoint?url=https://flakehub.com/f/tmayoff/nix-opendds/badge)](https://flakehub.com/flake/tmayoff/nix-opendds)
 
Add `OpenDDS` to your `flake.nix`:
 
```nix
{
  inputs.opendds.url = "https://flakehub.com/f/tmayodff/nix-opendds/*.tar.gz";
 
  outputs = { self, opendds }: {
    # Use in your outputs
  };
}
```
