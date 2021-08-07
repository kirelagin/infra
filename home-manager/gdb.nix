{
  home.file.".gdbinit".text = ''
    set disassembly-flavor intel

    define a
      if $argc == 0
        disassemble
      end
      if $argc == 1
        disassemble $arg0
      end
    end
  '';
}
