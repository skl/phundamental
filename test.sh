#!/bin/bash

# 0 = PASS
# 1 = FAIL
PH_TEST_FAILURE=0

# Run syntax check
bash -n plz && echo "SYNTAX OK: ./plz" || PH_TEST_FAILURE=1

for i in `find . -name "*.sh"`; do
    bash -n ${i} && echo "SYNTAX OK: ${i}" || PH_TEST_FAILURE=1
done

exit ${PH_TEST_FAILURE}
