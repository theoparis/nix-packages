let
	pkgs = import <nixpkgs> {};
	llvm = pkgs.callPackage ./llvm.nix {};
	polygeist = pkgs.callPackage ./polygeist.nix {
		inherit llvm;
	};
in {
	inherit llvm;
	inherit polygeist;
}
