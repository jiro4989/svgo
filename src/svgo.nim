import xmltree, strutils
from strformat import `&`
from sequtils import delete

import cligen

type
  SvgoError = object of CatchableError

const
  version = """svgo version 0.3.1
Copyright (c) 2020 jiro4989
Released under the MIT License.
https://github.com/jiro4989/svgo"""
  svgDocType = """<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
"""

proc replaceSpecialVariables(s: string, nr: int, fields: seq[string]): string =
  result = s
    .replace("$NR", $nr)
    .replace("$NF", $fields.len)
  if fields.len < 1: return
  # NOTE: for replacing $10, and replace $1
  for i in countdown(fields.len-1, 0):
    let f = fields[i]
    let i = i + 1
    result = result.replace(&"${i}", f)

proc parseAttrArg(s: string, nr: int, fields: seq[string]): (string, string) =
  if "=" notin s:
    raise newException(SvgoError, &"illegal argument format: arg = '{s}'")
  let kv = s.split("=")
  let key = kv[0]
  var value = kv[1..^1].join("=")
  value = value.replaceSpecialVariables(nr, fields)
  result = (key, value)

proc parseArgs(args: var seq[string], nr: int, fields: seq[string]): XmlNode =
  var rawAttrs: seq[string]
  var level: int
  while true:
    let arg = args[0]
    case arg
    of "[":
      inc(level)
      if 2 <= level:
        let childNode = parseArgs(args, nr, fields)
        result.add(childNode)
        dec(level)
      else:
        args.delete(0, 0)
    of "]":
      dec(level)
      args.delete(0, 0)
      var attrs: seq[(string, string)]
      for rawAttr in rawAttrs:
        if rawAttr.startsWith("TEXT="):
          let text = rawAttr[5..^1]
          result.add(newText(text))
          continue
        let attr = parseAttrArg(rawAttr, nr, fields)
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

proc svgo(useStdin = false, autoIncrementOutFileNumber = false,
    outFileNumberWidth = 6, width = 200, height = 200, outFile = "", args: seq[string]): int =
  proc processLine(outFile: string, nr: int, fields: seq[string]) =
    var outFile = outFile
    var vArgs = args
    let node = parseArgs(vArgs, nr, fields)
    var body: string
    body.add(xmlHeader)
    body.add(svgDocType)
    let attr = {
      "width": $width,
      "height": $height,
      "version": "1.1",
      "xmlns": "http://www.w3.org/2000/svg",
      }.toXmlAttributes
    let tree = newXmlTree("svg", [node], attr)
    body.add($tree)
    if outFile == "":
      echo body
    else:
      if useStdin and autoIncrementOutFileNumber:
        let num = align($nr, outFileNumberWidth, '0')
        outFile = outFile.replace("$NR", num)
      writeFile(outFile, body)

  if useStdin:
    var i: int
    for line in stdin.lines:
      inc(i)
      let fields = line.split(" ")
      processLine(outFile, i, fields)
    return
  processLine(outFile, 1, @[])

when isMainModule and not defined modeTest:
  import cligen
  clCfg.version = version
  dispatch(
    svgo,
    help = {
      "useStdin": "activate a flag to read stdin",
      "autoIncrementOutFileNumber": "activate a variable of current record number for outfile",
      "outFileNumberWidth": "set a padding width of outfile number",
      "width": "set a width of SVG object",
      "height": "set a height of SVG object",
    },
    short = {
      "useStdin": 'i',
      "autoIncrementOutFileNumber": 'n',
      "outFileNumberWidth": 'w',
      "width": 'W',
      "height": 'H',
    })
