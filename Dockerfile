FROM python

RUN mkdir /app
WORKDIR /app
RUN pip install slack_bolt requests
COPY app.py .
CMD ["python", "app.py"]