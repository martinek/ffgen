module Fanfic

  # Class used for downloading and parsing user profile
  class Profile

    attr_accessor :handle

    def initialize(handle)
      @handle = handle
    end

    def url
      'https://www.fanfiction.net/' + handle
    end

    def profile
      @profile ||= load_profile
    end

    def favstories
      divs = profile.xpath('//*[@id="fs_inside"]/div[@class="z-list favstories"]')
      divs.map do |div|
        data = div.attributes.select{|k, v| k.match(/data-.*/)}
        data = Hash[data.values.collect{|attr| [attr.name[/data-(.*)/, 1].to_sym, attr.value] }]

        [:storyid, :wordcount, :ratingtimes, :chapters, :statusid].each do |key|
          data[key] = data[key].to_i
        end

        [:datesubmit, :dateupdate].each do |key|
          data[key] = Time.at(data[key].to_i)
        end

        data[:url] = Story.uri(data[:storyid])

        data
      end
    end

    private

    def load_profile
      puts 'loading profile: ' + handle

      file_name = 'temp/profiles/' + handle
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

  end

end
