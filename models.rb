class Frame < Sequel::Model
  def minutes(billable: false)
    _et = end_time
    _et = Time.now if _et.nil?
    _m = ((_et - start_time) / 60).ceil

    if billable
      _a = _m % 15
      _m + (15 - _a)
    else
      _m
    end
  end

  def cost
    unless rate.nil?
      (rate.to_f / 60.0 * minutes(billable: true)).round(2)
    else
      (0.0).round(2) 
    end
  end

  def as_array
    [ start_time.strftime("%b %d %k:%M"),
      "##{id}",
      minutes.time_human,
      "~#{minutes(billable: true).time_human}",
      cost,
      "[#{client}]",
      message ]
  end
end

class Invoice < Sequel::Model
end
