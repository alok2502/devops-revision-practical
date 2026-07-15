# base image: a minimal Python — this is layer 1
FROM python:3.12-slim

# metadata
LABEL maintainer="alok"

# set the working directory inside the image
WORKDIR /app

# copy our app in (this is a layer — cached unless app.py changes)
COPY app.py .

# document which port the app uses
EXPOSE 5000

# the command that runs when the container starts (this process becomes PID 1)
CMD ["python", "app.py"]
