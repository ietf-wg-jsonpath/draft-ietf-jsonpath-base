LANG=C
export LANG

xmlstarlet sel -T -t -v '//sourcecode[@type="abnf"]' ./draft-ietf-jsonpath-base.xml 2>/dev/null \
| tee draft-ietf-jsonpath-base-orig.abnf \
| aex \
| tee draft-ietf-jsonpath-base.abnf \
| bap -S path
