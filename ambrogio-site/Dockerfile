# ambrogio-site — static site served by nginx.
# The pod is static files only: no database, no backend, nothing computed at request time.

FROM nginx:stable-alpine
COPY site/ /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
