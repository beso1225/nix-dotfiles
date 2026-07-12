{
  runCommand,
  gcc,
}:

runCommand "gcc-without-cc-${gcc.version}" { } ''
  mkdir -p "$out/bin"
  ln -s ${gcc}/bin/gcc "$out/bin/gcc"
  ln -s ${gcc}/bin/g++ "$out/bin/g++"
''
