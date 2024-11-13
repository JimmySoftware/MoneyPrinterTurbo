# Use an official Python runtime as a parent image
FROM python:3.10-slim-bullseye

# Set the working directory in the container
WORKDIR /MoneyPrinterTurbo

# 设置/MoneyPrinterTurbo目录权限为777
RUN chmod 777 /MoneyPrinterTurbo

ENV PYTHONPATH="/MoneyPrinterTurbo"

RUN apt-get update
RUN apt-get install -y build-essential pkg-config libpango1.0-dev libharfbuzz-dev libcairo2-dev libjpeg-dev libpng-dev libtiff-dev libxml2-dev


# Install system dependencies
#     imagemagick \
RUN apt-get install -y \
    git \
    ffmpeg \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://download.imagemagick.org/ImageMagick/download/ImageMagick.tar.gz && \
    tar xvzf ImageMagick.tar.gz && \
    cd ImageMagick-* && \
    ./configure --with-pango --with-harfbuzz && \
    make && \
    make install && \
    ldconfig /usr/local/lib && \
    cd .. && \
    rm -rf ImageMagick.tar.gz ImageMagick-*

# Fix security policy for ImageMagick
#RUN sed -i '/<policy domain="path" rights="none" pattern="@\*"/d' /usr/local/bin/ImageMagick-7/policy.xml
#RUN POLICY_FILE=$(find /usr/local/ -name policy.xml) && \
#    if [ -n "$POLICY_FILE" ]; then sed -i '/<policy domain="path" rights="none" pattern="@\*"/d' "$POLICY_FILE"; fi

# Copy only the requirements.txt first to leverage Docker cache
COPY requirements.txt ./

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Now copy the rest of the codebase into the image
COPY . .
RUN cp ./resource/fonts/*.ttf /usr/share/fonts

RUN pip install -e ./moviepy

# Expose the port the app runs on
EXPOSE 8501

# Command to run the application
#CMD ["streamlit", "run", "./webui/Main.py","--browser.serverAddress=127.0.0.1","--server.enableCORS=True","--browser.gatherUsageStats=False"]
CMD ["tail", "-f", "/dev/null"]
# 1. Build the Docker image using the following command
# docker build -t moneyprinterturbo .

# 2. Run the Docker container using the following command
## For Linux or MacOS:
# docker run -v $(pwd)/config.toml:/MoneyPrinterTurbo/config.toml -v $(pwd)/storage:/MoneyPrinterTurbo/storage -p 8501:8501 moneyprinterturbo
## For Windows:
# docker run -v %cd%/config.toml:/MoneyPrinterTurbo/config.toml -v %cd%/storage:/MoneyPrinterTurbo/storage -p 8501:8501 moneyprinterturbo