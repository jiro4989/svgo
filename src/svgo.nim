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
  svgDocType = """<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">"""

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
    echo xmlHeader
    echo svgDocType
    let attr = {"width": $width, "height": $height, "version":"1.1", "xmlns":"http://www.w3.org/2000/svg"}.toXmlAttributes
    let tree = newXmlTree("svg", [node], attr)
    echo tree

when isMainModule and not defined modeTest:
  import cligen
  clCfg.version = version
  dispatch(svgo, short = {"width":'W', "height":'H'})
