{
  description = "Signal Messenger client for terminal";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system:
      with nixpkgs.legacyPackages.${system}; {
        packages.gurk-rs = rustPlatform.buildRustPackage rec {
          pname = "gurk-rs";
          version = "0.5.2";

          src = lib.cleanSource ./.;

          postPatch = ''
            rm .cargo/config.toml
          '';

          cargoLock = {
            lockFile = ./Cargo.lock;
            outputHashes = {
              "libsignal-protocol-0.1.0" = "sha256-AdN8UHu0khgsog1btE++0J4BmdUC6wMpZzL7HPzhALQ=";
              "libsignal-service-0.1.0" = "sha256-GhkT18SVrW8n5PcQrw0FW3E0MZhVqr08zNzq6I06tI0=";
              "curve25519-dalek-4.1.3" = "sha256-bPh7eEgcZnq9C3wmSnnYv0C4aAP+7pnwk9Io29GrI4A=";
              "presage-0.6.2" = "sha256-0H651YAjzorE/ufluXQADlG3AymarA+MmKCTXOryt1M=";
              "qr2term-0.3.1" = "sha256-BK+f+BFfzA05cMU79YNtvF7XdIXnxG+yRTMBcZhIe4o=";
            };
          };

          nativeBuildInputs = [protobuf pkg-config];

          buildInputs =
            [openssl]
            ++ lib.optionals stdenv.hostPlatform.isDarwin [Cocoa];

          NIX_LDFLAGS = lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64) ["-framework" "AppKit"];

          PROTOC = "${pkgsBuildHost.protobuf}/bin/protoc";

          OPENSSL_NO_VENDOR = true;

          useNextest = true;

          meta = with lib; {
            description = "Signal Messenger client for terminal";
            mainProgram = "gurk";
            homepage = "https://github.com/boxdot/gurk-rs";
            license = licenses.agpl3Only;
            maintainers = with maintainers; [devhell];
          };
        };
        defaultPackage = self.packages.${system}.gurk-rs;
      });
}
