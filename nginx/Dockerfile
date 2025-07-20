FROM nginx:alpine

# curlをインストール（ヘルスチェック用）
RUN apk add --no-cache curl

# デフォルト設定を残し、カスタム設定を追加
COPY app.conf /etc/nginx/conf.d/app.conf

# デフォルトのserver設定を削除（競合回避）
RUN rm /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
