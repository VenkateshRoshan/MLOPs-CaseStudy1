# import gradio as gr
# from transformers import pipeline, AutoModelForImageSegmentation 
# from gradio_imageslider import ImageSlider
# import torch
# from torchvision import transforms
# import spaces
# from PIL import Image

# import numpy as np
# import time

# birefnet = AutoModelForImageSegmentation.from_pretrained(
#     "ZhengPeng7/BiRefNet", trust_remote_code=True
# )
# device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# print("Using device:", device)

# birefnet.to(device)
# transform_image = transforms.Compose(
#     [
#         transforms.Resize((1024, 1024)),
#         transforms.ToTensor(),
#         transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
#     ]
# )

# # @spaces.GPU
# # def PreProcess(image):
# #     size = image.size
# #     image = transform_image(image).unsqueeze(0).to(device)

# #     with torch.no_grad():
# #         preds = birefnet(image)[-1].sigmoid().cpu()
# #     pred = preds[0].squeeze()
# #     pred = transforms.ToPILImage()(pred)
# #     mask = pred.resize(size)
# #     # image.putalpha(mask)
# #     return image

# @spaces.GPU
# def PreProcess(image):
#     size = image.size  # Save original size
#     image_tensor = transform_image(image).unsqueeze(0).to(device)  # Transform the image into a tensor

#     with torch.no_grad():
#         preds = birefnet(image_tensor)[-1].sigmoid().cpu()  # Get predictions
#     pred = preds[0].squeeze()

#     # Convert the prediction tensor to a PIL image
#     pred_pil = transforms.ToPILImage()(pred)

#     # Resize the mask to match the original image size
#     mask = pred_pil.resize(size)

#     # Convert the original image (passed as input) to a PIL image
#     image_pil = image.convert("RGBA")  # Ensure the image has an alpha channel

#     # Apply the alpha mask to the image
#     image_pil.putalpha(mask)

#     return image_pil

# def segment_image(image):
#     start = time.time()
#     image = Image.fromarray(image)
#     image = image.convert("RGB")
#     org = image.copy()
#     image = PreProcess(image)
#     time_taken = np.round((time.time() - start),2)
#     return (image, org), time_taken

# slider = ImageSlider(label='birefnet', type="pil")
# image = gr.Image(label="Upload an Image")

# butterfly = Image.open("butterfly.png")
# Dog = Image.open('Dog.jpg')

# time_taken = gr.Textbox(label="Time taken", type="text")

# demo = gr.Interface(
#     segment_image, inputs=image, outputs=[slider,time_taken], examples=[butterfly,Dog], api_name="BiRefNet")

# if __name__ == '__main__' :
#     demo.launch()

# import requests
# import gradio as gr
# import tempfile
# import os
# from transformers import pipeline
# from huggingface_hub import InferenceClient
# import time
# import torch

# device = "cuda" if torch.cuda.is_available() else "cpu"


# model_id = "openai/whisper-large-v3"
# client = InferenceClient(model_id)
# pipe = pipeline("automatic-speech-recognition", model=model_id, device=device)

# # def transcribe(inputs, task):
# #     if inputs is None:
# #         raise gr.Error("No audio file submitted! Please upload or record an audio file before submitting your request.")

# #     text = pipe(inputs, chunk_length_s=30)["text"]
# #     return text

# def transcribe(inputs, task):
#     start = time.time()
#     if inputs is None:
#         raise gr.Error("No audio file submitted! Please upload or record an audio file before submitting your request.")

#     try:
  
#         res = client.automatic_speech_recognition(inputs).text
#         end = time.time() - start
#         return res, end
    
#     except Exception as e:
#         return fr'Error: {str(e)}'
        

# demo = gr.Blocks()

# time_taken = gr.Textbox(label="Time taken", type="text")

# mf_transcribe = gr.Interface(
#     fn=transcribe,
#     inputs=[
#         gr.Audio(sources="microphone", type="filepath"),
#         gr.Radio(["transcribe", "translate"], label="Task", value="transcribe"),
#     ],
#     outputs=["text", time_taken],
#     title="Whisper Large V3: Transcribe Audio",
#     description=(
#         "Transcribe long-form microphone or audio inputs with the click of a button!"
#     ),
#     allow_flagging="never",
# )

# file_transcribe = gr.Interface(
#     fn=transcribe,
#     inputs=[
#         gr.Audio(sources="upload", type="filepath", label="Audio file"),
#         gr.Radio(["transcribe", "translate"], label="Task", value="transcribe"),
#     ],
#     outputs=["text", time_taken],
#     title="Whisper Large V3: Transcribe Audio",
#     description=(
#         "Transcribe long-form microphone or audio inputs with the click of a button!"
#     ),
#     allow_flagging="never",
# )



# with demo:
#     gr.TabbedInterface([mf_transcribe, file_transcribe], ["Microphone", "Audio file"])

# if __name__ == "__main__":
#     demo.queue().launch()

import requests
import gradio as gr
import tempfile
import os
from transformers import pipeline
from huggingface_hub import InferenceClient
import time
import torch

# Ensure CUDA is available and set device accordingly
# device = 0 if torch.cuda.is_available() else -1

model_id = "openai/whisper-large-v3"
client = InferenceClient(model_id)
pipe = pipeline("automatic-speech-recognition", model=model_id) #, device=device)

def transcribe(inputs, task, use_api):
    start = time.time()
    if inputs is None:
        raise gr.Error("No audio file submitted! Please upload or record an audio file before submitting your request.")

    try:
        if use_api:
            # Use InferenceClient (API) if checkbox is checked
            res = client.automatic_speech_recognition(inputs).text
        else:
            # Use local pipeline if checkbox is unchecked
            res = pipe(inputs, chunk_length_s=30)["text"]
        
        end = time.time() - start
        return res, end
    
    except Exception as e:
        return fr'Error: {str(e)}', None

demo = gr.Blocks()

mf_transcribe = gr.Interface(
                fn=transcribe,
                inputs=[
                    gr.Audio(sources="microphone", type="filepath"),
                    gr.Radio(["transcribe", "translate"], label="Task", value="transcribe"),
                ],
                outputs=["text", "text"],  # Placeholder for transcribed text and time taken
                title="Whisper Large V3: Transcribe Audio",
                description=(
                    "Transcribe long-form microphone or audio inputs with the click of a button!"
                ),
                allow_flagging="never",
            )

file_transcribe = gr.Interface(
                fn=transcribe,
                inputs=[
                    gr.Audio(sources="upload", type="filepath", label="Audio file"),
                    gr.Radio(["transcribe", "translate"], label="Task", value="transcribe"),
                ],
                outputs=["text", "text"],  # Placeholder for transcribed text and time taken
                title="Whisper Large V3: Transcribe Audio",
                description=(
                    "Transcribe long-form microphone or audio inputs with the click of a button!"
                ),
                allow_flagging="never",
            )

with demo:
    with gr.Row():
    # with gr.Column():
        # Group the tabs for microphone and file-based transcriptions
        gr.TabbedInterface([mf_transcribe, file_transcribe], ["Microphone", "Audio file"])

        with gr.Column():
            use_api_checkbox = gr.Checkbox(label="Use API", value=False)  # Checkbox outside
            time_taken = gr.Textbox(label="Time taken", type="text")  # Time taken outside the interfaces


if __name__ == "__main__":
    demo.queue().launch()
