final: prev: {
  jj = prev.rustPlatform.buildRustPackage rec {
    pname = "jj";
    version = "unstable-2025-01-10";

    src = prev.fetchFromGitHub {
      owner = "martinvonz";
      repo = "jj";
      rev = "main";
      hash = "sha256-77oTScsUU1BZMytdrncoWFuOC0XdiYp8ZPSQjFHlHRc="; # Replace with actual hash
    };

    cargoLock = {
      lockFile = src + "/Cargo.lock";
      # This will be empty at first, Nix will tell us what hashes we need
      outputHashes = {};
    };

    nativeBuildInputs = with prev; [
      pkg-config
      cmake
      perl
      rustc
      cargo
      cacert
      git
    ];

    buildInputs = with prev;
      [
        openssl
        zlib
        sqlite
        curl
        pcre2
      ]
      ++ lib.optionals stdenv.isDarwin [
        libiconv
        darwin.apple_sdk.frameworks.Security
      ];

    CARGO_HOME = "$NIX_BUILD_TOP/.cargo";
    SSL_CERT_FILE = "${prev.cacert}/etc/ssl/certs/ca-bundle.crt";
    GIT_CONFIG_NOSYSTEM = "1";
    HOME = "$NIX_BUILD_TOP";

    buildFeatures = ["vendored-openssl"];

    doCheck = false;

    meta = with prev.lib; {
      description = "A Git-compatible DVCS that is both simple and powerful";
      homepage = "https://github.com/martinvonz/jj";
      license = licenses.asl20;
      maintainers = [];
      platforms = platforms.all;
    };
  };
}
