require './job_posting_page'
require 'time'

# var init; url segments, saved cache, and loop counter setup
job_title_search = String.new
job_location = String.new
counter = 0
cache = Array.new

# mechanize setup
agent = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}

# add CLI args to allow for more specific 
ARGV.each do |arg|
  if ARGV[0] == "sd"
    job_title_search = "software+developer"
  elsif ARGV[0] == "jd"
    job_title_search = "junior+developer"
  # elsif ARGV[0].to_s == ''
    # abort "Incorrect flag 0"
  else
    abort "Incorrect flag 0"
  end

  if ARGV[1] == "ot"
    job_location = "Ottawa"
  elsif ARGV[1] == "to"
    job_location = "Toronto"
  else
    abort "Incorrect flag 1"
  end
end

# output file
time = Time.new
out = File.open(time.strftime("%Y-%m-%d") << ".txt", "w")

while counter <= 2
  url = "http://www.indeed.ca/jobs?q=" << job_title_search << "&l=" << job_location << ",+ON&start=" << (counter * 20).to_s
  doc = Nokogiri::HTML(open(url))

  # init mechanize for each new page of results
  page = agent.get(url)
  current_page = agent.page.uri

  # scraping segment; gets job title and company; outputs to console
  doc.css(".result").each do |item|
    job_title = item.at_css(".jobtitle").text[/[^\s][a-zA-Z0-9 -.\/\–\\]*/]
    job_company = item.at_css(".company").text[/[^\s][a-zA-Z0-9 -.\/ \–\\]*/]
    full_job = job_title + " - " + job_company

    # avoids redundant searches
    if cache.include?(full_job) == false
      cache << full_job
      out.puts "#{job_title} - #{job_company}"

      job_link = JobPostingPage.new
      job_link.get_url(url, job_title, agent, out)
    end
  end
  counter += 1
end