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
  svgDocType = """<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
"""

proc parseAttrArg(s: string, fields: seq[string]): (string, string) =
  if "=" notin s:
    raise newException(SvgoError, &"illegal argument format: arg = '{s}'")
  let kv = s.split("=")
  let key = kv[0]
  var value = kv[1..^1].join("=")
  for i, f in fields:
    let i = i + 1
    value = value.replace(&"${i}", f)
  result = (key, value)

proc parseArgs(args: var seq[string], fields: seq[string]): XmlNode =
  var rawAttrs: seq[string]
  var level: int
  while true:
    let arg = args[0]
    case arg
    of "[":
      inc(level)
      if 2 <= level:
        let childNode = parseArgs(args, fields)
        result.add(childNode)
        dec(level)
      else:
        args.delete(0, 0)
    of "]":
      dec(level)
      args.delete(0, 0)
      var attrs: seq[(string, string)]
      for rawAttr in rawAttrs:
        let attr = parseAttrArg(rawAttr, fields)
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

proc svgo(useStdin=false, autoIncrementOutFileNumber=false, outFileNumberWidth=6, width=200, height=200, outFile="", args: seq[string]): int =
  proc processLine(outFile: string, fields: seq[string], i: int) =
    var outFile = outFile
    var vArgs = args
    let node = parseArgs(vArgs, fields)
    var body: string
    body.add(xmlHeader)
    body.add(svgDocType)
    let attr = {
      "width": $width,
      "height": $height,
      "version":"1.1",
      "xmlns":"http://www.w3.org/2000/svg",
      }.toXmlAttributes
    let tree = newXmlTree("svg", [node], attr)
    body.add($tree)
    if outFile == "":
      echo body
    else:
      if useStdin and autoIncrementOutFileNumber:
        let num = align($i, outFileNumberWidth, '0')
        outFile = outFile.replace("$0", num)
      writeFile(outFile, body)

  if useStdin:
    var i: int
    for line in stdin.lines:
      let fields = line.split(" ")
      processLine(outFile, fields, i)
      inc(i)
    return
  processLine(outFile, @[], 0)

when isMainModule and not defined modeTest:
  import cligen
  clCfg.version = version
  dispatch(svgo,
           short = {
            "useStdin":'i',
            "autoIncrementOutFileNumber":'n',
            "outFileNumberWidth":'w',
            "width":'W',
            "height":'H',
            })
