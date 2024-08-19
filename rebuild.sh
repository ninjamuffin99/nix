#! /bin/bash
set -e
pushd ~/.config/nix
alejandra . &>/dev/null
git diff -U0 *.nix
echo "Rebuilding nix"
mkdir -p logs
darwin-rebuild switch --flake . &>logs/darwin-rebuild.log || (
    cat darwin-rebuild.log | grep --color error && false)
gen=$(darwin-rebuild --list-generations | grep current)
git commit -am "$gen"
popd 