#! /bin/bash
set -e
pushd ~/.config/nix
alejandra . &>/dev/null
git diff -U0 *.nix
echo "Rebuilding nix"
darwin-rebuild switch --flake . &>darwin-rebuild.log || (
    cat darwin-rebuild.log | grep --color error && false)
gen=$(darwin-rebuild --list-generations | grep current)
git commit -am "$gen"
popd 