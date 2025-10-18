FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y postgresql-client libpq-dev gcc

COPY requirements.txt .
RUN pip install -r requirements.txt
RUN pip uninstall openai -y && pip install openai==0.28.1 --force-reinstall

COPY backend/ .

EXPOSE 8000

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

