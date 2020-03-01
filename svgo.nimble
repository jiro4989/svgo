# Package

version       = "0.3.1"
author        = "jiro4989"
description   = "SVG output from a shell."
license       = "MIT"
srcDir        = "src"
bin           = @["svgo"]
binDir        = "bin"


# Dependencies

requires "nim >= 1.0.6"
requires "cligen >= 0.9.32"

import os, strformat

task archive, "Create archived assets":
  let app = "svgo"
  let assets = &"{app}_{buildOS}"
  let dir = "dist"/assets
  mkDir dir
  cpDir "bin", dir/"bin"
  cpFile "LICENSE", dir/"LICENSE"
  cpFile "README.rst", dir/"README.rst"
  withDir "dist":
    when buildOS == "windows":
      exec &"7z a {assets}.zip {assets}"
    else:
      exec &"tar czf {assets}.tar.gz {assets}"
