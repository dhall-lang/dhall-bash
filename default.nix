{ mkDerivation, base, bytestring, containers, dhall
, insert-ordered-containers, neat-interpolation, optparse-generic
, shell-escape, stdenv, text, text-format, trifecta
}:
mkDerivation {
  pname = "dhall-bash";
  version = "1.0.10";
  src = ./.;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base bytestring containers dhall insert-ordered-containers
    neat-interpolation shell-escape text text-format
  ];
  executableHaskellDepends = [
    base bytestring dhall optparse-generic text trifecta
  ];
  description = "Compile Dhall to Bash";
  license = stdenv.lib.licenses.bsd3;
}
