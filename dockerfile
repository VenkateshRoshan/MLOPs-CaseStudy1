FROM python:3.10

ARG HF_TOKEN

ENV HF_TOKEN=${HF_TOKEN}

WORKDIR /app

# Install FFmpeg and other dependencies
RUN apt-get update 
RUN apt-get install -y ffmpeg
RUN apt-get install -y prometheus-node-exporter
RUN apt-get clean

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Make port 7860 available to the world outside this container
EXPOSE 7860
# Prometheus Node Exporter metrics
EXPOSE 25561
# Prometheus Python app metrics
EXPOSE 25562


# Run app.py when the container launches
# CMD ["python", "app.py"]
# Run both the Node Exporter and the Gradio application
CMD ["sh", "-c", "prometheus-node-exporter & python app.py"]