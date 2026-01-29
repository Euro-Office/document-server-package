# AdminPanel: proxy all requests to the service
location ^~ /admin {
  proxy_pass http://adminpanel;
  proxy_intercept_errors on;
  error_page 502 503 504 = /welcome/admin-disabled.html;
}
