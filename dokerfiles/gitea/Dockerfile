FROM ubuntu:latest

RUN useradd gitea -d /app -m

ADD binary /app/gitea
ADD app.sh /app/entry
RUN chmod +x /app/gitea
RUN chmod +x /app/entry

RUN apt-get update
RUN apt-get install -y git

RUN chown gitea:gitea /app/gitea

EXPOSE 3000

ENTRYPOINT ["/app/entry"]
