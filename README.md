# JSONPath Internet Draft Development

This repository is for the development of an Internet Draft for JSONPath. The draft is currently a work in progress.

See the latest rendered version of the draft [here](https://ietf-wg-jsonpath.github.io/draft-ietf-jsonpath-jsonpath/).

Christoph Burgmer's [JSONPath Comparison project](https://github.com/cburgmer/json-path-comparison)
publishes a [comparison](https://cburgmer.github.io/json-path-comparison/) of many existing
implementations of JSONPath, calculates a consensus on various features, and proposes at least one
implementation which will inform the Internet Draft.

## Community

All official discussion is on the [jsonpath@ietf.org mailing list](https://www.ietf.org/mailman/listinfo/jsonpath).
See the [archive](https://mailarchive.ietf.org/arch/browse/jsonpath/) for previous posts.

## License

See the draft for the copyright which is repeated in [LICENSE](./LICENSE).

## Authoring

The source of the Internet Draft is in markdown and corresponding `.xml`, `.txt`, and `.html` files are generated and checked in.

So that the HTML version can be viewed via github pages, it is copied to `docs/index.html`.

See [RFC 7991](https://tools.ietf.org/html/rfc7991) for rfc XML syntax information.

The XML document was created from this [template](https://tools.ietf.org/tools/templates/draft-davies-template-bare-07.xml).

In the markdown file, the convention is to start a new line when starting a new sentence.

### Install [kramdown-rfc2629](https://github.com/cabo/kramdown-rfc2629)
```
gem install kramdown-rfc2629
```
You may need to prefix the above command with `sudo` if it doesn't have sufficient permissions to complete the installation.

### Install [xml2rfc](https://xml2rfc.tools.ietf.org/):
```
pip3 install xml2rfc --user
```
This will place the executable in `~/.local/bin`

### Install [xmlstarlet](http://xmlstar.sourceforge.net/)
On macOS, issue:
```
brew install xmlstarlet
```
On Linux, issue something like:
```
apt-get install -y xmlstarlet
```

### Install `aex` and `bap`

`aex` is an ABNF extractor and `bap` an ABNF syntax checker.

1. Clone https://github.com/fenner/bap
2. In the cloned directory execute
   1. `./configure`
   2. `make`
3. `aex` and `bap` binaries should now exist in the directory
4. Add them to your path

### Re-generate files

 This will:
 - re-generate the `.txt` and `.html` files
 - check the ABNF syntax
 - copy the HTML file for use by github pages:

```
xml2rfc ./draft-ietf-jsonpath-base.xml --text --html && aex draft-ietf-jsonpath-base.txt | bap -S path -q && cp draft-ietf-jsonpath-base.html docs/index.html
```

A script [gen.sh](scripts/gen.sh) is provided for convenience. You can also use [docker-gen.sh](scripts/docker-gen.sh)
version that installs and runs all utilities within a Docker container.

### Conventions

Basic conventions around source files formatting are captured in the `.editorconfig` file.
Many editors support that file natively. Others (such as VS code) require a plugin, see https://editorconfig.org/.

### Pull Requests

For ease of reading pull requests, push the PR branch to `master` of your fork. For instance, if your
github username/organisation is `xxx`, then rendered HTML will be available at:

```
https://xxx.github.io/draft-ietf-jsonpath-jsonpath/
```
