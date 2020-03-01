import os, xmltree, strutils
from strformat import `&`

import cligen

type
  SvgoError = object of CatchableError

const
  version = """svgo version 0.1.0
Copyright (c) 2020 jiro4989
Released under the MIT License.
https://github.com/jiro4989/svgo"""

proc parseAttrArg(s: string): (string, string) =
  let kv = s.split("=")
  let key = kv[0]
  let value = kv[1..^1].join("=")
  result = (key, value)

proc parseArgs(args: seq[string]): XmlNode =
  var needElemName = true
  var attrs: seq[(string, string)]
  for arg in args:
    case arg
    of "[": discard
    of "]": discard
    else:
      if needElemName:
        result = newElement(arg)
        needElemName = false
        continue
      if "=" notin arg:
        raise newException(SvgoError, &"illegal argument format: arg = '{arg}'")
      let attr = parseAttrArg(arg)
      attrs.add(attr)
  result.attrs = attrs.toXmlAttributes

proc svgo(width=200, height=200, args: seq[string]): int =
  let node = parseArgs(args[0..^2])
  let outFile = args[^1]
  if outFile == "-":
    echo node

when isMainModule and not defined modeTest:
  import cligen
  clCfg.version = version
  dispatch(svgo, short = {"width":'W', "height":'H'})
