---
title: Case Study1
emoji: 🦀
colorFrom: purple
colorTo: blue
sdk: gradio
sdk_version: 4.44.0
app_file: app.py
pinned: false
---

Check out the configuration reference at https://huggingface.co/docs/hub/spaces-config-reference

# QuickTranscribe

This is a Python-based web application that allows users to upload audio files or use a microphone to transcribe audio into text using Automatic Speech Recognition (ASR). The app also provides additional details like RAM utilization during the transcription process. It uses the **"openai/whisper-large-v3"** model from Hugging Face for transcription.

## Features

- **Microphone and File Upload Support**: Users can transcribe audio from either a microphone or an uploaded audio file.
- **Local and API-based Transcription**: Option to use a local model or an API for transcription.
- **RAM Utilization Display**: Shows how much RAM was utilized during the transcription process.
- **Real-time Speech-to-Text Transcription**: Converts audio to text in real-time with time-tracking.
- **Model Used**: The application uses the **"openai/whisper-large-v3"** model for transcription, which is part of Hugging Face's library.

## Installation

### Prerequisites

- Python 3.x
- `psutil` library for RAM usage tracking
- `gradio` for the web interface
- `transformers` library for the ASR pipeline
- `huggingface_hub` for API access

You can install the required dependencies using pip:

```bash
pip install psutil gradio transformers huggingface_hub
```

### Clone the repository

```bash
git clone https://github.com/VenkateshRoshan/MLOPs-CaseStudy1.git
cd MLOPs-CaseStudy1
```

## Usage

### Running the Application

To start the application, run the following command:

```bash
python app.py
```

This will launch a Gradio interface where you can choose to transcribe either using an uploaded audio file or the microphone input.

### Options

- **Microphone Input**: Click on the "Microphone" tab to start recording and transcribe the audio.
- **Audio File Upload**: Use the "Audio File" tab to upload an audio file for transcription.
- **Use API**: Check the "Use API" checkbox if you want to use the Hugging Face API for transcription instead of the local pipeline.

### Output

- **Transcribed Text**: The text transcribed from the uploaded or recorded audio will be displayed.
- **Time Taken**: The time taken for the transcription process is displayed.
- **RAM Utilization**: A text box shows the RAM usage details, including the amount of RAM used and the percentage of the total system RAM during the transcription process.

## Example Output

Here’s an example of the displayed output:

- **Transcribed Text**: "This is an example transcription."
- **Time Taken**: "Using API it took: 12.34 seconds"
- **RAM Utilization**: "RAM Used: 0.56 GB (3.45%), Total RAM: 16.0 GB"

## Future Enhancements

- **GPU Integration**: To address performance issues with CPU processing, integrating the product with Hugging Face’s GPU instances could significantly speed up transcription times, especially for longer audio files or real-time applications. Offering GPU as an option would provide a faster, more scalable solution for users who need high-speed transcription services.
- **Batch Processing and Caching**: Implementing batch processing or caching for repeated tasks (such as transcribing the same file multiple times) could reduce resource usage and improve performance. By grouping multiple audio files or requests together, the product could optimize processing times and reduce wait times for users.
- **Enhanced User Interface Features**: The user experience could be further enhanced by adding features like audio segmentation (to break up long audio files into smaller parts) and progress indicators during transcription. This would improve the usability of the product, especially for users transcribing lengthy recordings.
