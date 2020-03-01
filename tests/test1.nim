import unittest

include svgo

suite "parseAttrArg":
  test "cx=1":
    check parseAttrArg("cx=1", @[]) == ("cx", "1")
  test "cx=$1 and [100, 200] == cx=100":
    check parseAttrArg("cx=$1", @["100", "200"]) == ("cx", "100")
  test "cx=$2 and [100, 200] == cx=200":
    check parseAttrArg("cx=$2", @["100", "200"]) == ("cx", "200")
  test "cx=$3 and [100, 200] == cx=$3":
    check parseAttrArg("cx=$3", @["100", "200"]) == ("cx", "$3")

suite "parseArgs":
  test "[ circle cx=100 cy=100 ]":
    var want = newElement("circle")
    want.attrs = {"cx":"100", "cy":"100"}.toXmlAttributes
    var args = @["[", "circle", "cx=100", "cy=100", "]"]
    let got = parseArgs(args, @[])
    check $want == $got
  test "[ circle cx=$1 cy=$2 ] and [100, 200]":
    var want = newElement("circle")
    want.attrs = {"cx":"100", "cy":"200"}.toXmlAttributes
    var args = @["[", "circle", "cx=$1", "cy=$2", "]"]
    let got = parseArgs(args, @["100", "200"])
    check $want == $got
  test "[ g [ circle cx=100 cy=100 ] ]":
    var want = newElement("g")
    var want2 = newElement("circle")
    want2.attrs = {"cx":"100", "cy":"100"}.toXmlAttributes
    want.add(want2)
    var args = @["[", "g", "[", "circle", "cx=100", "cy=100", "]", "]"]
    let got = parseArgs(args, @[])
    check $want == $got
  test "[ g [ circle cx=100 cy=100 ] [ rect x=0 y=0 width=200 height=200 ] ]":
    var want = newElement("g")
    block:
      var sub = newElement("circle")
      sub.attrs = {"cx":"100", "cy":"100"}.toXmlAttributes
      want.add(sub)
    block:
      var sub = newElement("rect")
      sub.attrs = {"x":"0", "y":"0", "width":"200","height":"200"}.toXmlAttributes
      want.add(sub)
    var args = @["[", "g", "[", "circle", "cx=100", "cy=100", "]", "[", "rect", "x=0", "y=0", "width=200", "height=200", "]", "]"]
    let got = parseArgs(args, @[])
    check $want == $got
  test "[ text x=10 y=20 TEXT=HelloWorld ]":
    var want = newElement("text")
    want.attrs = {"x":"10", "y":"20"}.toXmlAttributes
    want.add(newText("HelloWorld"))
    var args = @["[", "text", "x=10", "y=20", "TEXT=HelloWorld", "]"]
    let got = parseArgs(args, @[])
    check $want == $got
