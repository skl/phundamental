#!/bin/bash

# 0 = PASS
# 1 = FAIL
PH_TEST_FAILURE=0

# Run syntax check
for i in plz install uninstall `find . -name "*.sh"`; do
    bash -n ${i} && echo "SYNTAX OK: ${i}" || PH_TEST_FAILURE=1
done

exit ${PH_TEST_FAILURE}
