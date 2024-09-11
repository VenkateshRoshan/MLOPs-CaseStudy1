import gradio as gr
from transformers import pipeline, AutoModelForImageSegmentation 
from gradio_imageslider import ImageSlider
import torch
from torchvision import transforms
import spaces
from PIL import Image

import numpy as np
import time

birefnet = AutoModelForImageSegmentation.from_pretrained(
    "ZhengPeng7/BiRefNet", trust_remote_code=True
)
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

print("Using device:", device)

birefnet.to(device)
transform_image = transforms.Compose(
    [
        transforms.Resize((1024, 1024)),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
    ]
)

# @spaces.GPU
# def PreProcess(image):
#     size = image.size
#     image = transform_image(image).unsqueeze(0).to(device)

#     with torch.no_grad():
#         preds = birefnet(image)[-1].sigmoid().cpu()
#     pred = preds[0].squeeze()
#     pred = transforms.ToPILImage()(pred)
#     mask = pred.resize(size)
#     # image.putalpha(mask)
#     return image

@spaces.GPU
def PreProcess(image):
    size = image.size  # Save original size
    image_tensor = transform_image(image).unsqueeze(0).to(device)  # Transform the image into a tensor

    with torch.no_grad():
        preds = birefnet(image_tensor)[-1].sigmoid().cpu()  # Get predictions
    pred = preds[0].squeeze()

    # Convert the prediction tensor to a PIL image
    pred_pil = transforms.ToPILImage()(pred)

    # Resize the mask to match the original image size
    mask = pred_pil.resize(size)

    # Convert the original image (passed as input) to a PIL image
    image_pil = image.convert("RGBA")  # Ensure the image has an alpha channel

    # Apply the alpha mask to the image
    image_pil.putalpha(mask)

    return image_pil

def segment_image(image):
    start = time.time()
    image = Image.fromarray(image)
    image = image.convert("RGB")
    org = image.copy()
    image = PreProcess(image)
    time_taken = np.round((time.time() - start),2)
    return (image, org), time_taken

slider = ImageSlider(label='birefnet', type="pil")
image = gr.Image(label="Upload an Image")

butterfly = Image.open("butterfly.png")
Dog = Image.open('Dog.jpg')

time_taken = gr.Textbox(label="Time taken", type="text")

demo = gr.Interface(
    segment_image, inputs=image, outputs=[slider,time_taken], examples=[butterfly,Dog], api_name="BiRefNet")

if __name__ == '__main__' :
    demo.launch()