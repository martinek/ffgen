class GeneratorParams

  attr_accessor :identifier, :title, :author, :publisher, :published_at, :chapters
  REQUIRED_PARAMS = %w(identifier title author publisher published_at)

  def initialize(params = {})
    REQUIRED_PARAMS.each do |required_param|
      self.send "#{required_param}=", params[required_param]
    end

    @chapters = (params['chapters'].is_a?(Array) ? params['chapters'] : [])
  end

  def published_at=(value)
    if value.is_a? String
      value = begin
        DateTime.parse(value)
      rescue ArgumentError
        nil
      end
    end
    @published_at = value
  end

  def valid?
    (identifier and title and author and publisher and published_at and chapters) and
        !identifier.blank? and
        !title.blank? and
        !author.blank? and
        !publisher.blank? and
        chapters.count > 0
  end

end
