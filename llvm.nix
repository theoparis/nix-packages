{
	pkgs,
	llvmProject,
}:
let
	llvmFull = pkgs.stdenv.mkDerivation rec {
		name = "llvm-full";
		src = llvmProject;

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
			-DLLVM_ENABLE_PROJECTS="mlir;llvm;clang;lld;clang-tools-extra;libclc;lldb;bolt" \
			-DLLVM_ENABLE_PIC=ON \
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
			-DCMAKE_C_COMPILER=${pkgs.clang}/bin/clang \
			-DCMAKE_CXX_COMPILER=${pkgs.clang}/bin/clang++ \
			-DCMAKE_ASM_COMPILER=${pkgs.clang}/bin/clang \
			-DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=${pkgs.lld}/bin/ld.lld" \
			-DCMAKE_INSTALL_PREFIX=${placeholder "out"}
		'';
		buildPhase = ''
		cmake --build build --parallel $NIX_BUILD_CORES
		'';
		installPhase = ''
		cmake --install build
		'';
	};

	clang = pkgs.wrapCC (pkgs.stdenv.mkDerivation {
		name = "clang-full";
		dontUnpack = true;
		installPhase = ''
			mkdir -p $out/bin
			for bin in ${toString (builtins.attrNames (builtins.readDir "${llvmFull}/bin"))}; do
				cat > $out/bin/$bin <<EOF
#!${pkgs.stdenv.shell}
exec "${llvmFull}/bin/$bin" "\$@"
EOF
				chmod +x $out/bin/$bin
		done
		'';
		passthru.isClang = true;
	});
in {
 	llvm = llvmFull;
	clang = clang;
}
