class String
  def strip_spaces_and_symbols
    self.gsub(/[^a-zA-Z0-9]/, '')
  end

  def trim_to_5_chars
    match = self.match(/\d{5}/)
    match ? match[0] : nil
  end

  def strip_excess_spaces
    self.gsub(/\s+/, ' ')
  end
end
