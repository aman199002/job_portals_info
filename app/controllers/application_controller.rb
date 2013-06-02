class ApplicationController < ActionController::Base
  http_basic_authenticate_with :name => "aman", :password => "yupp!!scraped"	
  protect_from_forgery
end
