module Fanfic

  class Story

    attr_accessor :id, :identifier,
                  :title, :author,
                  :published_at, :publisher,
                  :rating, :language, :genre, :chapters,
                  :domain

    def initialize(uri)
      #https://www.fictionpress.com/s/3172150/1/r9kElsa-Is-Suffering
      @id = uri[/(http|https):\/\/(www|m)?.(fanfiction.net|fictionpress.com)\/s\/(\d+).*/, 4]
      @domain = uri[/(http|https):\/\/(www|m)?.(fanfiction.net|fictionpress.com)\/s\/(\d+).*/, 3]
      raise Exception.new "Cannot parse uri: #{uri}" unless id
      @chapters_loaded = false
    end

    def uri
      "https://www.#{domain}/s/#{id}"
    end

    def chapter_uri(chapter_id)
      "https://www.#{domain}/s/#{id}/#{chapter_id}"
    end

    def publisher
      domain
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

      puts "Loaded details of story: #{@title} (#{@identifier})"
    end

    def load_chapters
      if chapters.any?
        fetch_queue = Queue.new
        chapters.each { |chap| fetch_queue.push(chap) }

        puts "Loading #{chapters.size} chapters of story: #{@title} (#{@identifier})"
        (1..8).map do |i|
          # puts "Starting thread ##{i}"
          Thread.new(fetch_queue) do |queue|
            while chap = queue.pop(true) rescue nil
              chap_uri = chapter_uri(chap[:id])
              # puts "Loading chapter in thread ##{i} #{chap[:id]}. - #{chap[:title]}: #{chap_uri}"
              doc = Nokogiri::HTML(open(chap_uri))
              chap[:body] = Story.get_text(doc.xpath('//*[@id="storytext"]'))
            end
          end
        end.each(&:join)
        puts "Loaded chapters of story: #{@title} (#{@identifier})"
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
