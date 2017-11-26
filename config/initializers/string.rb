# https://stackoverflow.com/a/1235891/12484
class String
  def is_integer?
    self.to_i.to_s == self
  end
end
