module Fanfic

  class Story

    attr_accessor :id, :identifier,
                  :title, :author,
                  :published_at, :publisher,
                  :rating, :language, :genre, :chapters

    def initialize(uri)
      @id = uri[/(http|https):\/\/(www|m)?.fanfiction.net\/s\/(\d+).*/, 3]
      raise Exception.new "Cannot parse uri: #{uri}" unless id
      @chapters_loaded = false
    end

    def uri
      Story.uri(id)
    end

    def chapter_uri(chapter_id)
      "https://www.fanfiction.net/s/#{id}/#{chapter_id}"
    end

    def publisher
      'fanfiction.net'
    end

    def one_shot?
      @chapters.count == 0
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
      end.uniq

      if one_shot?
        @chapters << {
            id: 0,
            title: @title,
            body: Story.get_text(doc.xpath('//*[@id="storytext"]'))
        }
      end
    end

    def load_chapters
      if chapters.any?
        chapters.each do |chap|
          chap_uri = chapter_uri(chap[:id])
          puts "Loading chapter #{chap[:id]}. - #{chap[:title]}: #{chap_uri}"
          doc = Nokogiri::HTML(open(chap_uri))
          chap[:body] = Story.get_text(doc.xpath('//*[@id="storytext"]'))
        end
      end
    end

    def self.preview(url)
      raise ArgumentError.new "Missing argument: url" unless url

      #doc = self.story(url)
      doc = Nokogiri::HTML(open(url))
      body = get_text(doc.xpath('//*[@id="storytext"]'))
      body.to_s
    end

    def self.get_text(node)
      node.search('.//hr').each do |hr|
        hr.name = 'p'
        hr.content = '--- === ---'
        hr.attributes.keys.each { |attr| hr.remove_attribute attr }
        hr['style'] = 'text-align: center'
      end
      node.search('.//br').remove
      node.inner_html
    end

    def self.story(url)
      file_name = 'test.xml'
      if File.exist? file_name
        puts "Loading from file: #{file_name}"
        buffer = File.open(file_name,'r').read
        doc = Nokogiri::XML(buffer)
      else
        puts "Loading from url: #{url}"
        doc = Nokogiri::HTML(open(url))
        File.open(file_name, 'w') {|f| doc.write_xml_to f}
      end

      doc
    end

    def self.uri(story_id)
      "https://www.fanfiction.net/s/#{story_id}"
    end

  end

end
