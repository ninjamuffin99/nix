final: prev: {
  fish = prev.fish.overrideAttrs (oldAttrs: {
    version = "4.0.0-beta.1";

    src = prev.fetchFromGitHub {
      owner = "fish-shell";
      repo = "fish-shell";
      rev = "8557c3c48c132a31dffbab6a90326a80f9cae8ec";
      hash = "sha256-O5xZHXNrJMpjTA2mrTqzMtU/55UArwoc2adc0R6pVl0=";
    };
    nativeBuildInputs =
      (oldAttrs.nativeBuildInputs or [])
      ++ [
        prev.rustc
        prev.cargo
        prev.cmake
        prev.pkg-config
        prev.cacert
        prev.git
      ];

    buildInputs =
      (oldAttrs.buildInputs or [])
      ++ [
        prev.rustc
        prev.pcre2
        prev.openssl
      ];

    CARGO_HOME = "$NIX_BUILD_TOP/.cargo";
    SSL_CERT_FILE = "${prev.cacert}/etc/ssl/certs/ca-bundle.crt";
    FISH_BUILD_VERSION = "4.0.0-beta.1";
    GIT_CONFIG_NOSYSTEM = "1";
    HOME = "$NIX_BUILD_TOP";

    # Disable building tests
    cmakeFlags = [
      "-DBUILD_DOCS=OFF"
      "-DFISH_BUILD_TESTS=OFF"
    ];

    # Skip running tests
    doCheck = false;

    preConfigure = ''
      # Set up cargo home directory
      mkdir -p $CARGO_HOME

      # Initialize git repo with local config
      git init
      git config --local user.email "fish@example.com"
      git config --local user.name "Fish Builder"
      git config --local init.defaultBranch main
      git add .
      git commit -m "Initial commit"

      # Vendor dependencies to avoid network access
      cargo vendor

      # Configure cargo to use vendored dependencies
      mkdir -p .cargo
      cat >.cargo/config.toml <<EOF
      [source.crates-io]
      replace-with = "vendored-sources"

      [source.vendored-sources]
      directory = "vendor"
      EOF
    '';

    patchPhase = ''
      patchShebangs ./build_tools/
      substituteInPlace share/config.fish \
        --replace-warn "/usr/local" "$out"
    '';
  });
}
