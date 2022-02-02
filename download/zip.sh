#!/bin/zsh

## zip artifacts
cp src/main/js/index.js .
cp src/main/js/idl.json .
zip -r function.zip index.js idl.json node_modules
rm index.js
rm idl.json
