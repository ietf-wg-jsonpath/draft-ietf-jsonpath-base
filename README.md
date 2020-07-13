# JSONPath Internet Draft Development

This repository is for the development of an Internet Draft for JSONPath. The draft is currently a work in progress.

See the latest rendered version of the draft [here](https://jsonpath-standard.github.io/internet-draft/).

Christoph Burgmer's [JSONPath Comparison project](https://github.com/cburgmer/json-path-comparison) 
publishes a [comparison](https://cburgmer.github.io/json-path-comparison/) of many existing
implementations of JSONPath, calculates a consensus on various features, and proposes at least one
implementation which will inform the Internet Draft.

## Community

Informal discussions happen in slack. If you would like to join in, here is an
[invitation](https://join.slack.com/t/jsonpath-standard/shared_invite/zt-fp521hp0-D7gmDcmOMK4UkrRRug~SQQ).

## License

See the draft for the copyright which is repeated in [LICENSE](./LICENSE).

## Authoring

The source of the Internet Draft is in XML and corresponding `.txt` and `.html` files are generated and checked in.

So that the HTML version can be viewed via github pages, it is copied to `docs/index.html`.

See [RFC 7749](https://tools.ietf.org/html/rfc7749) for rfc XML syntax information.

The XML document was created from this [template](https://tools.ietf.org/tools/templates/draft-davies-template-bare-07.xml).

### Install [xml2rfc](https://xml2rfc.tools.ietf.org/):
```
pip3 install xml2rfc --user
```
This will place the executable in `~/.local/bin`

### Install the `aex` and `bap`

`aex` is an ABNF extractor and `bap` an ABNF syntax checker

1. Clone https://github.com/fenner/bap
2. In the cloned directory execute 
   1. `./configure`
   2. `make`
3. `aex` and `bap` binaries should now exist in the directory

### Re-generate files

 This will:
 - re-generate the `.txt` and `.html` files
 - check the ABNF syntax 
 - copy the HTML file for use by github pages:

```
xml2rfc ./draft-normington-jsonpath-latest.xml --text --html && aex draft-normington-jsonpath-latest.txt | bap -S path -q && cp draft-normington-jsonpath-latest.html docs/index.html
```
