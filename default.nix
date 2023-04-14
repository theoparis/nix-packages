let
	pkgs = import <nixpkgs> {};
	llvm = pkgs.callPackage ./llvm.nix {};
in {
	inherit llvm;
}
