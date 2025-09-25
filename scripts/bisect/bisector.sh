#!/bin/bash

# Clang/icx bisect script to find failing pass using opt-bisect-limit
# Usage: ./bisector.sh <compile_script> <fail_test_script>
#   compile_script: script that compiles with -mllvm -opt-bisect-limit=X
#   fail_test_script: script that returns 0 if compilation/test passes, non-zero if fails

set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 <compile_script> <fail_test_script>"
    echo "  compile_script: script that accepts -mllvm -opt-bisect-limit=X as argument"
    echo "  fail_test_script: script that tests if compilation succeeded (exit 0) or failed (exit 1)"
    exit 0
fi

COMPILE_SCRIPT="$1"
FAIL_TEST_SCRIPT="$2"

# Step 1: Find the upper bound by running with unlimited passes
echo "Finding upper bound..."
if ! $COMPILE_SCRIPT "-mllvm -opt-bisect-limit=-1" > bisect_output.log 2>&1; then
    echo "ERROR: Initial compilation with unlimited passes failed"
    exit 0
fi

# Extract the last pass number from the output
UPPER_BOUND=$(grep "BISECT: running pass" bisect_output.log | tail -1 | sed 's/.*(\([0-9]*\)).*/\1/')

if [ -z "$UPPER_BOUND" ]; then
    echo "ERROR: Could not find pass numbers in output"
    exit 0
fi

echo "Found upper bound: $UPPER_BOUND"

# Step 2: Verify that upper bound fails the test
echo "Verifying upper bound fails..."
$COMPILE_SCRIPT "-mllvm -opt-bisect-limit=$UPPER_BOUND" > /dev/null 2>&1
if $FAIL_TEST_SCRIPT; then
    echo "ERROR: Upper bound should fail but passed the test"
    exit 0
fi

# Step 3: Find lower bound where test still passes
LOWER_BOUND=0
echo "Finding lower bound where test passes..."

# Check if pass 0 already fails
$COMPILE_SCRIPT "-mllvm -opt-bisect-limit=0" > /dev/null 2>&1
if ! $FAIL_TEST_SCRIPT; then
    echo "ERROR: Even with no passes, the test fails"
    exit 0
fi

echo "Starting binary search between $LOWER_BOUND and $UPPER_BOUND"

# Step 4: Binary search to find the exact failing pass
while [ $((UPPER_BOUND - LOWER_BOUND)) -gt 1 ]; do
    MIDDLE=$(( (LOWER_BOUND + UPPER_BOUND) / 2 ))
    echo "Testing pass limit: $MIDDLE (range: $LOWER_BOUND - $UPPER_BOUND)"
    
    # Compile with middle pass limit
    if $COMPILE_SCRIPT "-mllvm -opt-bisect-limit=$MIDDLE" > /dev/null 2>&1; then
        # Compilation succeeded, run the fail test
        if $FAIL_TEST_SCRIPT; then
            # Test passed, so failure is in upper half
            LOWER_BOUND=$MIDDLE
            echo "  Test PASSED at $MIDDLE, searching upper half"
        else
            # Test failed, so failure is in lower half or at this point
            UPPER_BOUND=$MIDDLE
            echo "  Test FAILED at $MIDDLE, searching lower half"
        fi
    else
        # Compilation failed, so failure is in lower half or at this point
        UPPER_BOUND=$MIDDLE
        echo "  Compilation FAILED at $MIDDLE, searching lower half"
    fi
done

# Step 5: Report results
echo ""
echo "BISECT COMPLETE:"
echo "Last passing pass limit: $LOWER_BOUND"
echo "First failing pass limit: $UPPER_BOUND"

# Get the actual pass information for the failing limit
echo ""
echo "Failing pass details:"
$COMPILE_SCRIPT "-mllvm -opt-bisect-limit=$UPPER_BOUND" > failing_pass.log 2>&1 || true
FAILING_PASS_INFO=$(grep "BISECT: running pass ($UPPER_BOUND)" failing_pass.log || echo "Pass info not found")
echo "$FAILING_PASS_INFO"

# Generate final verification
echo ""
echo "Verification:"
echo "Running with limit $LOWER_BOUND (should pass):"
$COMPILE_SCRIPT "-mllvm -opt-bisect-limit=$LOWER_BOUND" > /dev/null 2>&1
if $FAIL_TEST_SCRIPT; then
    echo "  ✓ PASSED as expected"
else
    echo "  ✗ FAILED unexpectedly"
fi

echo "Running with limit $UPPER_BOUND (should fail):"
$COMPILE_SCRIPT "-mllvm -opt-bisect-limit=$UPPER_BOUND" > /dev/null 2>&1
if $FAIL_TEST_SCRIPT; then
    echo "  ✗ PASSED unexpectedly"
else
    echo "  ✓ FAILED as expected"
fi

echo ""
echo "The problematic pass is likely pass number $UPPER_BOUND"

