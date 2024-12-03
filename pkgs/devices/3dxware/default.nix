{ lib, pkgs, stdenv, fetchzip }:

stdenv.mkDerivation {
  pname = "3dxware";
  version = "1.8.0";

  src = fetchzip {
    url = "https://download.3dconnexion.com/drivers/linux/3dxware-linux-v1-8-0.x86_64.tar.gz";
    sha256 = "sha256-qVSOEoJEmOdhrk0PJffp/2ch5hD/v1oj35bm3XDfnRk=";
    stripRoot = false;
  };

  buildInputs = [ pkgs.motif pkgs.glibc ];

  installPhase = ''
    mkdir -p $out/opt/3dxware
    cp -r $src/. $out/opt/3dxware

    # Create shim lib dir and symlink libXm.so.3 -> libXm.so.4
    mkdir -p $out/opt/3dxware/lib
    ln -s ${pkgs.motif}/lib/libXm.so.4 $out/opt/3dxware/lib/libXm.so.3
  '';

  postInstall = ''
    # Patch binary to use the fake lib path first
    patchelf --set-interpreter ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 $out/opt/3dxware/etc/3DxWare/daemon/3dxsrv
    patchelf --set-rpath $out/opt/3dxware/lib:${pkgs.motif}/lib:${pkgs.glibc}/lib $out/opt/3dxware/etc/3DxWare/daemon/3dxsrv
  '';
}
