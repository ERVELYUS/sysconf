{
  pkgs,
  ...
}:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      precmd() { echo }
      typeset -A ZSH_HIGHLIGHT_STYLES
      ZSH_HIGHLIGHT_STYLES[path]='none'
      ZSH_HIGHLIGHT_STYLES[path_prefix]='none'
      bindkey '^ ' autosuggest-accept # Ctrl + Space
    '';
  };

  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    settings = builtins.fromJSON (builtins.readFile ../oh-my-posh/config.json);
  };
}
