FROM python:3.10.6-slim

WORKDIR /subsai

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git gcc g++ ffmpeg && \
    rm -rf /var/lib/apt/lists/*

# Constrain setuptools in ALL pip environments (including build isolation)
RUN echo "setuptools>=69.5,<78" > /tmp/pip-constraints.txt
ENV PIP_CONSTRAINT=/tmp/pip-constraints.txt

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir "setuptools>=69.5,<78" wheel

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY pyproject.toml .
COPY ./src ./src
COPY ./assets ./assets

RUN pip install --no-cache-dir .

EXPOSE 8501

ENTRYPOINT ["python", "src/subsai/webui.py", "--server.fileWatcherType", "none", "--browser.gatherUsageStats", "false", "--server.maxUploadSize", "5000"]
