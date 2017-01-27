require 'dotenv'

Dotenv.load

require 'sinatra'

Dir['./models/*.rb'].each do |file|
  require file
end

get '/' do
  haml :index
end

# Used for generating epub from url passed via parameter
post '/story.epub' do
  t0 = Time.now

  begin
    # Create story object
    story = Fanfic::Story.new(params['url'])
    # Load story details
    story.load_details
    # Load all of the story chapters.
    # If story is one shot (only one chapter), chapters don't need to be loaded as the chapter is inside the body of details.
    story.load_chapters unless story.one_shot?

    # Generator is used for ePub generation
    gen = Generator.new
    gen.build(story)

    message = "#{story.title} (#{story.uri}) > #{Time.now - t0} sec"
    HipchatNotificator.notify message
    EmailNotificator.notify message
    SlackNotificator.notify message

    # Output ePub to browser named by the story title
    content_type 'application/epub+zip'
    attachment "#{story.title.gsub(' ', '_')}.epub"
    gen.result_stream.string
  rescue Exception => e
    puts "Error generating story with url '#{params['url']}': #{e.message}"
    @message = 'Could not generate story'
    @error = e
    haml :error
  end
end

get '/test_notify' do
  message = 'Test message'
  HipchatNotificator.notify message
  EmailNotificator.notify message
  SlackNotificator.notify message
  { status: 'ok' }.to_json
end

# Used for previewing one chapter of story in browser.
# This was used for checking what story text looks like after parsing and modifications.
get '/preview' do
  begin
    Fanfic::Story.preview(params['url'])
  rescue Exception => e
    puts "Error previewing url '#{params['url']}': #{e.message}"
    @message = 'Could not preview story'
    @error = e
    haml :error
  end
end

# Can be used to keep application alive on heroku by pinging app.
get '/status' do
  content_type :json
  { status: 'ok' }.to_json
end

# extra generator from form
# These are used to generate ePub from text given through form

get '/ebook_form' do
  @params = GeneratorParams.new

  haml :ebook_form
end

post '/generate.epub' do
  @params = GeneratorParams.new(params['book'])

  if @params.valid?
    gen = Generator.new
    gen.build(@params)

    content_type 'application/epub+zip'
    attachment "#{@params.title.gsub(' ', '_')}.epub"
    gen.result_stream.string
  else
    haml :ebook_form
  end

end
