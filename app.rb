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

post '/add_story' do
  url = params['url']

  #if url
  #  story = Fanfic::Story.new(url)
  #  title = url.split('/')[6]
  #
  #  if title
  #    title = title.gsub '-', ' '
  #  else
  #    story.load_details
  #    title = story.title
  #  end
  #
  #  Story.create(story_id: story.id, title: title, read: false)
  #end

  Story.create(url: url, read: false)

  redirect '/'
end

post '/delete_story' do
  story = Story.find(params['id'])
  story.delete
  redirect '/'
end

post '/toggle_read' do
  story = Story.find(params['id'])
  story.read = !story.read
  story.save
  redirect '/'
end

get '/feed' do
  uri = 'https://www.fanfiction.net/atom/l/?&cid1=10896&r=103&s=1'

  if params['feed']
    feed = params.delete 'feed'
    uri = feed + params.to_query
  end

  @feed = Feedjira::Feed.fetch_and_parse(uri)
  haml :feed
end

post '/story.epub' do
  story = Fanfic::Story.new(params['url'])
  story.load_details
  story.load_chapters unless story.one_shot?

  gen = Generator.new
  gen.build(story)

  content_type 'application/epub+zip'
  attachment "#{story.title.gsub(' ', '_')}.epub"
  gen.result_stream.string
end

get '/preview' do
  FanficStory.preview(params['url'])
end

get '/status' do
  content_type :json
  { status: 'ok' }.to_json
end

# extra generator from form

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

#get '/:handle' do
#
#  @profile = Fanfic::Profile.new(params[:handle])
#
#
#  haml :profile
#end
