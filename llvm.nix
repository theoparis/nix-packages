{
	nixpkgs ? <nixpkgs>,
	pkgs ? import nixpkgs { },
	llvmVersion ? "d30b4e515a0cf509e56b88ddd7ddb87b9e601508",
}:
let
	llvmSrc = builtins.fetchTarball "https://github.com/llvm/llvm-project/archive/${llvmVersion}.tar.gz";

	llvmFull = pkgs.stdenv.mkDerivation rec {
		name = "llvm-full";
		src = llvmSrc;

		nativeBuildInputs = [
			pkgs.cmakeMinimal
			pkgs.python3
			pkgs.perl
			pkgs.vulkan-headers
			pkgs.vulkan-loader
			pkgs.vulkan-validation-layers
			pkgs.vulkan-tools
		];
		
		configurePhase = ''
		cmake -S llvm -B build \
			-DCMAKE_BUILD_TYPE=MinSizeRel \
			-DLLVM_ENABLE_PROJECTS="mlir;llvm;clang;lld;clang-tools-extra;libclc;lldb;openmp;bolt" \
			-DLLVM_ENABLE_ASSERTIONS=ON \
			-DMLIR_ENABLE_VULKAN_RUNNER=ON \
			-DMLIR_ENABLE_SPIRV_CPU_RUNNER=ON \
			-DMLIR_ENABLE_EXECUTION_ENGINE=ON \
			-DLLVM_ENABLE_RTTI=ON \
			-DLLVM_ENABLE_TERMINFO=OFF \
			-DLLVM_ENABLE_ZLIB=OFF \
			-DLLVM_ENABLE_LIBXML2=OFF \
			-DLLVM_ENABLE_LIBEDIT=OFF \
			-DLLVM_ENABLE_LIBPFM=OFF \
			-DLLVM_ENABLE_LIBCXX=OFF \
			-DLLVM_INCLUDE_DOCS=OFF \
			-DLLVM_INCLUDE_TESTS=OFF \
			-DLLVM_INCLUDE_BENCHMARKS=OFF \
			-DLLVM_PARALLEL_LINK_JOBS=1 \
			-DLLDB_ENABLE_LUA=OFF \
			-DLLDB_ENABLE_PYTHON=OFF \
			-DLLDB_ENABLE_LZMA=OFF \
			-DLLDB_ENABLE_LIBEDIT=OFF \
			-DLLDB_ENABLE_LIBXML2=OFF \
			-DLLDB_ENABLE_CURSES=OFF \
			-DLIBCXXABI_USE_LLVM_UNWINDER=ON \
			-DLIBCXXABI_USE_COMPILER_RT=ON \
			-DLIBCXXABI_ENABLE_EXCEPTIONS=ON \
			-DLIBCXXABI_ENABLE_THREADS=ON \
			-DLIBCXXABI_ENABLE_RTTI=ON \
			-DCMAKE_INSTALL_PREFIX=${placeholder "out"}
		'';
		buildPhase = ''
		cmake --build build --parallel $NIX_BUILD_CORES
		'';
		installPhase = ''
		cmake --install build
		'';
	};
in llvmFull
