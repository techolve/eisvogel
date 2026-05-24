#!/bin/bash
# ローカルビルド用（dist/eisvogel.latex が必要）
pandoc "document.md" \
  -o "document.pdf" \
  --from markdown \
  --template "../../dist/eisvogel.latex" \
  --pdf-engine xelatex \
  --syntax-highlighting idiomatic
