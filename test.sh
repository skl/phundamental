#!/bin/bash
for i in `find . -name "*.sh"`; do bash -n ${i} && echo "SYNTAX OK: ${i}"; done
