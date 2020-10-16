class Numeric
  def time_human
    _h = self / 60
    t = ""
    t += "#{_h}h " if _h > 0
    _m = self % 60
    t += "#{_m}m" if _m > 0
    t.strip
  end
end

