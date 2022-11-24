{
  description = "Personal package overlay";
  inputs = {
    zsh-vim-mode = {
      url = "github:softmoth/zsh-vim-mode";
      flake = false;
    };
    zsh-z = {
      url = "github:agkozak/zsh-z";
      flake = false;
    };
  };
  outputs = inputs@{ self, nixpkgs, zsh-vim-mode, zsh-z }: {
    overlay = final: prev: {
      authelia = prev.callPackage ./authelia.nix prev;
      zsh-z = prev.zsh-z.overrideAttrs (attrs: {
        pname = "zsh-z";
        version = "unstable";
        src = zsh-z;
      });
      zsh-vim-mode = prev.callPackage ./zsh-vim-mode.nix inputs prev;
      invoiceninja = prev.callPackage ./invoiceninja.nix prev;
      xerox-generic-driver = prev.callPackage ./xerox.nix prev;
    };
  };
}
