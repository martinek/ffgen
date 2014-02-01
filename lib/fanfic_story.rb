class FanficStory

  attr_accessor :id, :identifier,
                :title, :author,
                :published_at, :publisher,
                :rating, :language, :genre, :chapters

  def initialize(uri)
    @id = uri[/(http|https):\/\/(www)?.fanfiction.net\/s\/(\d+).*/, 3]
    raise Exception.new "Cannot parse uri: #{uri}" unless id
    @chapters_loaded = false
  end

  def uri
    "https://www.fanfiction.net/s/#{id}"
  end

  def chapter_uri(chapter_id)
    "https://www.fanfiction.net/s/#{id}/#{chapter_id}"
  end

  def publisher
    'fanfiction.net'
  end

  def load_details
    puts "Loading details from: #{uri}"

    @identifier = uri

    doc = Nokogiri::HTML(open(uri))

    @title = doc.xpath('//*[@id="profile_top"]/b')[0].text
    @author = doc.xpath('//*[@id="profile_top"]/a[1]')[0].text

    @rating = doc.xpath('//*[@id="profile_top"]/span[last()]/a[1]')[0].text
    details = doc.xpath('//*[@id="profile_top"]/span[last()]/text()[2]').text

    match = / - (?<lang>[^-]*) - (?<genre>[^-]*) -/.match(details)

    @language = match[:lang]
    @genre = match[:genre]

    time = doc.xpath("//text()[contains(., 'Published:')]/following-sibling::span").attr('data-xutime').value
    @published_at = DateTime.strptime(time,'%s')

    @chapters = doc.xpath('//*[@id="chap_select"][1]/option').collect do |option|
      {
          id: option['value'].to_i,
          title: option.text[/\d+. (.*)/, 1],
          body: ''
      }
    end

    if @chapters.count == 0
      @chapters << {
          id: 0,
          title: @title,
          body: get_text(doc.xpath('//*[@id="storytext"]'))
      }
      @chapters_loaded = true
    end
  end

  def load_chapters
    if !@chapters_loaded and chapters.any?
      chapters.each do |chap|
        chap_uri = chapter_uri(chap[:id])
        puts "Loading chapter #{chap[:id]}. - #{chap[:title]}: #{chap_uri}"
        doc = Nokogiri::HTML(open(chap_uri))
        chap[:body] = get_text(doc.xpath('//*[@id="storytext"]'))
      end
      @chapters_loaded = true
    end
  end

  def get_text(node)
    node.search('.//hr').remove
    node.search('.//br').remove
    node.inner_html
  end

end
