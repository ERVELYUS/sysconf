# dotfiles/plymouth/mkLogo.nix
{
  pkgs,
  colors,
  pointsize ? 24,
}:
pkgs.runCommand "nixos-logo"
  {
    nativeBuildInputs = [ pkgs.imagemagick ];
  }
  ''
    font=$(find ${pkgs.nerd-fonts.jetbrains-mono} -iname '*regular*.ttf' | head -1)
    convert -background none -fill "#${colors.base0D}" \
      -font "$font" -pointsize ${toString pointsize} \
      +antialias -kerning -1 -interline-spacing -2 \
      label:@${./logo.txt} \
      -channel A -threshold 50% +channel \
      png:$out
  ''
