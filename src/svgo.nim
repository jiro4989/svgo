import os, xmltree, strutils
from strformat import `&`
from sequtils import delete

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
  if "=" notin s:
    raise newException(SvgoError, &"illegal argument format: arg = '{s}'")
  let kv = s.split("=")
  let key = kv[0]
  let value = kv[1..^1].join("=")
  result = (key, value)

proc parseArgs(args: var seq[string]): XmlNode =
  var rawAttrs: seq[string]
  var level: int
  while true:
    let arg = args[0]
    case arg
    of "[":
      inc(level)
      if 2 <= level:
        let childNode = parseArgs(args)
        result.add(childNode)
        dec(level)
      else:
        args.delete(0, 0)
    of "]":
      dec(level)
      args.delete(0, 0)
      var attrs: seq[(string, string)]
      for rawAttr in rawAttrs:
        let attr = parseAttrArg(rawAttr)
        attrs.add(attr)
      result.attrs = attrs.toXmlAttributes
      rawAttrs = @[]
      if level <= 0:
        break
    else:
      args.delete(0, 0)
      if result == nil:
        result = newElement(arg)
        continue
      rawAttrs.add(arg)
  if 0 < level:
    raise newException(SvgoError, "illegal tree")

proc svgo(width=200, height=200, args: seq[string]): int =
  var vArgs = args[0..^2]
  let node = parseArgs(vArgs)
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