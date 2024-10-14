FROM alpine:3.20.3

EXPOSE 2222 3000

ENV TZ="Asia/Kuala_Lumpur"

WORKDIR /gitea/

RUN apk add --no-cache git gitea tzdata su-exec && \
	chown gitea:www-data /gitea/ && \
	mv /etc/gitea/app.ini /etc/gitea/app.ini.default

COPY ./tools/gitea-run.sh /root/
COPY --chown=gitea:www-data ./configs/app.ini /etc/gitea/

CMD [ "/root/gitea-run.sh" ]