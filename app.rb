require 'dotenv'

Dotenv.load

require 'sinatra'
require 'sinatra/activerecord'
require './config/environments' #database configuration

Dir['./models/*.rb'].each do |file|
  require file
end

get '/' do
  @stories = Story.order(read: :asc, created_at: :desc)
  haml :index
end


# These are used for adding, removing and marking stories in database.
#
# post '/add_story' do
#   url = params['url']
#
#   Story.create(url: url, read: false)
#
#   redirect '/'
# end
#
# post '/delete_story' do
#   story = Story.find(params['id'])
#   story.delete
#   redirect '/'
# end
#
# post '/toggle_read' do
#   story = Story.find(params['id'])
#   story.read = !story.read
#   story.save
#   redirect '/'
# end

# Used for displaying last stories from Frozen (default)
# feed bo be used can also be passed via 'feed' parameter
get '/feed' do
  uri = 'https://www.fanfiction.net/atom/l/?&cid1=10896&r=103&s=1'

  if params['feed']
    feed = params.delete 'feed'
    uri = feed + params.to_query
  end

  # RSS feed is parsed using Feedjira gem. See feed.haml for details of what is printed out
  @feed = Feedjira::Feed.fetch_and_parse(uri)
  haml :feed
end

# Used for generating epub from url passed via parameter
post '/story.epub' do
  t0 = Time.now

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

  # Output ePub to browser named by the story title
  content_type 'application/epub+zip'
  attachment "#{story.title.gsub(' ', '_')}.epub"
  gen.result_stream.string
end

# Used for previewing one chapter of story in browser.
# This was used for checking what story text looks like after parsing and modifications.
get '/preview' do
  Fanfic::Story.preview(params['url'])
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

# This would be used for user profile display
#get '/:handle' do
#
#  @profile = Fanfic::Profile.new(params[:handle])
#
#
#  haml :profile
#end
