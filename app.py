import requests
import gradio as gr
import tempfile
import os
from transformers import pipeline
from huggingface_hub import InferenceClient
import time
import psutil
# import torch
# import numpy as np

# Ensure CUDA is available and set device accordingly
# device = 0 if torch.cuda.is_available() else -1

model_id = "openai/whisper-large-v3"
client = InferenceClient(model_id)
pipe = pipeline("automatic-speech-recognition", model=model_id) #, device=device)

def transcribe(inputs, use_api):
    start = time.time()
    API_STATUS = ''
    
    memory_before = psutil.Process(os.getpid()).memory_info().rss

    if inputs is None:
        raise gr.Error("No audio file submitted! Please upload or record an audio file before submitting your request.")

    try:
        if use_api:
            print(f'Using API for transcription...')
            API_STATUS = 'Using API it took: '
            # Use InferenceClient (API) if checkbox is checked
            res = client.automatic_speech_recognition(inputs).text
        else:
            print(f'Using local pipeline for transcription...')
            # Use local pipeline if checkbox is unchecked
            API_STATUS = 'Using local pipeline it took: '
            res = pipe(inputs, chunk_length_s=30)["text"]
        
        end = time.time() - start

        # Measure memory after running the transcription process
        memory_after = psutil.Process(os.getpid()).memory_info().rss
        
        # Calculate the difference to see how much memory was used by the code
        memory_used = memory_after - memory_before  # Memory used in bytes
        memory_used_gb = round(memory_used / (1024 ** 3), 2)  # Convert memory used to GB
        total_memory_gb = round(psutil.virtual_memory().total / (1024 ** 3), 2)  # Total RAM in GB

        # Calculate the percentage of RAM used by this process
        memory_used_percent = round((memory_used / psutil.virtual_memory().total) * 100, 2)
        
        return res, API_STATUS + str(round(end, 2)) + ' seconds', f"RAM Used by code: {memory_used_gb} GB ({memory_used_percent}%) Total RAM: {total_memory_gb}"
    
    
    except Exception as e:
        return fr'Error: {str(e)}', None

demo = gr.Blocks()

mf_transcribe = gr.Interface(
                fn=transcribe,
                inputs=[
                    gr.Audio(sources="microphone", type="filepath"),
                    # gr.Radio(["transcribe", "translate"], label="Task", value="transcribe"),
                    gr.Checkbox(label="Use API", value=False)
                ],
                outputs=[gr.Textbox(label="Transcribed Text", type="text"),
                         gr.Textbox(label="Time taken", type="text"),
                         gr.Textbox(label="Utilization", type="text") 
                        ],  # Placeholder for transcribed text and time taken
                title="Welcome to QuickTranscribe",
                description=(
                    "Transcribe long-form microphone or audio inputs with the click of a button!"
                ),
                allow_flagging="never",
            )

file_transcribe = gr.Interface(
                fn=transcribe,
                inputs=[
                    gr.Audio(sources="upload", type="filepath", label="Audio file"),
                    # gr.Radio(["transcribe", "translate"], label="Task", value="transcribe"),
                    gr.Checkbox(label="Use API", value=False)  # Checkbox for API usage
                ],
                outputs=[ gr.Textbox(label="Transcribed Text", type="text"),
                         gr.Textbox(label="Time taken", type="text"),
                         gr.Textbox(label="Utilization", type="text") 
                        ],  # Placeholder for transcribed text and time taken
                title="Welcome to QuickTranscribe",
                description=(
                    "Transcribe long-form microphone or audio inputs with the click of a button!"
                ),
                allow_flagging="never",
            )

with demo:
    with gr.Row():
    # with gr.Column():
        # Group the tabs for microphone and file-based transcriptions
        tab = gr.TabbedInterface([mf_transcribe, file_transcribe], ["Microphone", "Audio file"])

        # with gr.Column():
        #     use_api_checkbox = gr.Checkbox(label="Use API", value=False)  # Checkbox outside
        #     # time_taken = gr.Textbox(label="Time taken", type="text")  # Time taken outside the interfaces

if __name__ == "__main__":
    demo.queue().launch()