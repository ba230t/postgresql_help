FROM python:3.12-alpine
ENV FLASK_APP=app.py
ENV PYTHONDONTWRITEBYTECODE=1

WORKDIR /app
COPY . /app
RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5000
CMD ["flask", "run", "--host=0.0.0.0"]
