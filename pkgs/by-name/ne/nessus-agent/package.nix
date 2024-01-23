{ lib, buildFHSEnv, writeShellScriptBin, fetchurl, dpkg }:

let
  version = "10.5.1";

  src = fetchurl {
    url = "https://www.tenable.com/downloads/api/v1/public/pages/nessus-agents/downloads/21859/download?i_agree_to_tenable_license_agreement=true";
    sha256 = "sha256-aQ3eFKQzxZZCUxwvzjY+/4sIJojbXzZWz7tsa06mTyA=";
  };

  nessus-agent-install = writeShellScriptBin "nessus-agent-install" ''
    set -euo pipefail
    if [ -d /opt/nessus_agent ]; then
      echo "Nessus Agent already installed to /opt/nessus_agent"
      exit 0
    fi
    ${dpkg}/bin/dpkg-deb --fsys-tarfile '${src}' | tar x -C / ./opt/nessus_agent
    echo "Nessus Agent installed to /opt/nessus_agent"
  '';
in
buildFHSEnv {
  name = "nessus-agent-shell";

  targetPkgs = pkgs: with pkgs; [ nessus-agent-install nix coreutils tzdata nettools iproute2 procps util-linux ];

  runScript = "bash -l";

  meta = with lib; {
    description = "Tenable Nessus Agent Installer";
    homepage = "https://www.tenable.com/products/nessus/nessus-agents";
    # license = licenses.unfree;
    maintainers = with maintainers; [ matrss ];
    platforms = platforms.linux;
  };
}
