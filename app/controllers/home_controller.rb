class HomeController < ApplicationController
  require 'rubygems'
  require 'nokogiri'
  require 'open-uri'  

  def welcome

  end

  def scrape
    @portal = Portal.find_or_create_by_name(params[:url])
    case @portal.name
    when "http://www.indeed.com/jobs"
      url = @portal.name + '?q=' + params[:keyword].split(' ').join('+') + '&where=' + params[:location].split(' ').join('+')
      @jobs = @portal.fetch_all_jobs_for_indeed(url, params[:jobs_count].to_i)
    when "http://jobsearch.monster.com/search"
      url = @portal.name + '?q=' + params[:keyword].split(' ').join('+') + '&l=' + params[:location].split(' ').join('+')
    end      
  end

  def all_jobs   
    @jobs = Job.paginate(:page => params[:page], :per_page => 10)    
  end        
end
