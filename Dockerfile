FROM python:3.12

RUN mkdir /application

WORKDIR "/application"

COPY . .

RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5000

ENV PYTHONUNBUFFERED 1
ENTRYPOINT ["python3.12", "app.py"]


