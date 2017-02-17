#!/bin/bash
for f in tests/*.min
do
  echo -e "$f"\\n
  ./lexer "$f"
  echo
done
