---
stand_alone: true
ipr: trust200902
docname: draft-normington-jsonpath-latest
cat: std
obsoletes: ''
updates: ''
consensus: 'true'
submissiontype: IETF
lang: en
pi:
  toc: 'true'
  tocdepth: '4'
  symrefs: 'true'
  sortrefs: 'true'
title: JavaScript Object Notation (JSON) Path
area: General
wg: Internet Engineering Task Force
kw: JSON
date: 2020

author:
- role: editor
  ins: G. Normington
  name: Glyn Normington
  org: VMware, Inc.
  street: ''
  city: Winchester
  region: ''
  code: ''
  country: UK
  phone: ''
  email: glyn.normington@gmail.com
- role: editor
  ins: E. Surov
  name: Edward Surov
  org: TheSoul Publishing Ltd.
  street: ''
  city: Limassol
  region: ''
  code: ''
  country: Cyprus
  phone: ''
  email: esurov.tsp@gmail.com
- ins: M. Mikulicic
  name: Marko Mikulicic
  org: VMware, Inc.
  street: ''
  city: Pisa
  region: ''
  code: ''
  country: IT
  phone: ''
  email: mmikulicic@gmail.com

contributor:
- ins: C. Bormann
  name: Carsten Bormann
  org: Universitaet Bremen TZI
  street: Postfach 330440
  city: D-28359 Bremen
  country: Germany
  phone: "+49-421-218-63921"
  email: cabo@tzi.org


informative:
  RFC3552:
  RFC5226:
  RFC6901:
  RFC8259:
  Goessner:
    target: https://goessner.net/articles/JsonPath/
    title: JSONPath - XPath for JSON
    author:
    - org: Stefan Gössner
    date: 2007-02
  ECMA-262:
    target: http://www.ecma-international.org/publications/files/ECMA-ST-ARCH/ECMA-262,%203rd%20edition,%20December%201999.pdf
    title: ECMAScript Language Specification, Standard ECMA-262, Third Edition
    author:
    - org: Ecma International
    date: 1999-12

normative:
  RFC3629:
  RFC5234:

--- abstract


JSONPath defines a string syntax for identifying values
within a JavaScript Object Notation (JSON) document.

--- note_

**This document is a work in progress and has not yet been published
as an Internet Draft.**

--- middle

# Introduction

JSONPath was introduced by Stefan Goessner as a simple
form of XPath for JSON.
See his original article {{Goessner}}.

JSON is defined by {{RFC8259}}.

## Requirements Language

{::boilerplate bcp14}

## ABNF Syntax

The syntax in this document conforms to ABNF as defined by {{RFC5234}}.

ABNF terminal values in this document define Unicode code points rather than
their UTF-8 encoding.
For example, the Unicode PLACE OF INTEREST SIGN (U+2318) would be defined
in ABNF as `%x2318`.



# JSONPath Syntax and Semantics

## Overview

A JSONPath is a string which selects zero or more nodes of a piece of JSON.
A valid JSONPath conforms to the ABNF syntax defined by this document.

A JSONPath MUST be encoded using UTF-8. To parse a JSONPath according to the grammar in this document, its UTF-8 form SHOULD first be decoded into Unicode code points as described in {{RFC3629}}.


## Terminology

A JSON value is logically a tree of nodes.

Each node holds a JSON value (as defined by {{RFC8259}}) of one of the types object, array, number, string, or one of the literals `true`, `false`, or `null`. The type of the JSON value held by a node is sometimes referred to as the type of the node.


## Implementation

An implementation of this specification, from now on referred to simply as "an implementation", SHOULD takes two inputs, a JSONPath and a JSON value, and produce a possibly empty list of nodes of the JSON value which are selected by the JSONPath or an error (but not both).

If no node is selected and no error has occurred, an implementation MUST return an empty list of nodes.

Syntax errors in the JSONPath SHOULD be detected before selection is attempted since these errors do not depend on the JSON value. Therefore, an implementation SHOULD take a JSONPath and produce an optional syntax error and then, if and only if an error was not produced, SHOULD take a JSON value and produce a list of nodes or an error (but not both).

Alternatively, an implementation MAY take a JSONPath and a JSON value and produce a list of nodes or an optional error (but not both).

For any implementation, if a syntactically invalid JSONPath is provided, the implementation MUST return an error.

If a syntactially invalid JSON value is provided, any implementation SHOULD return an error.


## Syntax

Syntactically, a JSONPath consists of a root selector (`$`), which selects the root node of a JSON value, followed by a possibly empty sequence of *selectors*.

~~~~ abnf
json-path = root-selector *selector
root-selector = %x24               ; $ selects document root node
~~~~

The syntax and semantics of each selector is defined below.


## Semantics

The root selector `$` not only selects the root node of the input document, but it also produces as output a list consisting of one node: the input document.

A selector may select zero or more nodes for further processing. A syntactically valid selector MUST NOT produce errors. This means that some operations which might be considered erroneous, such as indexing beyond the end of an array, simply result in fewer nodes being selected.

But a selector doesn't just act on a single node: each selector acts on a list of nodes and produces a list of nodes, as follows.

After the root selector, the remainder of the JSONPath is processed by passing lists of nodes from one selector to the next ending up with a list of nodes which is the result of applying the JSONPath to the input JSON value.

Each selector acts on its input list of nodes as follows. For each node in the list, the selector selects zero or more nodes, each of which is a descendant of the node or the node itself. The output list of nodes of a selector is the concatenation of the lists of selected nodes for each input node.

A specific, non-normative example will make this clearer. Suppose the input document is: `{"a":[{"b":0},{"b":1},{"c":2}]}`. As we will see later, the JSONPath `$.a[*].b` selects the following list of nodes: `0`, `1`. Let's walk through this in detail.

The JSONPath consists of `$` followed by three selectors: `.a`, `[*]`, and `.b`.

Firstly, `$` selects the root node which is the input document. So the result is a list consisting of just the root node.

Next, `.a` selects from any input node of type object and selects any value of the input node corresponding to the key `"a"`. The result is again a list of one node: `[{"b":0},{"b":1},{"c":2}]`.

Next, `[*]` selects from any input node which is an array and selects all the elements of the input node. The result is a list of three nodes: `{"b":0}`, `{"b":1}`, and `{"c":2}`.

Finally, `.b` selects from any input node of type object with a key `b` and selects the value of the input node corresponding to that key. The result is a list containing `0`, `1`. This is the concatenation of three lists, two of length one containing `0`, `1`, respectively, and one of length zero.

As a consequence of this approach, if any of the selectors selects no nodes, then the whole JSONPath selects no nodes.

In what follows, the semantics of each selector are defined for each type of node.


## Selectors

### Dot Child Selector

#### Syntax
{: numbered="false" toc="exclude"}

A dot child selector has a key known as a dot child name or a single asterisk (`*`).

A dot child name corresponds to a name in a JSON object.

~~~~ abnf
selector = dot-child              ; see below for alternatives
dot-child = %x2E dot-child-name / ; .<dot-child-name>
            %x2E %x2A             ; .*
dot-child-name = 1*(
                   %x2D /         ; -
                   DIGIT /
                   ALPHA /
                   %x5F /         ; _
                   %x80-10FFFF    ; any non-ASCII Unicode character
                 )
DIGIT =  %x30-39                  ; 0-9
ALPHA = %x41-5A / %x61-7A         ; A-Z / a-z
~~~~

More general child names, such as the empty string, are supported by "Union Child" ({{unionchild}}{: format="default"}).

Note that the `dot-child-name` rule follows the philosophy of JSON strings and is allowed to contain bit sequences that cannot encode Unicode characters (a single unpaired UTF-16 surrogate, for example). The behaviour of an implementation is undefined for child names which do not encode Unicode characters.


#### Semantics
{: numbered="false" toc="exclude"}

A dot child name which is not a single asterisk (`*`) is considered to have a key. It selects the value corresponding to the key from any object node. It selects no nodes from a node which is not an object.

The key of a dot child name is the sequence of Unicode characters contained in that name.

A dot child name consisting of a single asterisk is a wild card. It selects all the values of any object node. It also selects all the elements of any array node.
It selects no nodes from number, string, or literal nodes.



### Union Selector

#### Syntax

A union selector consists of one or more union elements.

~~~~ abnf
selector =/ union
union = %x5B ws union-elements ws %x5D ; [...]
ws = *%x20                             ; zero or more spaces
union-elements = union-element /
                 union-element ws %x2C ws union-elements
                                       ; ,-separated list
~~~~


#### Semantics

A union selects any node which is selected by at least one of the union selectors and selects the concatenation of the lists (in the order of the selectors) of nodes selected by the union elements.<!--  TODO: define whether duplicates are kept or removed.  -->


#### Child {#unionchild}

##### Syntax
{: numbered="false" toc="exclude"}

A child is a quoted string.

~~~~ abnf
union-element = child ; see below for more alternatives
child = %x22 *double-quoted %x22 / ; "string"
        %x27 *single-quoted %x27   ; 'string'

double-quoted = dq-unescaped /
          escape (
              %x22 /          ; "    quotation mark  U+0022
              %x2F /          ; /    solidus         U+002F
              %x5C /          ; \    reverse solidus U+005C
              %x62 /          ; b    backspace       U+0008
              %x66 /          ; f    form feed       U+000C
              %x6E /          ; n    line feed       U+000A
              %x72 /          ; r    carriage return U+000D
              %x74 /          ; t    tab             U+0009
              %x75 4HEXDIG )  ; uXXXX                U+XXXX


      dq-unescaped = %x20-21 / %x23-5B / %x5D-10FFFF

single-quoted = sq-unescaped /
          escape (
              %x27 /          ; '    apostrophe      U+0027
              %x2F /          ; /    solidus         U+002F
              %x5C /          ; \    reverse solidus U+005C
              %x62 /          ; b    backspace       U+0008
              %x66 /          ; f    form feed       U+000C
              %x6E /          ; n    line feed       U+000A
              %x72 /          ; r    carriage return U+000D
              %x74 /          ; t    tab             U+0009
              %x75 4HEXDIG )  ; uXXXX                U+XXXX

      sq-unescaped = %x20-26 / %x28-5B / %x5D-10FFFF

escape = %x5C                 ; \

HEXDIG =  DIGIT / "A" / "B" / "C" / "D" / "E" / "F"
                              ; case insensitive hex digit
~~~~

Notes:
1. double-quoted strings follow JSON in {{RFC8259}}.
   Single-quoted strings follow an analogous pattern.
2. `HEXDIG` includes A-F and a-f.


##### Semantics
{: numbered="false" toc="exclude"}

If the child is a quoted string, the string MUST be converted to a key by removing the surrounding quotes and replacing each escape sequence with its equivalent Unicode character, as in the table below:

| Escape Sequence | Unicode Character |
|:---------------:|:-----------------:|
| %x5C %x22       | U+0022            |
| %x5C %x27       | U+0027            |
| %x5C %x2F       | U+002F            |
| %x5C %x5C       | U+005C            |
| %x5C %x62       | U+0008            |
| %x5C %x66       | U+000C            |
| %x5C %x6E       | U+000A            |
| %x5C %x72       | U+000D            |
| %x5C %x74       | U+0009            |
| %x5C uXXXX      | U+XXXX            |
{: title="Escape Sequence Replacements" cols="c c"}

The child selects the value corresponding to the key from any object node with the key as a name. It selects no nodes from a node which is not an object.



#### Array Selector

##### Syntax
{: numbered="false" toc="exclude"}

An array selector selects zero or more elements of an array node. An array selector takes the form of an index, which selects at most one element, or a slice, which selects zero or more elements.

~~~~ abnf
union-element =/ array-index / array-slice
~~~~

An array index is an integer (in base 10).

~~~~ abnf
array-index = integer

integer = ["-"] ("0" / (DIGIT1 *DIGIT))
                            ; optional - followed by 0 or
                            ; sequence of digits with no leading zero
DIGIT1 = %x31-39            ; non-zero digit
~~~~

Note: the syntax does not allow integers with leading zeros such as `01` and `-01`.

An array slice consists of three optional integers (in base 10) separated by colons.

~~~~ abnf
array-slice = [ start ] ws ":" ws [ end ]
                   [ ws ":" ws [ step ] ]
start = integer
end = integer
step = integer
~~~~

Note: the array slices `:` and `::` are both syntactically valid, as are `:2:2`, `2::2`, and `2:4:`.

##### Semantics
{: numbered="false" toc="exclude"}

###### Informal Introduction
{: numbered="false" toc="exclude"}

This section is non-normative.

Array indexing is a way of selecting a particular element of an array using a 0-based index. For example, the expression `[0]` selects the first element of a non-empty array.

Negative indices index from the end of an array. For example, the expression `[-2]` selects the last but one element of an array with at least two elements.

Array slicing is inspired by the behaviour of the `Array.prototype.slice` method of the JavaScript language as defined by the ECMA-262 standard {{ECMA-262}}, with the addition of the `step` parameter, which is inspired by the Python slice expression.

The array slice expression `[start:end:step]` selects elements at indices starting at `start`, incrementing by `step`, and ending with `end` (which is itself excluded).
So, for example, the expression `[1:3]` (where `step` defaults to `1`) selects elements with indices `1` and `2` (in that order) whereas `[1:5:2]` selects elements with indices `1` and `3`.

When `step` is negative, elements are selected in reverse order. Thus, for example, `[5:1:-2]` selects elements with indices `5` and `3`, in that order and `[::-1]` selects all the elements of an array in reverse order.

When `step` is `0`, no elements are selected. This is the one case which differs from the behaviour of Python, which raises an error in this case.

The following section specifies the behaviour fully, without depending on JavaScript or Python behaviour.


###### Detailed Semantics
{: numbered="false" toc="exclude"}

An array selector is either an array slice or an array index, which is defined in terms of an array slice.

A slice expression selects a subset of the elements of the input array, in the same order as the array or the reverse order, depending on the sign of the `step` parameter. It selects no nodes from a node which is not an array.

A slice is defined by the two slice parameters, `start` and `end`, and an iteration delta, `step`. Each of these parameters is optional. `len` is the length of the input array.

The default value for `step` is `1`. The default values for `start` and `end` depend on the sign of `step`, as follows:

| Condition    | start   | end      |
|--------------|---------|----------|
| step >= 0    | 0       | len      |
| step < 0     | len - 1 | -len - 1 |
{: title="Default array slice start and end values"}

Slice expression parameters `start` and `end` are not directly usable as slice bounds and must first be normalized. Normalization is defined as:

~~~~
FUNCTION Normalize(i):
  IF i >= 0 THEN
    RETURN i
  ELSE
    RETURN len + i
  END IF
~~~~

The result of the array indexing expression `[i]` is defined to be the result of the array slicing expression `[i:Normalize(i)+1:1]`.

Slice expression parameters `start` and `end` are used to derive slice bounds `lower` and `upper`. The direction of the iteration, defined by the sign of `step`, determines which of the parameters is the lower bound and which is the upper bound:

~~~~
FUNCTION Bounds(start, end, step, len):
  n_start = Normalize(start)
  n_end = Normalize(end)

  IF step >= 0 THEN
    lower = MIN(MAX(n_start, 0), len)
    upper = MIN(MAX(n_end, 0), len)
  ELSE
    upper = MIN(MAX(n_start, -1), len-1)
    lower = MIN(MAX(n_end, -1), len-1)
  END IF

  RETURN (lower, upper)
~~~~

The slice expression selects elements with indices between the lower and upper bounds. In the following pseudocode, the `a(i)` construct expresses the 0-based indexing operation on the underlying array.

~~~~
IF step > 0 THEN

  i = lower
  WHILE i < upper:
    SELECT a(i)
    i = i + step
  END WHILE

ELSE if step < 0 THEN

  i = upper
  WHILE lower < i:
    SELECT a(i)
    i = i + step
  END WHILE

END IF
~~~~

When `step = 0`, no elements are selected and the result array is empty.

An implementation MUST raise an error if any of the slice expression parameters does not fit in the implementation's representation of an integer. If a successfully parsed slice expression is evaluated against an array whose
size doesn't fit in the implementation's representation of an integer, the implementation MUST raise an error.







# IANA Considerations {#IANA}

This memo includes no request to IANA.

All drafts are required to have an IANA considerations section (see [Guidelines for Writing an IANA Considerations Section in RFCs](#RFC5226){: format="default"} for a guide). If the draft does not require IANA to do anything, the section contains an explicit statement that this is the case (as above). If there are no requirements for IANA, the section will be removed during conversion into an RFC by the RFC Editor.


# Security Considerations {#Security}

This section gives security considerations, as required by {{RFC3552}}.


# Alternatives {#Alternatives}

An analogous standard, JSON Pointer, is provided by {{RFC6901}}.


--- back
