class Backtrace
  include Mongoid::Document
  include Mongoid::Timestamps

  field :fingerprint
  index :fingerprint

  has_many :notices
  embeds_many :lines, :class_name => "BacktraceLine"

  after_initialize :generate_fingerprint

  def self.find_or_create(attributes = {})
    new(attributes).similar || create(attributes)
  end

  def similar
    Backtrace.first(:conditions => { :fingerprint => fingerprint } )
  end

  def raw=(raw)
    raw.each do |raw_line|
      lines << BacktraceLine.new(BacktraceLineNormalizer.new(raw_line).call)
    end
  end

  private
  def generate_fingerprint
    self.fingerprint = Digest::SHA1.hexdigest(lines.join)
  end

end
