import unittest

include svgo

suite "parseAttrArg":
  test "main":
    check parseAttrArg("cx=1") == ("cx", "1")

suite "parseArgs":
  test "[ circle cx=100 cy=100 ]":
    var want = newElement("circle")
    want.attrs = {"cx":"100", "cy":"100"}.toXmlAttributes
    var args = @["[", "circle", "cx=100", "cy=100", "]"]
    let got = parseArgs(args)
    check $want == $got
  test "[ g [ circle cx=100 cy=100 ] ]":
    var want = newElement("g")
    var want2 = newElement("circle")
    want2.attrs = {"cx":"100", "cy":"100"}.toXmlAttributes
    want.add(want2)
    var args = @["[", "g", "[", "circle", "cx=100", "cy=100", "]", "]"]
    let got = parseArgs(args)
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
    let got = parseArgs(args)
    check $want == $got
