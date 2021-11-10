Here are the installation instructions from the old README, for posterity.

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

```
xml2rfc ./draft-ietf-jsonpath-base.xml --text --html && aex draft-ietf-jsonpath-base.txt | bap -S path -q
```

A script [gen.sh](scripts/gen.sh) is provided for convenience. You can also use [docker-gen.sh](scripts/docker-gen.sh)
version that installs and runs all utilities within a Docker container.
