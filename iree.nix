{
	pkgs,
	llvm,
}:
pkgs.stdenv.mkDerivation rec {
	name = "iree";
	version = "e19fc8ee473001780e5713ce22e3e7d973026087";
	src = pkgs.fetchgit {
		url = "https://github.com/openxla/iree.git";
		rev = version;
		sha256 = "fbxkml+PQ6ETdOkptgVO/ilVkppfjOWy7QpLb4t/fk8=";
	};

	nativeBuildInputs = [
		pkgs.cmake
		pkgs.python3
	];

	buildInputs = [
		llvm.llvm
		pkgs.python3
	];

	cmakeFlags = [
		"-DLLVM_DIR=${llvm.llvm}/lib/cmake/llvm"
		"-DMLIR_DIR=${llvm.llvm}/lib/cmake/mlir"
		"-DCMAKE_BUILD_TYPE=MinSizeRel"
		"-DCMAKE_C_COMPILER=${llvm.clang}/bin/clang"
		"-DCMAKE_CXX_COMPILER=${llvm.clang}/bin/clang++"
	];
}
