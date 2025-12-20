{
  description = "CLOS.org - Static site generator using Emacs Org-mode";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Emacs with extra packages
        emacs-with-packages = pkgs.emacs-nox.pkgs.withPackages (epkgs: [
          epkgs.htmlize
          epkgs.simple-httpd
        ]);

        buildSite = pkgs.writeShellScriptBin "build-site" ''
          ${emacs-with-packages}/bin/emacs -Q --script publish.el
        '';

        serveSite = pkgs.writeShellScriptBin "serve-site" ''
          echo "Starting HTTP server on http://localhost:8080"
          echo "Serving files from ./public"
          echo "Press Ctrl+C to stop"
          ${emacs-with-packages}/bin/emacs -Q --batch \
            --eval "(require 'simple-httpd)" \
            --eval "(setq httpd-root \"./public\")" \
            --eval "(setq httpd-port 8080)" \
            --eval "(httpd-batch-start)"
        '';

        cleanSite = pkgs.writeShellScriptBin "clean-site" ''
          rm -rf public/
        '';

      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            emacs-with-packages
            buildSite
            serveSite
            cleanSite
          ];

          shellHook = ''
            echo "CLOS.org development environment"
            echo ""
            echo "Available commands:"
            echo "  build-site  - Build the static site"
            echo "  serve-site  - Serve the site locally"
            echo "  clean-site  - Clean build artifacts"
          '';
        };
      }
    );
}
