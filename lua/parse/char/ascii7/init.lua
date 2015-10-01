-- same as lpeg.R('\0\127')
return require 'parse.char.ascii7.symbol'
     + require 'parse.char.ascii7.whitespace'
     + require 'parse.char.ascii7.control'
     + require 'parse.char.ascii7.null'
