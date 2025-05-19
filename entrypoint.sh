#!/bin/bash
set -e

# Ensure instance folder exists
mkdir -p instance

# Initialize the database if not already present
if [ ! -f "instance/flaskr.sqlite" ]; then
    echo "Initializing the database..."
    flask --app flaskr init-db
else
    echo "Database already exists."
fi

# Start the Flask server
exec flask run --host=0.0.0.0 --port=5000
