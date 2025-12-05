{
  nixConfig.bash-prompt-prefix = ''(zig) '';
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";

    zig.url = "github:mitchellh/zig-overlay";
    zls.url = "github:zigtools/zls";
  };

  outputs = inputs: let
    forAllSystems = f:
      inputs.nixpkgs.lib.genAttrs
      (import inputs.systems)
      (system: f inputs.nixpkgs.legacyPackages.${system});
  in {
    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        packages = [
          inputs.zig.packages.${pkgs.stdenv.hostPlatform.system}.master
          inputs.zls.packages.${pkgs.stdenv.hostPlatform.system}.default
          pkgs.python314
        ];
        shellHook = ''
          echo made with love by wrd

          function find-project-root() {
            local path="$PWD"
            while [[ "$path" != "" && ! -e "$path/.git" ]]; do
              path=''${path%/*}
            done

            [[ "$path" != "" ]] && {
              echo "$path"
              return
            }

            >&2 echo "Couldn't find project root, falling back to \$PWD"
            echo "$PWD"
          }

          export $(cat "$(find-project-root)"/.env)

          function download-input() {
            curl --cookie "session=$SESSION_COOKIE" \
              "$([ "$1" != "" ] &&
                echo https://adventofcode.com/"$1/day/$2"/input ||
                date +https://adventofcode.com/%Y/day/%-d/input)" \
              >input
          }
        '';
      };
    });
  };
}
