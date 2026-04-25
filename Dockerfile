FROM python:3.11-slim
WORKDIR /app
COPY app.py  .
COPY requirements.txt .
RUN groupadd -r appuser && \
    useradd -r -g appuser appuser && \
    pip install --no-cache-dir -r requirements.txt && \
    chown -R appuser:appuser /app

USER appuser
EXPOSE 80
CMD ["python", "app.py"]