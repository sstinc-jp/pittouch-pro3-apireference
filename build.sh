#!/bin/bash -ue

rm -rf docs

mkdocs build

NAME=pro3_api_reference_$(date +%y-%m-%d)_$(git rev-parse --short HEAD | head -c 6).zip
rm -rf release/"$NAME"
zip -r release/"$NAME" site
