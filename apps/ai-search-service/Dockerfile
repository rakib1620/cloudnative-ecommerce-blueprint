FROM python:3.11-slim

# Create non-root user
RUN useradd -m -u 10001 appuser
WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY src/ ./src/
RUN chown -R appuser:appuser /app

USER 10001:10001
EXPOSE 8085

CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8085"]
