let
	nixpkgsVersion = "016a65fde03180d0c6e817da11b9c7bc8316a0ab";

	pkgs = import (
		(fetchTarball "https://github.com/nixos/nixpkgs/archive/${nixpkgsVersion}.tar.gz")
	) {};
	llvm = pkgs.callPackage ./llvm.nix {};
in {
	inherit llvm;
}
