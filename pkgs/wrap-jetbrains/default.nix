{ pkgs }:

pkg:
let
  jcefLibs = pkgs.lib.makeLibraryPath (with pkgs; [
    stdenv.cc.cc zlib glib nss nspr dbus atk at-spi2-core cups libdrm mesa libgbm alsa-lib expat
    libX11 libXcomposite libXdamage libXext libXfixes libXrandr libXrender libxcb libxkbcommon
    pango cairo gdk-pixbuf gtk3
  ]);
in
pkgs.symlinkJoin {
  name = "${pkg.name}-jcef-wrapped";
  paths = [ pkg ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    for bin in $out/bin/*; do
      if [ -f "$bin" ]; then
        wrapProgram "$bin" --prefix LD_LIBRARY_PATH : "${jcefLibs}"
      fi
    done
  '';
}

