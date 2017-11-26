require 'sinatra'
require 'json'
require 'sinatra/reloader'

require './parser.rb'

get '/' do
    json = JSON.parse(open('data/input.txt').read)
    @items = json.map do |input|
      # extract main contents
      puts "extracting main contents... "
      main_node = extract_main input["url1"], input["url2"]
      puts "main-contents xpath: " + main_node
    
      # find images
      puts "finding images"
      html =  Nokogiri::HTML(open(input["url1"]))
      images = find_images(html, main_node).map{|img|
        {xpath:img[1], src:img[2].attribute("src").value}
      }
      puts "finish"
    
      {title:input["title"], images:images}
    end
    erb :index
end