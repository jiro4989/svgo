# Package

version       = "0.1.0"
author        = "jiro4989"
description   = "SVG output from a shell."
license       = "MIT"
srcDir        = "src"
bin           = @["svgo"]
binDir        = "bin"


# Dependencies

requires "nim >= 1.0.6"
requires "cligen >= 0.9.32"
