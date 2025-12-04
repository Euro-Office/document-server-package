# AdminPanel: proxy all requests to the service
location ^~ /admin {
  proxy_pass http://adminpanel;
}
