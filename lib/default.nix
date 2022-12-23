{ lib, ... }:

{
  _module.args.helper = {
    mergeAttrsets = builtins.foldl' lib.recursiveUpdate { };
  };
}
