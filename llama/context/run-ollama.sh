#!/usr/bin/env bash

ollama serve &
echo "Waiting for Ollama server to be active..."
while [ "$(ollama list | grep 'NAME')" == "" ]; do
  sleep 1
done
ollama pull llama3
