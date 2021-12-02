---
stand_alone: true
ipr: trust200902
docname: draft-ietf-jsonpath-base-latest
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
  comments: true
title: "JSONPath: Query expressions for JSON"
abbrev: JSONPath
area: ART
wg: JSONPath WG
kw: JSON
date: 2021

author:
-
  role: editor
  name: Stefan Gössner
  org: Fachhochschule Dortmund
  city: Dortmund
  code: D-44139
  street: Sonnenstraße 96
  country: Germany
  email: stefan.goessner@fh-dortmund.de
-
  role: editor
  name: Glyn Normington
  org: ''
  street: ''
  city: Winchester
  region: ''
  code: ''
  country: UK
  phone: ''
  email: glyn.normington@gmail.com
-
  role: editor
  name: Carsten Bormann
  org: Universität Bremen TZI
  orgascii: Universitaet Bremen TZI
  street: Postfach 330440
  city: Bremen
  code: D-28359
  country: Germany
  phone: +49-421-218-63921
  email: cabo@tzi.org

contributor:
-
  name: Marko Mikulicic
  org: InfluxData, Inc.
  street: ''
  city: Pisa
  region: ''
  code: ''
  country: IT
  phone: ''
  email: mmikulicic@gmail.com
-
  name: Edward Surov
  org: TheSoul Publishing Ltd.
  street: ''
  city: Limassol
  region: ''
  code: ''
  country: Cyprus
  phone: ''
  email: esurov.tsp@gmail.com

informative:
  RFC3552: seccons
#  RFC8126: ianacons
  RFC6901: pointer
  RFC6901: pointer
  JSONPath-orig:
    target: https://goessner.net/articles/JsonPath/
    title: JSONPath — XPath for JSON
    author:
      name: Stefan Gössner
      org: Fachhochschule Dortmund
    date: 2007-02-21
  XPath: W3C.REC-xpath20-20101214
  E4X:
    title: >
      Information technology — ECMAScript for XML (E4X) specification
    author:
    - org: ISO
    seriesinfo:
      ISO/IEC 22537:2006
    date: 2006
  SLICE:
    target: https://github.com/tc39/proposal-slice-notation
    title: Slice notation
  ECMA-262:
    target: http://www.ecma-international.org/publications/files/ECMA-ST-ARCH/ECMA-262,%203rd%20edition,%20December%201999.pdf
    title: ECMAScript Language Specification, Standard ECMA-262, Third Edition
    author:
    - org: Ecma International
    date: 1999-12

normative:
  RFC3629:
  RFC5234: abnf
  RFC8259: json
  RFC7493: i-json

venue:
  group: JSON Path
  mail: jsonpath@ietf.org
  github: ietf-wg-jsonpath/draft-ietf-jsonpath-base

...
--- abstract

JSONPath defines a string syntax for selecting and extracting values
within a JavaScript Object Notation (JSON, RFC 8259) value.

--- middle

<!-- define an ALD to simplify below -->
{:unnumbered: numbered="false" toc="exclude"}
<!-- use as {: unnumbered} -->

<!-- editorial issue: lots of complicated nesting of quotes, as in -->
<!-- `"13 == '13'"` or `$`.  We probably should find a simpler style -->

# Introduction

JavaScript Object Notation (JSON, {{-json}}) is a popular representation
format for structured data values.
JSONPath defines a string syntax for identifying values
within a JSON value.

JSONPath is not intended as a replacement, but as a more powerful
companion, to JSON Pointer {{RFC6901}}. [^json-pointer-missing]

[^json-pointer-missing]:
    Insert reference to section where the relationship is detailed.
    The purposes of the two syntaxes are different.
    Pointer is for isolating a single location within a JSON document.
    Path is a query syntax that can also be used to pull multiple
    locations.

## Terminology

{::boilerplate bcp14-tagged}

The grammatical rules in this document are to be interpreted as ABNF,
as described in {{-abnf}}.
ABNF terminal values in this document define Unicode code points rather than
their UTF-8 encoding.
For example, the Unicode PLACE OF INTEREST SIGN (U+2318) would be defined
in ABNF as `%x2318`.

The terminology of {{-json}} applies except where clarified below.
The terms "Primitive" and "Structured" are used to group
the types as in {{Section 1 of -json}}.
Definitions for "Object", "Array", "Number", and "String" remain
unchanged.
Importantly "object" and "array" in particular do not take on a
generic meaning, such as they would in a general programming context.

Additional terms used in this specification are defined below.

Value:
: As per {{-json}}, a structure complying to the generic data model of JSON, i.e.,
  composed of components such as structured values, namely JSON objects and arrays, and
  primitive data, namely numbers and text strings as well as the special
  values null, true, and false.

Member:
: A name/value pair in an object.  (Not itself a value.)

Name:
: The name in a name/value pair constituting a member.  (Also known as
  "key", "tag", or "label".)
  This is also used in {{-json}}, but that specification does not
  formally define it.
  It is included here for completeness.

Element:
: A value in an array. (Not to be confused with XML element.)

Index:
: A non-negative integer that identifies a specific element in an array.
  Note that the term _indexing_ is also used for accessing elements
  using negative integers ({{index-semantics}}), and for accessing
  member values in an object using their member name.

Query:
: Short name for JSONPath expression.

Argument:
: Short name for the value a JSONPath expression is applied to.

Node:
: The pair of a value along with its location within the argument.

Root Node:
: The unique node whose value is the entire argument.

Children (of a node):
: If the node is an array, each of its elements,
  or if the node is an object, each its member values (but not its
  member names).

Descendants (of a node):
: The node itself, plus the descendants of each of its children. [^or-self]

[^or-self]: Note that this is often more selectively called descendant-or-self.
    Should we define descendants non-inclusive of the node itself?
    We do have the language to say "node + descendants" in several places.

Nodelist:
: A list of nodes.  <!-- ordered list?  Maybe TBD by issues #27 and #60 -->
  The output of applying a query to an argument is manifested as a list of nodes.
  While this list can be represented in JSON, e.g. as an array, the
  nodelist is an abstract concept unrelated to JSON values.

Normalized Path:
: A simple form of JSONPath expression that identifies a node by
  providing a query that results in exactly that node.  Similar
  to, but syntactically different from, a JSON Pointer {{-pointer}}.

<!--
  Depending on the outcome of [?()] expression support discussions,
  we may also need to define "boolean", "number", and perhaps others.
-->

For the purposes of this specification, a value as defined by
{{-json}} is also viewed as a tree of nodes.
Each node, in turn, holds a value.
Further nodes within each value are the elements of arrays and the
member values of objects and are themselves values.
(The type of the value held by a node
may also be referred to as the type of the node.)

A query is applied to an argument, and the output is a nodelist.

## History

This document picks up Stefan Gössner's popular JSONPath proposal
dated 2007-02-21 {{JSONPath-orig}} and provides a normative definition
for it.

{{inspired-by-xpath}} describes how JSONPath was inspired by XML's XPath
[XPath].

JSONPath was intended as a light-weight companion to JSON
implementations on platforms such as PHP and JavaScript, so instead of
defining its own expression language like XPath did, JSONPath
delegated this to the expression language of the platform.
While the languages in which JSONPath is used do have significant
commonalities, over time this caused non-portability of JSONPath
expressions between the ensuing platform-specific dialects.

The present specification intends to remove platform dependencies and
serve as a common JSONPath specification that can be used across
platforms.  Obviously, this means that backwards compatibility could
not always be achieved; a design principle of this specification is to
go with a "consensus" between implementations even if it is rough, as
long as that does not jeopardize the objective of obtaining a usable,
stable JSON query language.

## Overview of JSONPath Expressions {#overview}

JSONPath expressions are applied to a JSON value, the *argument*.
Within the JSONPath expression, the abstract name `$` is used to refer
to the *root node* of the argument, i.e., to the argument as a whole.

JSONPath expressions can use the *dot notation*

~~~~
$.store.book[0].title
~~~~

or the *bracket notation*

~~~~
$['store']['book'][0]['title']
~~~~

to build paths that are input to a JSONPath processor.
Bracket notation is more general than dot notation and can serve as a
canonical form (for instance, when a JSONPath processor uses JSONPath
expressions as output paths).

JSONPath allows the wildcard symbol `*` to select any member of an
object or any element of an array ({{wildcard}}).
The descendant operator `..` selects the node and all its descendants ({{descendant-selector}}).
The array slice
syntax `[start:end:step]` allows selecting a regular selection of an
element from an array, giving a start position, an end position, and
possibly a step value that moves the position from the start to the
end ({{slice}}).

Filter expressions are supported via the syntax `?(<boolean expr>)` as in

~~~~
$.store.book[?(@.price < 10)].title
~~~~

{{tbl-overview}} provides a quick overview of the JSONPath syntax elements.

| JSONPath       | Description           |
|----------------|-----------------------|
| `$`                | the root node                                                                |
| `@`                | the current node                                                             |
| `.` or `[]`        | child operator                                                               |
| n/a                | parent operator                                                              |
| `..`               | nested descendants                                                           |
| `*`                | wildcard: all member values/array elements regardless of their names/indices |
| `[]`               | subscript operator: index current node as an array (from 0)                  |
| `[,]`              | Union operator JSONPath allows alternate(??) names or array indices as a set |
| `[start:end:step]` | array slice operator                                                         |
| `?()`              | applies a filter expression                                                  |
| `()`               | expression, e.g., for indexing                                               |
{: #tbl-overview title="Overview over JSONPath"}

# JSONPath Examples

This section provides some more examples for JSONPath expressions.
The examples are based on the simple JSON value shown in
{{fig-example-value}}, which was patterned after a
typical XML example representing a bookstore (that also has bicycles).

~~~~json
{ "store": {
    "book": [
      { "category": "reference",
        "author": "Nigel Rees",
        "title": "Sayings of the Century",
        "price": 8.95
      },
      { "category": "fiction",
        "author": "Evelyn Waugh",
        "title": "Sword of Honour",
        "price": 12.99
      },
      { "category": "fiction",
        "author": "Herman Melville",
        "title": "Moby Dick",
        "isbn": "0-553-21311-3",
        "price": 8.99
      },
      { "category": "fiction",
        "author": "J. R. R. Tolkien",
        "title": "The Lord of the Rings",
        "isbn": "0-395-19395-8",
        "price": 22.99
      }
    ],
    "bicycle": {
      "color": "red",
      "price": 19.95
    }
  }
}
~~~~
{: #fig-example-value title="Example JSON value"}

The examples in {{tbl-example}} use the expression mechanism to obtain
the number of elements in an array, to test for the presence of a
member in a object, and to perform numeric comparisons of member values with a
constant.

| JSONPath                                  | Result                                                       |
|-------------------------------------------|--------------------------------------------------------------|
| `$.store.book[*].author`                  | the authors of all books in the store                        |
| `$..author`                               | all authors                                                  |
| `$.store.*`                               | all things in store, which are some books and a red bicycle  |
| `$.store..price`                          | the prices of everything in the store                        |
| `$..book[2]`                              | the third book                                               |
| `$..book[(@.length-1)]`<br>`$..book[-1]`  | the last book in order                                       |
| `$..book[0,1]`<br>`$..book[:2]`           | the first two books                                          |
| `$..book[?(@.isbn)]`                      | filter all books with isbn number                            |
| `$..book[?(@.price<10)]`                  | filter all books cheaper than 10                             |
| `$..*`                                    | all elements in XML document; all member values and array elements contained in input value |
{: #tbl-example title="Example JSONPath expressions applied to the example JSON value"}

<!-- XXX: fine tune: is $..* really member values + array elements -->

<!-- back to normington draft; not yet merged up where needed (e.g., terminology). -->

# JSONPath Syntax and Semantics

## Overview {#synsem-overview}

A JSONPath query is a string which selects zero or more nodes of a piece of JSON.

A query MUST be encoded using UTF-8.
The grammar for queries given in this document assumes that its UTF-8 form is first decoded into
Unicode code points as described
in {{RFC3629}}; implementation approaches that lead to an equivalent
result are possible.

A string to be used as a JSONPath query needs to be *well-formed* and
*valid*.
A string is a well-formed JSONPath query if it conforms to the ABNF syntax in this document.
A well-formed JSONPath query is valid if it also fulfills all semantic
requirements posed by this document.

To be valid, integer numbers in the JSONPath query that are relevant
to the JSONPath processing (e.g., index values and steps) MUST be
within the range of exact values defined in I-JSON {{-i-json}}, namely
within the interval \[-(2<sup>53</sup>)+1, (2<sup>53</sup>)-1]).

The well-formedness and the validity of JSONPath queries are independent of
the JSON value the query is applied to; no further errors can be
raised during application of the query to a value.

Obviously, an implementation can still fail when executing a JSONPath
query, e.g., because of resource depletion, but this is not modeled in
the present specification.  However, the implementation MUST NOT
silently malfunction.  Specifically, if a valid JSONPath query is
evaluated against a structured value whose size doesn't fit in the
range of exact values, interfering with the correct interpretation of
the query, the implementation MUST provide an indication of overflow.

(Readers familiar with the HTTP error model may be reminded of 400
type errors when pondering well-formedness and validity, while
resource depletion and related errors are comparable to 500 type
errors.)

## Processing Model

In this specification, the semantics of a JSONPath query are defined
in terms of a *processing model*.  That model is not prescriptive of
the internal workings of an implementation:  Implementations may wish
(or need) to design a different process that yields results that are
consistent with this model.

In the processing model,
a valid query is executed against a value, the *argument*, and
produces a list of zero or more nodes of the value.

The query is a sequence of zero or more *selectors*, each of
which is applied to the result of the previous selector and provides
input to the next selector.
These results and inputs take the form of a *nodelist*, i.e., a
sequence of zero or more nodes.

The nodelist going into the first selector contains a single node,
the argument.
The nodelist resulting from the last selector is presented as the
result of the query; depending on the specific API, it might be
presented as an array of the JSON values at the nodes, an array of
Output Paths referencing the nodes, or both — or some other
representation as desired by the implementation.
Note that the API must be capable of presenting an empty nodelist as
the result of the query.

A selector performs its function on each of the nodes in its input
nodelist, during such a function execution, such a node is referred to
as the "current node".  Each of these function executions produces a
nodelist, which are then concatenated into
the result of the selector.

The processing within a selector may execute nested queries,
which are in turn handled with the processing model defined here.
Typically, the argument to that query will be the current node of the
selector or a set of nodes subordinate to that current node.


## Syntax

Syntactically, a JSONPath query consists of a root selector (`$`), which
stands for a nodelist that contains the root node of the argument,
followed by a possibly empty sequence of *selectors*.

~~~~ abnf
json-path = root-selector *(S (dot-selector        /
                               dot-wild-selector   /
                               index-selector      /
                               index-wild-selector /
                               union-selector      /
                               slice-selector      /
                               descendant-selector /
                               filter-selector))
~~~~

The syntax and semantics of each selector is defined below.


## Semantics

The root selector `$` not only selects the root node of the argument,
but it also produces as output a list consisting of one
node: the argument itself.

A selector may select zero or more nodes for further processing.
A syntactically valid selector MUST NOT produce errors.
This means that some
operations which might be considered erroneous, such as indexing beyond the
end of an array,
simply result in fewer nodes being selected.

But a selector doesn't just act on a single node: a selector acts on
each of the nodes in its input nodelist and concatenates the resultant nodelists
to form the result nodelist of the selector.


For each node in the list, the selector selects zero or more nodes,
each of which is a descendant of the node or the node itself.

<!-- To do: Define "descendants" (making sure that member values are, but member names aren't). -->

For instance, with the argument `{"a":[{"b":0},{"b":1},{"c":2}]}`, the
query `$.a[*].b` selects the following list of nodes: `0`, `1`
(denoted here by their value).
Let's walk through this in detail.

The query consists of `$` followed by three selectors: `.a`, `[*]`, and `.b`.

Firstly, `$` selects the root node which is the argument.
So the result is a list consisting of just the root node.

Next, `.a` selects from any input node of type object and selects the
node of any
member value of the input
node corresponding to the member name `"a"`.
The result is again a list of one node: `[{"b":0},{"b":1},{"c":2}]`.

Next, `[*]` selects from an input node of type array all its elements
(if the input note were of type object, it would select all its member
values, but not the member names).
The result is a list of three nodes: `{"b":0}`, `{"b":1}`, and `{"c":2}`.

Finally, `.b` selects from any input node of type object with a member name
`b` and selects the node of the member value of the input node corresponding to that name.
The result is a list containing `0`, `1`.
This is the concatenation of three lists, two of length one containing
`0`, `1`, respectively, and one of length zero.

As a consequence of this approach, if any of the selectors selects no nodes,
then the whole query selects no nodes.

In what follows, the semantics of each selector are defined for each type
of node.


## Selectors

A JSONPath query consists of a sequence of selectors. Valid selectors are

  * Root selector `$` (used at the start of a query and in expressions)
  * Dot selector `.<name>`, used with object member names exclusively.
  * Dot wild card selector `.*`.
  * Index selector `[<index>]`, where `<index>` is either a (possibly
    negative, see {{index-semantics}}) array index or an object member name.
  * Index wild card selector `[*]`.
  * Array slice selector `[<start>:<end>:<step>]`, where the optional
    values `<start>`, `<end>`, and `<step>` are integer literals.
  * Nested descendants selector `..`.
  * Union selector `[<sel1>,<sel2>,...,<selN>]`, holding a comma delimited list of index, index wild card, array slice, and filter selectors.
  * Filter selector `[?(<expr>)]`
  * Current item selector `@` (used in expressions)

### Root Selector

#### Syntax
{: unnumbered}

Every valid JSONPath query MUST begin with the root selector `$`.

~~~~ abnf
root-selector  = "$"
~~~~

#### Semantics
{: unnumbered}

The Argument — the root JSON value — becomes the root node, which is
addressed by the root selector `$`.


### Dot Selector

#### Syntax
{: unnumbered}

A dot selector starts with a dot `.` followed by an object's member name.

~~~~ abnf
dot-selector    = "." dot-member-name
dot-member-name = name-first *name-char
name-first =
                      ALPHA /
                      "_"   /           ; _
                      %x80-10FFFF       ; any non-ASCII Unicode character
name-char = DIGIT / name-first

DIGIT           =  %x30-39              ; 0-9
ALPHA           =  %x41-5A / %x61-7A    ; A-Z / a-z
~~~~

Member names containing characters other than allowed by
`dot-selector` — such as space ` `, minus `-`, or dot `.`
characters — MUST NOT be used with the `dot-selector`.
(Such member names can be addressed by the
`index-selector` instead.)

#### Semantics
{: unnumbered}

The `dot-selector` selects the node of the member value corresponding
to the member name from any JSON object in its input nodelist. It selects no nodes from any other JSON value.

<!-- DELETEME Not true, as JSONPath queries are UTF-8 texts -->
Note that the `dot-selector` follows the philosophy of JSON strings and is
allowed to contain bit sequences that cannot encode Unicode characters (a
single unpaired UTF-16 surrogate, for example).
The behaviour of an implementation is undefined for member names which do
not encode Unicode characters.

### Dot Wild Card Selector {#wildcard}

#### Syntax
{: unnumbered}

The dot wild card selector has the form `.*` as defined in the
following syntax:

~~~~ abnf
dot-wild-selector    = "." "*"            ;  dot followed by asterisk
~~~~

#### Semantics
{: unnumbered}

A `dot-wild-selector` acts as a wild card by selecting the nodes of
all member values of an object in its input nodelist as well as all
element nodes of an array in its input nodelist.
Applying the `dot-wild-selector` to a primitive JSON value (number,
string, or true/false/null) selects no node.


### Index Selector

#### Syntax {#syntax-index}
{: unnumbered}

An index selector `[<index>]` addresses at most one object member value or at most one array element value.

~~~~ abnf
index-selector      = "[" S (quoted-member-name / element-index) S "]"
~~~~

Applying the `index-selector` to an object value in its input nodelist, a
`quoted-member-name` string is required to select the corresponding
member value.
In contrast to JSON,
the JSONPath syntax allows strings to be enclosed in _single_ or _double_ quotes.

~~~~ abnf
quoted-member-name  = string-literal

string-literal      = %x22 *double-quoted %x22 /       ; "string"
                      %x27 *single-quoted %x27         ; 'string'

double-quoted       = unescaped /
                      %x27      /                       ; '
                      ESC %x22  /                       ; \"
                      ESC escapable

single-quoted       = unescaped /
                      %x22      /                       ; "
                      ESC %x27  /                       ; \'
                      ESC escapable

ESC                 = %x5C                              ; \  backslash

unescaped           = %x20-21 /                         ; s. RFC 8259
                      %x23-26 /                         ; omit "
                      %x28-5B /                         ; omit '
                      %x5D-10FFFF                       ; omit \

escapable           = ( %x62 / %x66 / %x6E / %x72 / %x74 / ; \b \f \n \r \t
                          ; b /         ;  BS backspace U+0008
                          ; t /         ;  HT horizontal tab U+0009
                          ; n /         ;  LF line feed U+000A
                          ; f /         ;  FF form feed U+000C
                          ; r /         ;  CR carriage return U+000D
                          "/" /          ;  /  slash (solidus)
                          "\" /          ;  \  backslash (reverse solidus)
                          (%x75 hexchar) ;  uXXXX      U+XXXX
                      )

hexchar = non-surrogate / (high-surrogate "\" %x75 low-surrogate)
non-surrogate = ((DIGIT / "A"/"B"/"C" / "E"/"F") 3HEXDIG) /
                 ("D" %x30-37 2HEXDIG )
high-surrogate = "D" ("8"/"9"/"A"/"B") 2HEXDIG
low-surrogate = "D" ("C"/"D"/"E"/"F") 2HEXDIG

HEXDIG = DIGIT / "A" / "B" / "C" / "D" / "E" / "F"

; Task from 2021-06-15 interim: update ABNF later
~~~~

Applying the `index-selector` to an array, a numerical `element-index`
is required to select the corresponding
element. JSONPath allows it to be negative (see {{index-semantics}}).

~~~~ abnf
element-index   = int                             ; decimal integer

int             = ["-"] ( "0" / (DIGIT1 *DIGIT) ) ; -  optional
DIGIT1          = %x31-39                         ; 1-9 non-zero digit
~~~~

Notes:
1. `double-quoted` strings follow the JSON string syntax ({{Section 7 of RFC8259}});
   `single-quoted` strings follow an analogous pattern ({{syntax-index}}).
2. An `element-index` is an integer (in base 10, as in JSON numbers).
3. As in JSON numbers, the syntax does not allow octal-like integers with leading zeros such as `01` or `-01`.

#### Semantics {#index-semantics}
{: unnumbered}

A `quoted-member-name` string MUST be converted to a
member name by removing the surrounding quotes and
replacing each escape sequence with its equivalent Unicode character, as
in the table below:

| Escape Sequence    | Unicode Character   |  Description                |
| :----------------: | :-----------------: |:--------------------------- |
| \\b                | U+0008              | BS backspace                |
| \\t                | U+0009              | HT horizontal tab           |
| \\n                | U+000A              | LF line feed                |
| \\f                | U+000C              | FF form feed                |
| \\r                | U+000D              | CR carriage return          |
| \\"                | U+0022              | quotation mark              |
| \\'                | U+0027              | apostrophe                  |
| \\/                | U+002F              | slash (solidus)             |
| \\\\               | U+005C              | backslash (reverse solidus) |
| \\uXXXX            | U+XXXX              | unicode character           |
{: title="Escape Sequence Replacements" cols="c c"}

The `index-selector` applied with a `quoted-member-name` to an object
selects the node of the corresponding member value from it, if and only if that object has a member with that name.
Nothing is selected from a value which is not a object.

Array indexing via `element-index` is a way of selecting a particular array element using a zero-based index.
For example, selector `[0]` selects the first and selector `[4]` the fifth element of a sufficiently long array.

A negative `element-index` counts from the array end.
For example, selector `[-1]` selects the last and selector `[-2]` selects the penultimate element of an array with at least two elements.
As with non-negative indexes, it is not an error if such an element does
not exist; this simply means that no element is selected.


### Index Wild Card Selector

#### Syntax
{: unnumbered}

The index wild card selector has the form `[*]`.

~~~~ abnf
index-wild-selector    = "[" "*" "]"  ;  asterisk enclosed by brackets
~~~~

#### Semantics
{: unnumbered}

An `index-wild-selector`
selects the nodes of all member values of an object as well as of all elements of an
array.
Applying the `index-wild-selector` to a primitive JSON value (such as
a number, string, or true/false/null) selects no node.

The `index-wild-selector` behaves identically to the `dot-wild-selector`.

### Array Slice Selector {#slice}

#### Syntax
{: unnumbered}

The array slice selector has the form `[<start>:<end>:<step>]`.
It selects elements starting at index `<start>`, ending at — but
not including — `<end>`, while incrementing by `step`.

~~~~ abnf
slice-selector = "[" S [start S] ":" S [end S] [":" S [step S]] "]"

start          = int       ; included in selection
end            = int       ; not included in selection
step           = int       ; default: 1

B              =    %x20 / ; Space
                    %x09 / ; Horizontal tab
                    %x0A / ; Line feed or New line
                    %x0D   ; Carriage return
S              = *B        ; optional blank space
RS             = 1*B       ; required blank space

~~~~

The `slice-selector` consists of three optional decimal integers separated by colons.

#### Semantics
{: unnumbered}

The `slice-selector` was inspired by the slice operator of ECMAScript
4 (ES4), which was deprecated in 2014, and that of Python.


##### Informal Introduction
{: unnumbered}

This section is non-normative.

Array indexing is a way of selecting a particular element of an array using
a 0-based index.
For example, the expression `[0]` selects the first element of a non-empty array.

Negative indices index from the end of an array.
For example, the expression `[-2]` selects the last but one element of an array with at least two elements.

Array slicing is inspired by the behaviour of the `Array.prototype.slice` method
of the JavaScript language as defined by the ECMA-262 standard {{ECMA-262}},
with the addition of the `step` parameter, which is inspired by the Python slice expression.

The array slice expression `[start:end:step]` selects elements at indices starting at `start`,
incrementing by `step`, and ending with `end` (which is itself excluded).
So, for example, the expression `[1:3]` (where `step` defaults to `1`)
selects elements with indices `1` and `2` (in that order) whereas
`[1:5:2]` selects elements with indices `1` and `3`.

When `step` is negative, elements are selected in reverse order. Thus,
for example, `[5:1:-2]` selects elements with indices `5` and `3`, in
that order and `[::-1]` selects all the elements of an array in
reverse order.

When `step` is `0`, no elements are selected.
(This is the one case which differs from the behaviour of Python, which
raises an error in this case.)

The following section specifies the behaviour fully, without depending on
JavaScript or Python behaviour.

##### Detailed Semantics
{: unnumbered}

An array selector is either an array slice or an array index, which is defined
in terms of an array slice.

A slice expression selects a subset of the elements of the input array, in
the same order
as the array or the reverse order, depending on the sign of the `step` parameter.
It selects no nodes from a node which is not an array.

A slice is defined by the two slice parameters, `start` and `end`, and
an iteration delta, `step`.
Each of these parameters is
optional. `len` is the length of the input array.

The default value for `step` is `1`.
The default values for `start` and `end` depend on the sign of `step`,
as follows:

| Condition    | start   | end      |
|--------------|---------|----------|
| step >= 0    | 0       | len      |
| step < 0     | len - 1 | -len - 1 |
{: title="Default array slice start and end values"}

Slice expression parameters `start` and `end` are not directly usable
as slice bounds and must first be normalized.
Normalization for this purpose is defined as:

~~~~
FUNCTION Normalize(i, len):
  IF i >= 0 THEN
    RETURN i
  ELSE
    RETURN len + i
  END IF
~~~~

The result of the array indexing expression `[i]` applied to an array
of length `len` is defined to be the result of the array
slicing expression `[i:Normalize(i, len)+1:1]`.

Slice expression parameters `start` and `end` are used to derive slice bounds `lower` and `upper`.
The direction of the iteration, defined
by the sign of `step`, determines which of the parameters is the lower bound and which
is the upper bound:

~~~~
FUNCTION Bounds(start, end, step, len):
  n_start = Normalize(start, len)
  n_end = Normalize(end, len)

  IF step >= 0 THEN
    lower = MIN(MAX(n_start, 0), len)
    upper = MIN(MAX(n_end, 0), len)
  ELSE
    upper = MIN(MAX(n_start, -1), len-1)
    lower = MIN(MAX(n_end, -1), len-1)
  END IF

  RETURN (lower, upper)
~~~~

The slice expression selects elements with indices between the lower and
upper bounds.
In the following pseudocode, the `a(i)` construct expresses the
0-based indexing operation on the underlying array.

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

To be valid, the slice expression parameters MUST be in the I-JSON
range of exact values, see {{synsem-overview}}.

### Descendant Selector

#### Syntax
{: unnumbered}

The descendant selector starts with a double dot `..` and can be
followed by an object member name (similar to the `dot-selector`),
by an `index-selector` acting on objects or arrays, or by a wild card.

~~~~ abnf
descendant-selector = ".." ( dot-member-name      /  ; ..<name>
                             index-selector       /  ; ..[<index>]
                             index-wild-selector  /  ; ..[*]
                             "*"                     ; ..*
                           )
~~~~

#### Semantics
{: unnumbered}

The `descendant-selector` selects the node and all its descendants.

In the resultant nodelist:
* nodes occur before their children, and
* nodes of an array occur in array order.

Children of an object may occur in any order, since JSON objects are unordered.

### Union Selector

#### Syntax
{: unnumbered}

The union selector is syntactically related to the
`index-selector`.
It contains two or more entries, separated by commas.

~~~~ abnf
union-selector = "[" S union-entry 1*(S "," S union-entry) S "]"

union-entry    =  ( quoted-member-name /
                    element-index      /
                    slice-index
                  )
~~~~

#### Semantics
{: unnumbered}

A union selects any node which is selected by at least one of the union selectors and selects the concatenation of the
lists (in the order of the selectors) of nodes selected by the union elements.
Note that any node selected in more than one of the union selectors is kept
as many times in the node list.

To be valid, integer values in the `element-index` and `slice-index`
components MUST be in the I-JSON range of exact values, see
{{synsem-overview}}.


### Filter Selector

#### Syntax
{: unnumbered}

The filter selector has the form `[?<expr>]`. It works via iterating over structured values, i.e. arrays and objects.

~~~~ abnf
filter-selector    = "[" S "?" S boolean-expr S "]"
~~~~

During iteration process each array element or object member is visited and its value — accessible via symbol `@` — or one of its descendants — uniquely defined by a relative path — is tested against a boolean expression `boolean-expr`.

The current item is selected if and only if the result is `true`.


~~~~ abnf
boolean-expr     = logical-or-expr
logical-or-expr  = logical-and-expr *(S "||" S logical-and-expr)
                                                      ; disjunction
                                                      ; binds less tightly than conjunction
logical-and-expr = basic-expr *(S "&&" S basic-expr)  ; conjunction
                                                      ; binds more tightly than disjunction

basic-expr   = exist-expr /
               paren-expr /
               relation-expr
exist-expr   = [neg-op S] path                          ; path existence or non-existence
path         = rel-path / json-path
rel-path     = "@" *(S (dot-selector / index-selector))
paren-expr   = [neg-op S] "(" S boolean-expr S ")"    ; parenthesized expression
neg-op       = "!"                                    ; not operator

relation-expr = comp-expr /                           ; comparison test
                regex-expr                            ; regular expression test

comp-expr    = comparable S comp-op S comparable
comparable   = number / string-literal /              ; primitive ...
               true / false / null /                  ; values only
               path                                   ; path value
comp-op      = "==" / "!=" /                          ; comparison ...
               "<"  / ">"  /                          ; operators
               "<=" / ">="
true         = %x74.72.75.65                          ; true
false        = %x66.61.6c.73.65                       ; false
null         = %x6e.75.6c.6c                          ; null

regex-expr   = (path / string-literal) S regex-op S regex
regex-op     = "=~"                                   ; regular expression match
regex        = <TO BE DEFINED>
~~~~

Notes:

* Parentheses can be used with `boolean-expr` for grouping. So filter selection syntax in the original proposal `[?(<expr>)]` is naturally contained in the current lean syntax `[?<expr>]` as a special case.
* Comparisons are restricted to primitive values (such as number, string, `true`, `false`, `null`). Comparisons with complex values will fail, i.e. no selection occurs.
<!-- issue: comparison with structured value -->
* Types are not implicitly converted in comparisons.
  So `"13 == '13'"` selects no node.
* A member or element value by itself in a Boolean context is
  interpreted as `false` only if it does not exist.
  Otherwise it is interpreted as `true`.
  To be more specific about the actual value, explicit comparisons are necessary. This existence test — as an exception to the general rule — also works with structured values.
* Regular expression tests can be applied to `string` values only.

The following table lists filter expression operators in order of precedence from highest (binds most tightly) to lowest (binds least tightly).

<!-- FIXME: Should the syntax column be split between unary and binary operators? -->

| Precedence | Operator type | Syntax |
|:--:|:--:|:--:|
|  5  | Grouping | `(...)` |
|  4  | Logical NOT | `!` |
|  3  | Relations | `==`&nbsp;`!=`<br>`<`&nbsp;`<=`&nbsp;`>`&nbsp;`>=`<br>`=~`<br>` in ` |
|  2  | Logical AND | `&&` |
|  1  | Logical OR | `¦¦`   |
{: title="Filter expression operator precedence" }

#### Semantics
{: unnumbered}

The `filter-selector` works with arrays and objects exclusively. Its result might be a list of *zero*, *one*, *multiple* or *all* of their element or member values then. Applied to other value types, it will select nothing.

**FIXME**: The zero number/empty string exceptions are no longer true.  Booleans work the same everywhere.

Negation operator `neg-op` allows to test *falsiness* of values.

| Type |  Negation | Result | Comment |
|:----:|:---------:|:------:|:-------:|
| Number |  `!0`   | `true` | `false` for non-zero number  |
| String |  `!""`<br>`!''`  | `true` | `false` for non-empty string  |
| `null` |  `!null`| `true` | —  |
| `true` |  `!true`| `false`| —  |
| `false`| `!false`| `true` | —  |
| Object | `!{}`<br>`!{a:0}` | `false`| always `false` |
| Array | `![]`<br>`![0]` | `false`| always `false` |
{: title="Test falsiness of JSON values" }

Applying negation operator twice `!!` gives us *truthiness* of values.

Some examples:

| JSON |  Query | Result | Comment |
|:----|:---------:|:------:|:-------|
| `{"a":1,"b":2}`<br>`[2,3,4]` | `$[?@]` | `[1,2]`<br>`[2,3,4]` | Same as `$.*` or `$[*]`  |
| `./.` | `$[?@==2]` | `[2]`<br>`[2]` | Select by value.  |
| `{"a":{"b":{"c":{}}}` | `$[?@.b]`<br>`$[?@.b.c]` | `[{"b":{"c":{}}]` | Existence  |
| `{"key":false}` | `$[?index(@)=='key']`<br>`$[?index(@)==0]` | `[false]`<br>`[]` | Select object member |
| `[3,4,5]` | `$[?index(@)==2]`<br>`$[?index(@)==17]` | `[5]`<br>`[]` | Select array element |
| `{"a":{"b":{5},c:0}}` | `$[?@.b==5 && !@.c]` | `[{"b":{5},c:0}]` | Existence  |

# IANA Considerations {#IANA}

TBD: Define a media type for JSONPath expressions.

# Security Considerations {#Security}

This section gives security considerations, as required by {{RFC3552}}.



--- back

# Inspired by XPath

This appendix is informative.

At the time JSONPath was invented, XML was noted for the availability of
powerful tools to analyse, transform and selectively extract data from
XML documents.
{{XPath}} is one of these tools.

In 2007, the need for something solving the same class of problems for
the emerging JSON community became apparent, specifically for:

* Finding data interactively and extracting them out of {{-json}}
  JSON values without special scripting.
* Specifying the relevant parts of the JSON data in a request by a
  client, so the server can reduce the amount of data in its response,
  minimizing bandwidth usage.

(Note that XPath has evolved since 2007, and recent versions even
nominally support operating inside JSON values.
This appendix only discusses the more widely used version of XPath
that was available in 2007.)

JSONPath picks up the overall feeling of XPath, but maps the concepts
to syntax (and partially semantics) that would be familiar to someone
using JSON in a dynamic language.

E.g., in popular dynamic programming languages such as JavaScript,
Python and PHP, the semantics of the XPath expression

~~~~
/store/book[1]/title
~~~~

can be realized in the expression

~~~~
x.store.book[0].title
~~~~

or, in bracket notation,

~~~~
x['store']['book'][0]['title']
~~~~

with the variable x holding the argument.

The JSONPath language was designed to:

* be naturally based on those language characteristics;
* cover only the most essential parts of XPath 1.0;
* be lightweight in code size and memory consumption;
* be runtime efficient.

## JSONPath and XPath {#xpath-overview}

JSONPath expressions apply to JSON values in the same way
as XPath expressions are used in combination with an XML document.
JSONPath uses `$` to refer to the root node of the argument, similar
to XPath's `/` at the front.

JSONPath expressions move further down the hierarchy using *dot notation*
(`$.store.book[0].title`)
or the *bracket notation*
(`$['store']['book'][0]['title']`), a lightweight/limited, and a more
heavyweight syntax replacing XPath's `/` within query expressions.

Both JSONPath and XPath use `*` for a wildcard.
The descendant operator `..`, borrowed from {{E4X}}, is similar to XPath's `//`.
The array slicing construct `[start:end:step]` is unique to JSONPath,
inspired by {{SLICE}} from ECMASCRIPT 4.

Filter expressions are supported via the syntax `?(<boolean expr>)` as in

~~~~
$.store.book[?(@.price < 10)].title
~~~~

{{tbl-xpath-overview}} extends {{tbl-overview}} by providing a comparison
with similar XPath concepts.

| XPath | JSONPath           | Description                                                                                                                           |
|-------|--------------------|---------------------------------------------------------------------------------------------------------------------------------------|
| `/`   | `$`                | the root XML element                                                                                                                  |
| `.`   | `@`                | the current XML element                                                                                                               |
| `/`   | `.` or `[]`        | child operator                                                                                                                        |
| `..`  | n/a                | parent operator                                                                                                                       |
| `//`  | `..`               | nested descendants (JSONPath borrows this syntax from E4X)                                                                            |
| `*`   | `*`                | wildcard: All XML elements regardless of their names                                                                                  |
| `@`   | n/a                | attribute access: JSON values do not have attributes                                                                                  |
| `[]`  | `[]`               | subscript operator used to iterate over XML element collections and for predicates                                                    |
| `¦`   | `[,]`              | Union operator (results in a combination of node sets); JSONPath allows alternate names or array indices as a set                     |
| n/a   | `[start:end:step]` | array slice operator borrowed from ES4                                                                                                |
| `[]`  | `?()`              | applies a filter (script) expression                                                                                                  |
| seamless   | n/a                | expression engine                                                                                                                     |
| `()`  | n/a                | grouping                                                                                                                     |
{: #tbl-xpath-overview title="XPath syntax compared to JSONPath"}

<!-- note that the weirdness about the vertical bar above is intentional -->

For further illustration, {{tbl-xpath-equivalents}} shows some XPath expressions
and their JSONPath equivalents.

| XPath                  | JSONPath                                  | Result                                                       |
|------------------------|-------------------------------------------|--------------------------------------------------------------|
| `/store/book/author`   | `$.store.book[*].author`                  | the authors of all books in the store                        |
| `//author`             | `$..author`                               | all authors                                                  |
| `/store/*`             | `$.store.*`                               | all things in store, which are some books and a red bicycle  |
| `/store//price`        | `$.store..price`                          | the prices of everything in the store                        |
| `//book[3]`            | `$..book[2]`                              | the third book                                               |
| `//book[last()]`       | `$..book[(@.length-1)]`<br>`$..book[-1]`  | the last book in order                                       |
| `//book[position()<3]` | `$..book[0,1]`<br>`$..book[:2]`           | the first two books                                          |
| `//book[isbn]`         | `$..book[?(@.isbn)]`                      | filter all books with isbn number                            |
| `//book[price<10]`     | `$..book[?(@.price<10)]`                  | filter all books cheaper than 10                             |
| `//*`                  | `$..*`                                    | all elements in XML document; all member values and array elements contained in input value |
{: #tbl-xpath-equivalents title="Example XPath expressions and their JSONPath equivalents"}

XPath has a lot more functionality (location paths in unabbreviated syntax,
operators and functions) than listed in this comparison.  Moreover, there are
significant differences in how the subscript operator works in XPath and
JSONPath:

* Square brackets in XPath expressions always operate on the *node
  set* resulting from the previous path fragment. Indices always start
  at 1.
* With JSONPath, square brackets operate on the *object* or *array*
  addressed by the previous path fragment. Array indices always start
  at 0.

# Acknowledgements
{: numbered="no"}

This specification is based on <contact fullname="Stefan Gössner"/>'s
original online article defining JSONPath {{JSONPath-orig}}.

The books example was taken from
http://coli.lili.uni-bielefeld.de/~andreas/Seminare/sommer02/books.xml
— a dead link now.

<!--  LocalWords:  JSONPath XPath nodelist
 -->
