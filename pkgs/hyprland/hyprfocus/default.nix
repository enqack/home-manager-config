{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation rec {
  pname = "hyprfocus";
  version = "0.0.1";

  src = pkgs.fetchFromGitHub {
    owner = "pyt0xic";
    repo = "hyprfocus";
    rev = "main";
    sha256 = "07ag2imfxhxs3pngyfyqsw01325xz7l0fjhl3ncjx8942hv60mj7";
  };

  buildInputs = [ pkgs.hyprland pkgs.meson pkgs.ninja pkgs.pkg-config ];

  buildPhase = ''
    meson build
    ninja -C build
  '';

  installPhase = ''
    mkdir -p $out/lib/hyprland/plugins
    cp build/libhyprfocus.so $out/lib/hyprland/plugins/
  '';

  meta = with pkgs.lib; {
    description = "Hyprfocus Plugin for Hyprland";
    license = licenses.bsd3;
    maintainers = with maintainers; [ pyt0xic ];
    homepage = "https://github.com/pyt0xic/hyprfocus";
  };
}
