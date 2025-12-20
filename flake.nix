{
  description = "CLOS.org - Static site generator using Emacs Org-mode";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    heti-src = {
      url = "github:sivan/heti/7d5ceb7";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      pre-commit-hooks,
      heti-src,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Pre-commit hooks configuration
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixfmt-rfc-style.enable = true;
            trailing-whitespace = {
              enable = true;
              name = "trailing-whitespace";
              entry = "${pkgs.python3Packages.pre-commit-hooks}/bin/trailing-whitespace-fixer";
              types = [ "text" ];
            };
            end-of-file-fixer = {
              enable = true;
              name = "end-of-file-fixer";
              entry = "${pkgs.python3Packages.pre-commit-hooks}/bin/end-of-file-fixer";
              types = [ "text" ];
            };
            check-yaml = {
              enable = true;
              name = "check-yaml";
              entry = "${pkgs.python3Packages.pre-commit-hooks}/bin/check-yaml";
              types = [ "yaml" ];
            };
            check-xml = {
              enable = true;
              name = "check-xml";
              entry = "${pkgs.python3Packages.pre-commit-hooks}/bin/check-xml";
              types = [ "xml" ];
            };
          };
        };

        heti = pkgs.buildNpmPackage {
          pname = "heti";
          version = "0.9.6";
          src = heti-src;

          npmDepsHash = "sha256-Zf0m+cbudGN4H9Us+SQSVH8Pgpc1gMtOZsXjGTkOP80=";

          buildPhase = ''
            npm run build
          '';

          installPhase = ''
            mkdir -p $out/css $out/js
            cp -r umd/* $out/css/
            cp -r _site/heti-addon.js $out/js/
          '';
        };

        # Emacs with extra packages
        emacs-with-packages = pkgs.emacs-nox.pkgs.withPackages (epkgs: [
          epkgs.htmlize
          epkgs.simple-httpd
        ]);

        # Shared build script used by both the derivation and dev shell
        buildScript = ''
          # Create static directories if they don't exist
          mkdir -p content/static/css content/static/js

          # Copy heti files to static directories
          cp ${heti}/css/heti.min.css content/static/css/
          cp ${heti}/js/heti-addon.js content/static/js/
          chmod u+w content/static/css/heti.min.css content/static/js/heti-addon.js

          # Build the site
          ${emacs-with-packages}/bin/emacs -Q --script publish.el
        '';

        # Main site package
        site = pkgs.stdenv.mkDerivation {
          name = "CLOS.org";
          src = ./.;

          buildInputs = [ emacs-with-packages ];

          buildPhase = ''
            export HOME=$TMPDIR
            ${buildScript}
          '';

          installPhase = ''
            mkdir -p $out
            cp -r public/* $out/
          '';
        };

        buildSite = pkgs.writeShellScriptBin "build-site" ''
          set -euo pipefail

          echo "Copying Heti artifacts..."
          ${buildScript}
          echo "Build complete!"
        '';

        serveSite = pkgs.writeShellScriptBin "serve-site" ''
          set -euo pipefail

          build-site
          echo ""
          echo "Starting HTTP server on http://localhost:8080"
          echo "Serving files from ./public"
          echo "Press Ctrl+C to stop"
          echo ""
          ${pkgs.python310}/bin/python -m http.server 8080 --directory public/ --bind 0.0.0.0
        '';

        cleanSite = pkgs.writeShellScriptBin "clean-site" ''
          set -euo pipefail

          echo "Cleaning build artifacts..."
          rm -rf public/
          echo "Clean complete!"
        '';
      in
      {
        packages = {
          default = site;
          site = site;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            emacs-with-packages
            buildSite
            serveSite
            cleanSite
            pkgs.nixfmt-rfc-style
            pkgs.nodePackages.prettier
          ];

          shellHook = ''
            ${pre-commit-check.shellHook}

            echo "CLOS.org development environment"
            echo ""
            echo "Available commands:"
            echo "  build-site  - Build the static site"
            echo "  serve-site  - Serve the site locally"
            echo "  clean-site  - Clean build artifacts"
            echo ""
            echo "Pre-commit hooks are installed and will run automatically."
          '';
        };

        checks = {
          inherit pre-commit-check;
        };
      }
    );
}
