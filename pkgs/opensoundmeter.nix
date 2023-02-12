{
  stdenv,
  lib,
  qmake,
  qtbase,
  qtquickcontrols2,
  wrapQtAppsHook,
  alsaSupport ? stdenv.isLinux,
  alsa-lib ? null,
}:
# TODO: Verify on Darwin. Probably needs work as it installs an App.
stdenv.mkDerivation rec {
  pname = "opensoundmeter";
  version = "1.2.2";

  src = pkgs.fetchFromGitHub {
    owner = "psmokotnin";
    repo = "osm";
    rev = "v${version}";
    hash = "sha256-nci0QzOvCywqstMfWMmM0cmYjVyb1a1tF6Eo43rCbHU=";
  };

  nativeBuildInputs = [qmake wrapQtAppsHook];
  buildInputs =
    [qtbase qtquickcontrols2]
    ++ optionals alsaSupport [alsa-lib];

  postPatch = ''
    # We don't need the app image stuff.
    sed -i '/linuxdeployosm/d' OpenSoundMeter.pro

    # We want our prefix to be used.
    sed -i "s%target.path = .*$%target.path = $out/bin%" OpenSoundMeter.pro
  '';
}
