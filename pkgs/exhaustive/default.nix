# source: https://github.com/NixOS/nixpkgs/blob/nixos-25.11/pkgs/by-name/ex/exhaustive/package.nix
# issue: https://github.com/nishanths/exhaustive/issues/86
{
  lib,
  pkgs,
}:
pkgs.buildGo124Module rec {
  pname = "exhaustive";
  version = "0.12.0";

  src = pkgs.fetchFromGitHub {
    owner = "nishanths";
    repo = "exhaustive";
    rev = "v${version}";
    hash = "sha256-OLIdtKzCqnBkzdUSIl+UlENeMl3zrBE47pLWPg+6qXw=";
  };

  vendorHash = "sha256-DyN2z6+lA/163k6TTQZ+ypm9s2EV93zvSo/yKQZXvCg=";

  ldflags = [
    "-s"
    "-w"
  ];

  doCheck = false;

  meta = with lib; {
    description = "Check exhaustiveness of switch statements of enum-like constants in Go code";
    mainProgram = "exhaustive";
    homepage = "https://github.com/nishanths/exhaustive";
    license = licenses.bsd2;
    maintainers = with maintainers; [ meain ];
  };
}
