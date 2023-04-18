{
	description = "LLVM 17 with MLIR";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/44a76628fa05bd46aadba4a4f8e5311f77d1e133";
		llvmProject = {
			url = "github:llvm/llvm-project/7e1b62bd9ca8ab34444c3307e19abecdd482210f";
			flake = false;
		};
	};

	outputs = { self, nixpkgs, llvmProject }:
	let
		system = "x86_64-linux";
		pkgs = nixpkgs.legacyPackages.${system};
		llvm = pkgs.callPackage ./llvm.nix {
			inherit llvmProject;
		};
	in {
		packages.${system} = {
			llvm = llvm.llvm;
			clang = llvm.clang;
			default = self.packages.${system}.clang;
		};
	};
}
