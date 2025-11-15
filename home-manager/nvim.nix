{ lib, pkgs, ... }:

let
  ts = pkgs.vimPlugins.nvim-treesitter;
  nvim-treesitter = ts.withPlugins (ps: ts.allGrammars ++ (with ps; [
    tree-sitter-nu
  ]));
in

{
  programs.neovim = {
    enable = true;

    withPython3 = true;

    extraLuaConfig = ''
      local path_orig = package.path
      package.path = "${./nvim}/?/init.lua;${./nvim}/?.lua;" .. package.path
      require("config").setup()
      package.path = path_orig

      vim.opt.rtp:prepend("${pkgs.vimPlugins.lazy-nvim}")
      vim.opt.rtp:prepend("${./nvim}")  -- so that the import below finds the lua/plugins dir
      require("lazy").setup({
        { "catppuccin/nvim", name = "catppuccin", dir = "${pkgs.vimPlugins.catppuccin-nvim}" },
        { "nvim-treesitter/nvim-treesitter", name = "nvim-treesitter",  dir = "${nvim-treesitter}", lazy = true },
        { "nvim-telescope/telescope-fzf-native.nvim", name = "telescope-fzf-native.nvim", dir = "${pkgs.vimPlugins.telescope-fzf-native-nvim}", lazy = true },
        { import = "plugins" --[[ searches on rtp in ./lua subdirs --]] },
      })

      vim.cmd.colorscheme "catppuccin"
    '';
  };

  # HACK !?
  xdg.configFile."nvim/parser".source = "${pkgs.symlinkJoin {
      name = "treesitter-parsers";
      paths = nvim-treesitter.dependencies;
    }}/parser";

  programs.git.ignores = [
    "/Session.vim"
  ];

}
