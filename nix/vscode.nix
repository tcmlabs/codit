{ pkgs ? import <nixpkgs> { } }:
pkgs.vscode-with-extensions.override {
  vscodeExtensions = with pkgs.vscode-extensions;
    [ bbenoist.Nix ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "prettier-vscode";
        publisher = "esbenp";
        version = "4.6.0";
        sha256 = "09bw4v1i5jdpyql91vcj66vhzni8rkr6fxrnbvaq5fjlh3g6m2rv";
      }
      {
        name = "vscode-purty";
        publisher = "mvakula";
        version = "0.4.1";
        sha256 = "021r5cg6h229d2gfgd5a06iy0w5fw9563vxpfcs045nn559xpwxr";
      }
      {
        name = "language-purescript";
        publisher = "nwolverson";
        version = "0.2.4";
        sha256 = "16c6ik09wj87r0dg4l0swl2qlqy48jkavpp5i90l166x2mjw2b7w";
      }
      {
        name = "ide-purescript";
        publisher = "nwolverson";
        version = "0.20.15";
        sha256 = "0m2dxhqw1slcw051vdknwpkpadlpnfarhrxn1rfxwqdx0yxadfil";
      }
      {
        name = "nixfmt-vscode";
        publisher = "brettm12345";
        version = "0.0.1";
        sha256 = "07w35c69vk1l6vipnq3qfack36qcszqxn8j3v332bl0w6m02aa7k";
      }
    ];
}
