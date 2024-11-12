# Use the official Python image as the base
FROM python:3.10-slim

# Set environment variables for Poetry
ENV POETRY_VERSION=1.8.4 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_CREATE=false \
    POETRY_NO_INTERACTION=1

# Install dependencies needed for Poetry and building packages
RUN apt-get update && apt-get install -y curl build-essential && \
    rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -

# Add Poetry to PATH
ENV PATH="$POETRY_HOME/bin:$PATH"

# Set the working directory
WORKDIR /app

# Copy only the necessary files for Poetry to install dependencies
COPY poetry.lock pyproject.toml /app/

# Install dependencies
RUN poetry install --no-root --no-dev  # Use --no-dev if you want to skip dev dependencies for production

# Copy the rest of the application code
COPY . /app

# Run the application
CMD ["python", "/app/crawler_chrome/app.py"]  # Change to your actual entry point
