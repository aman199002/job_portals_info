class HomeController < ApplicationController
  require 'rubygems'
  require 'nokogiri'
  require 'open-uri'  

  def welcome

  end

  def scrape
    portal = Portal.find_or_create_by_name(params[:url])
    url = portal.name + '?q=' + params[:keyword].split(' ').join('+') + '&l=' + params[:location].split(' ').join('+')    
    page = Nokogiri::HTML(open(url))    
    elements = page.css("[itemtype='http://schema.org/JobPosting']")    
    @jobs = []    
    elements.each do |element|
      begin
        job = portal.jobs.new
        job.title = element.at_css('.jobtitle').text.strip
        job.description = element.at_css('.summary').text.strip
        job.location = element.at_css('.location').text.strip
        job.company = element.at_css('.company').text.strip    
        unless Job.exists?(:title => job.title, :company => job.company, :description => job.description)
          job.save
          @jobs << job 
        end  
      rescue Exception => e
        puts "Exception occured: #{e.message}"
        next
      end
    end    
    @jobs.each_with_index do |job,index|
      begin
        linkedin_url = "http://www.linkedin.com/company/" + job.company.downcase.split(' ').join('-')
        linkedin_page = Nokogiri::HTML(open(linkedin_url))
        linkedin_description = linkedin_page.css('.container.description p').text.strip
        size = linkedin_page.xpath("//div[@class='basic-info']//dd[2]").text.strip
        job.update_attributes(:linkedin_desc => linkedin_description, :size => size)
        @jobs[index] = job
      rescue Exception => e
        puts "Exception occured: #{e.message}"
        next       
      end
    end
  end

  def all_jobs   
    @jobs = Job.paginate(:page => params[:page], :per_page => 10)    
  end  
end
