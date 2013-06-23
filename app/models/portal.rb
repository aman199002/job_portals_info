class Portal < ActiveRecord::Base
  attr_accessible :name
  has_many :jobs

  
  def fetch_all_jobs_for_indeed(url, given_jobs_count)
    @jobs = []
    page = Nokogiri::HTML(open(url))
    fetch_jobs_for_indeed(url, page)
    total_jobs_count = page.css('#searchCount').text.split(" ").last.gsub(',','').to_i
    available_jobs_count = total_jobs_count > 1000 ? 990 : total_jobs_count
    required_jobs_count = (given_jobs_count > 0 && given_jobs_count <= available_jobs_count) ? given_jobs_count : available_jobs_count    
    1.upto(required_jobs_count/10) do |count|      
      fetch_jobs_for_indeed(url.concat("&start=#{count*10}"))
    end
    @jobs.flatten
  end	


  def fetch_jobs_for_indeed(url, page=nil)  	
    page = Nokogiri::HTML(open(url)) if page.nil?
	elements = page.css("[itemtype='http://schema.org/JobPosting']")    
	jobs = []	
	elements.each do |element|
	  begin
	    job = self.jobs.new
	  	job.title = element.at_css('.jobtitle').text.strip
	  	job.description = element.at_css('.summary').text.strip
	  	job.location = element.at_css('.location').text.strip
	  	job.company = element.at_css('.company').text.strip    
	  	unless Job.exists?(:title => job.title, :company => job.company, :description => job.description)
	  	  job.save
	  	  jobs << job 
	  	end
	  rescue Exception => e
	    puts "Exception occured: #{e.message}"
	  	next
      end
	end    
	get_info_from_linkedin(jobs) if jobs.present?
	@jobs << jobs
  end

  private

    def get_info_from_linkedin(jobs)
	  jobs.each_with_index do |job,index|
	  begin
	    linkedin_url = "http://www.linkedin.com/company/" + job.company.downcase.split(' ').join('-')	
	    linkedin_page = Nokogiri::HTML(open(linkedin_url))
	    linkedin_description = linkedin_page.css('.container.description p').text.strip
	    size = linkedin_page.xpath("//div[@class='basic-info']//dd[2]").text.strip
	    job.update_attributes(:linkedin_desc => linkedin_description, :size => size)
	    jobs[index] = job
	  rescue Exception => e
	    puts "Exception occured: #{e.message}"
	    next       
      end
    end	

  end  

end
