{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};

      link = "https://iv.catgirl.cloud/watch?v=dQw4w9WgXcQ";

      package = pkgs.stdenvNoCC.mkDerivation {
        pname = "nixcon-meme";
        version = "unstable-2023-09-09";

        src = ./.;

        nativeBuildInputs = with pkgs; [
          qrencode
          imagemagick
          fira-go
        ];

        buildPhase = let
          fontCommands = "-background transparent -fill black -font '${pkgs.fira-go}/share/fonts/opentype/FiraGO-Medium.otf'";
        in ''
          mkdir -p build cache
          export XDG_CACHE_HOME="cache"
          qrencode ${nixpkgs.lib.escapeShellArg link} -o build/qr.png -s 10 -l Q
          magick \
            -size 1920x1080 xc:white \
            \( img/template.jpg -resize 1920x1080 -geometry +200+0 \) -composite \
            \( ${fontCommands} -pointsize 48 label:'Making memes imperatively' -geometry +800+250 \) -composite \
            \( ${fontCommands} -pointsize 48 label:'Building a flake that \noutputs a meme' -geometry +800+750 \) -composite \
            \( build/qr.png -geometry +1510+530 \) -composite \
            \( ${fontCommands} -pointsize 32 label:'Source code:\nhttps://github.com/999eagle/nixcon-meme' -geometry +1100+940 \) -composite \
            build/out.jpg
        '';

        installPhase = ''
          mkdir -p $out
          cp -r build/out.jpg $out/
        '';
      };
    in {
      devShells.default = pkgs.mkShell {
        inputsFrom = [package];
      };
      packages.default = package;
    });
}
