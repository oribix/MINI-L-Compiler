#!/bin/bash
for f in *.min
do
  echo -e "$f"\\n
  ./a.out "$f"
  echo
done
