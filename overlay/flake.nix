{
  description = "Personal package overlay";
  inputs = {
    zsh-z = {
      url = "github:agkozak/zsh-z";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, zsh-z }: {
    overlay = final: prev: {
      authelia = prev.callPackage ./authelia.nix prev;
      zsh-z = prev.zsh-z.overrideAttrs (attrs: {
        pname = "zsh-z";
        version = "unstable";
        src = zsh-z;
      });
      invoiceninja = prev.callPackage ./invoiceninja.nix prev;
      xerox-generic-driver = prev.callPackage ./xerox.nix prev;
    };
  };
}
