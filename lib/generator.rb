class Generator

  attr_accessor :book

  def build(story)
    @book = GEPUB::Book.new

    book.set_primary_identifier   story.identifier, 'BookID', 'URL'

    book.add_title     story.title
    book.add_creator   story.author

    book.add_publisher story.publisher, nil
    book.add_date      story.published_at.to_s, nil

    book.ordered {
      story.chapters.each do |chapter|
        book.add_item("text/chap#{chapter[:id]}.xhtml")
            .add_content(StringIO.new("<html xmlns=\"http://www.w3.org/1999/xhtml\"><head><title>#{Rack::Utils.escape_html(chapter[:title])}</title></head><body>#{chapter[:body]}</body></html>"))
            .toc_text(chapter[:title])
      end
    }
  end

  def result_stream
    book.generate_epub_stream
  end

end
