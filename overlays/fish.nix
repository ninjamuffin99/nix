final: prev: {
  fish = prev.fish.overrideAttrs (oldAttrs: {
    version = "4.0b1";

    src = prev.fetchFromGitHub {
      owner = "fish-shell";
      repo = "fish-shell";
      rev = "8557c3c48c132a31dffbab6a90326a80f9cae8ec";
      hash = "sha256-O5xZHXNrJMpjTA2mrTqzMtU/55UArwoc2adc0R6pVl0=";
    };
  });
}
