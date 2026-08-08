{ ... }:
{
  programs.git = {
    enable = true;

    lfs.enable = true;

    # global gitignore (~/.config/git/ignore)
    ignores = [
      ".DS_Store"
      "*.aux"
      "*.log"
      "*.out"
      "*.dvi"
      "*.fdb_latexmk"
      "*.fls"
      "**/auto/*.el"
      "*.bbl"
      "*.blg"
      "\\#*\\#"
      ".\\#*"
      "node_modules"
      "venv"
      ".vscode"
      "**/.claude/settings.local.json"
    ];

    # global gitattributes (~/.config/git/attributes)
    attributes = [
      "* text=auto"
      "*.json diff=json"
      "*.md   diff=markdown"
      "*.png  binary"
      "*.jpg  binary"
      "*.pdf  binary"
    ];

    settings = {
      user = {
        name = "Alex Raskin";
        email = "alexraskin@fastmail.fm";
        signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFZ/ZjjWTINdBcOkNfdsnwMJxBsCpcgNvM4wxcBEXG/a";
      };
      alias = {
        co = "checkout";
        cleanup = "remote update --prune";
        ds = "diff --staged";
      };
      init = {
        defaultBranch = "main";
        templateDir = "~/.git-templates";
      };
      gpg = {
        format = "ssh";
        ssh.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      };
      commit.gpgsign = true;
      pull.rebase = true;
      github.user = "alexraskin";
    };
  };
}
