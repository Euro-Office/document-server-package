# AdminPanel: proxy all requests to the service
location ^~ /admin {
  proxy_pass http://adminpanel;
  proxy_intercept_errors on;
  error_page 502 503 504 = /admin/disabled;
}

location = /admin/disabled {
  internal;
  alias M4_DS_EXAMPLE/welcome/admin-disabled.html;
  default_type text/html;
}

location ^~ /admin/css/ {
  alias M4_DS_EXAMPLE/welcome/css/;
  expires 365d;
}