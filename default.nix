{
  stdenv,
  lib,
  callPackage,
  meson,
  ninja,
  wayland,
  libGL,
  wayland-protocols,
  libinput,
  libxkbcommon,
  pixman,
  xcbutilwm,
  libcap,
  xcbutilimage,
  xcbutilerrors,
  mesa,
  libpng,
  ffmpeg_4,
  xorg,
  pkg-config,
}:

let
  libxcb-errors = callPackage ./libxcb-errors/libxcb-errors.nix { };
in

stdenv.mkDerivation rec {
  name = "wlroots";
  pname = "wlroots";
  version = "0.10.0";

  src = builtins.filterSource (path: type: baseNameOf path != "build") ./.;

  # $out for the library and $examples for the example programs (in examples):
  outputs = [
    "out"
    "examples"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    wayland
    libGL
    wayland-protocols
    libinput
    libxkbcommon
    pixman
    xcbutilwm
    libcap
    xcbutilimage
    xcbutilerrors
    mesa
    libpng
    ffmpeg_4
    libxcb-errors
    xorg.libX11.dev
    xorg.libxcb.dev
    xorg.xinput
  ];

  mesonFlags = [
    "-Dlibcap=enabled"
    "-Dlogind=enabled"
    "-Dxwayland=enabled"
    "-Dx11-backend=enabled"
    "-Dxcb-icccm=disabled"
    "-Dxcb-errors=enabled"
  ];

  LDFLAGS = [
    "-lX11-xcb"
    "-lxcb-xinput"
  ];

  postInstall = ''
    # Copy the library to $examples
    mkdir -p $examples/lib
    cp -Pr libwlroots* $examples/lib/
  '';

  postFixup = ''
    # Install ALL example programs to $examples:
    # screencopy dmabuf-capture input-inhibitor layer-shell idle-inhibit idle
    # screenshot output-layout multi-pointer rotation tablet touch pointer
    # simple
    mkdir -p $examples/bin
    cd ./examples
    for binary in $(find . -executable -type f -printf '%P\n' | grep -vE '\.so'); do
      cp "$binary" "$examples/bin/wlroots-$binary"
    done
  '';

  meta = with lib; {
    description = "A modular Wayland compositor library";
    inherit (src.meta) homepage;
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ primeos ];
  };
}
