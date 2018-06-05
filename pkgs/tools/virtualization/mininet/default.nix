{ stdenv, lib, fetchFromGitHub
, which
# only supports python2
, python
, help2man
, pythonSupport ? true
, telnet
, makeWrapper
, pythonPackages
}:

let
  pyEnv = python.withPackages(ps: [
    ps.setuptools
  ]);
in
stdenv.mkDerivation rec {
  name = "mininet-${version}";
  version = "2.2.2";

  outputs = [ "out"  ];

  src = fetchFromGitHub {
    owner = "mininet";
    repo = "mininet";
    rev = version;
    sha256 = "18w9vfszhnx4j3b8dd1rvrg8xnfk6rgh066hfpzspzqngd5qzakg";
  };

  patches = [ ./Makefile.patch ];

  makeFlags = [
    "mnexec"
    "VERSION='\"${version}\"'"
  ];

  installFlags = [
    "install"
    "PREFIX=$(out)"
  ];

  preInstall= ''
    mkdir -p $out $py
    # without --root, install fails
    ${pyEnv.interpreter} setup.py install --root="/" --prefix=$out
  '';
  
  postFixup = ''
    wrapPythonProgramsIn $out/bin "$out"
    wrapProgram $out/bin/mnexec \
      --prefix PATH : "${telnet}/bin"
  '';

  doCheck = false;

  buildInputs = [ pythonPackages.wrapPython makeWrapper which help2man pyEnv ];

  meta = with lib; {
    description = "Emulator for rapid prototyping of Software Defined Networks";
    license = {
      fullName = "Mininet 2.3.0d1 License";
    };
    homepage = https://github.com/mininet/mininet;
    maintainers = with maintainers; [ teto ];
  };
}
