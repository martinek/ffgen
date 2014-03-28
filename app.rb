get '/' do
  haml :index
end

get '/feed' do
  uri = 'https://www.fanfiction.net/atom/l/?&cid1=10896&r=103&s=1'

  if params['feed']
    feed = params.delete 'feed'
    uri = feed + params.to_query
  end

  @feed = Feedzirra::Feed.fetch_and_parse(uri)
  haml :feed
end

generate_file = lambda do
  story = Fanfic::Story.new(params['url'])
  story.load_details

  gen = Generator.new
  gen.build(story)

  content_type 'application/epub+zip'
  attachment "#{story.title.gsub(' ', '_')}.epub"
  gen.result_stream.string
end

#get '/story.epub', &generate_file
post '/story.epub', &generate_file

get '/preview' do
  FanficStory.preview(params['url'])
end

#get '/:handle' do
#
#  @profile = Fanfic::Profile.new(params[:handle])
#
#
#  haml :profile
#end
