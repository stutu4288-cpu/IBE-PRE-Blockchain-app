#!/bin/sh
# Railway Catalina Wrapper Script for Python Application
echo "Starting Enterprise Python Proxy Re-Encryption Platform..."
if [ -f "app.py" ]; then
    exec python -u app.py "$@"
elif [ -f "python_pre_app/app.py" ]; then
    cd python_pre_app && exec python -u app.py "$@"
else
    exec python -u app.py "$@"
fi
