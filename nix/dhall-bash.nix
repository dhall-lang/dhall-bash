{ mkDerivation, base, bytestring, containers, dhall
, insert-ordered-containers, neat-interpolation, optparse-generic
, shell-escape, stdenv, text
}:
mkDerivation {
  pname = "dhall-bash";
  version = "1.0.14";
  src = ./..;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base bytestring containers dhall insert-ordered-containers
    neat-interpolation shell-escape text
  ];
  executableHaskellDepends = [
    base bytestring dhall optparse-generic text
  ];
  description = "Compile Dhall to Bash";
  license = stdenv.lib.licenses.bsd3;
}
