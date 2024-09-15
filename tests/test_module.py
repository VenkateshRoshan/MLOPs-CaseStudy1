import pytest
import os
import sys
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from unittest.mock import patch
from app import transcribe

# Add the root directory to the Python path so we can import app.py
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

# Test to check if necessary libraries are installed
def test_libraries_installed():
    try:
        import requests
        import gradio as gr
        import transformers
        import time
        import os
        import tempfile
        from huggingface_hub import InferenceClient
    except ImportError as e:
        pytest.fail(f"Library not installed: {e}")

# Define a constant for the audio file to be used in tests
AUDIO_FILE = "tests/sample.wav"

# Fixture to check if the audio file exists
@pytest.fixture
def check_audio_file():
    print(f"Checking if audio file {AUDIO_FILE} exists...")
    assert os.path.exists(AUDIO_FILE), f"Audio file {AUDIO_FILE} does not exist."
    return AUDIO_FILE

# Need to login Hugging Face account to use the API
# # Test the transcribe function using the API
# @patch('app.InferenceClient')  # Mock the InferenceClient to simulate API response
# def test_transcribe_api(mock_client, check_audio_file):
#     # Mocking the return value of the API call
#     mock_client.return_value.automatic_speech_recognition.return_value.text = "This is a test transcription."
    
#     # Call the transcribe function with the mock and use_api=True
#     result, time_taken = transcribe(check_audio_file, use_api=True)
    
#     # Assert the mocked transcription matches the expected result
#     assert result == "This is a test transcription."
#     assert time_taken.startswith('Using API it took: ')

# Test the transcribe function using the local pipeline (when use_api=False)
@patch('app.pipeline')  # Mock the local pipeline function
def test_transcribe_local(mock_pipeline, check_audio_file):
    # Mocking the local transcription
    mock_pipeline.return_value.return_value['text'] = "Now go away or I shall taunt you a second time!"
    
    # Call the transcribe function with the mock and use_api=False
    result, time_taken, memory_usage = transcribe(check_audio_file, use_api=False)
    print(result)
    # Now you can add assertions for each of these values
    assert str(result).strip() == "Now go away or I shall taunt you a second time!"
    assert "Using local pipeline" in time_taken
    assert "RAM Used by code" in memory_usage

