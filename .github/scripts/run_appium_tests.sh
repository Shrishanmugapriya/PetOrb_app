#!/usr/bin/env bash
set -e

echo "=== Android AVD initialized successfully ==="
python -m pip install --upgrade pip
if [ -f appium_test_suite/requirements.txt ]; then
  pip install -r appium_test_suite/requirements.txt
fi
if [ -f appium_test_suite/run_tests.py ]; then
  python appium_test_suite/run_tests.py
fi
