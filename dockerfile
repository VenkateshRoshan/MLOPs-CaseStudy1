FROM python:3.10

ARG HF_TOKEN

ENV HF_TOKEN=${HF_TOKEN}

WORKDIR /app

# Install FFmpeg and other dependencies
RUN apt-get update 
RUN apt-get install -y ffmpeg
RUN apt-get clean

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Make port 5000 available to the world outside this container
EXPOSE 5000

# Run app.py when the container launches
CMD ["python", "app.py"]