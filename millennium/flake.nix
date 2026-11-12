{
  description = "Millennium (Steam modding framework), pinned with a corrected typescript-deps hash";

  inputs = {
    # Same revision as the root flake's nixpkgs-unstable lock, so only the
    # hash below differs from the build that failed.
    nixpkgs.url = "github:NixOS/nixpkgs/177d0540942fb205af6993b1d5fa0b57799e09f8";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      millennium = pkgs.millennium.overrideAttrs (
        finalAttrs: prevAttrs: {
          # nixpkgs' hash for the bun-installed node_modules doesn't match what
          # the fetch produces. This is the hash from the failed build log.
          typescript-deps = prevAttrs.typescript-deps.overrideAttrs (_: {
            outputHash = "sha256-ydtSsSPJIv6br141kpZAMrjxVjDBMgKe8KHG0s9pY9Y=";
          });
        }
      );
    in
    {
      packages.${system} = {
        inherit millennium;
        default = millennium;
      };
    };
}
