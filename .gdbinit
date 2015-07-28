# gdb options
set history save
set history filename ~/.gdb_history

set confirm off

# helper functions
define trace-fun
  if $argc != 1
    help trace-fun
  else
    break $arg0
    commands
      silent
      backtrace 1
      continue
    end
  end
end
document trace-fun
Trace a function, without "interrupting" it.
Usage: trace-fun functionname
end
