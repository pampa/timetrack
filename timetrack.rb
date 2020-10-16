ENV["THOR_SILENCE_DEPRECATION"] = "1" 

require "thor"
require "sequel"
require "tty-table"
require_relative "./config"
require_relative "./monkey"

Sequel.connect($db_uri)

require_relative "./models"

class TimeTrack < Thor
  desc "start", "start a new time frame"
  option :message, :aliases => :m, :type => :string,   :required => false 
  option :rate,    :aliases => :r, :type => :numeric,  :required => false
  option :client,  :aliases => :c, :type => :string,   :required => true
  def start
    frame = Frame.new(start_time: DateTime.now)
    frame.message = options[:message] if options[:message]
    frame.rate    = options[:rate]    if options[:rate]
    frame.client  = options[:client]  if options[:client]
    frame.save
    puts "starting frame #{frame.id} for client #{frame.client} at #{frame.start_time}"
  end
  
  desc "commit", "commit frame"
  option :message, :aliases => :m, :type => :string,   :required => true 
  option :rate,    :aliases => :r, :type => :numeric,  :required => false
  option :client,  :aliases => :c, :type => :string,   :required => false
  
  option :start,   :aliases => :s, :type => :boolean,  :required => false
  def commit
    frame = Frame.where(end_time: nil).first
    frame.end_time = DateTime.now
    frame.message = options[:message] if options[:message]
    frame.rate    = options[:rate]    if options[:rate]
    frame.client  = options[:client]  if options[:client]
    frame.save

    if options[:start]
      _frame = Frame.new(start_time: DateTime.now)
      _frame.message = frame.message 
      _frame.rate    = frame.rate
      _frame.client  = frame.client
      _frame.save
      puts "starting frame #{_frame.id} for client #{_frame.client} at #{_frame.start_time}"
    end
  end

  desc "amend ID", "amend a frame"
  option :message, :aliases => :m, :type => :string,  :required => false 
  option :rate,    :aliases => :r, :type => :numeric, :required => false
  option :client,  :aliases => :c, :type => :string,  :required => false
  def amend(id = nil)
    if id.nil?
      frame = Frame.last
    else
      frame = Frame[id]
    end

    if frame.nil?
      puts "Frame ##{id} not found"
    else
      frame.message = options[:message] if options[:message]
      frame.rate    = options[:rate]    if options[:rate]
      frame.client  = options[:client]  if options[:client]
      frame.save
    end
  end
  
  desc "backup", "dump database to timetrackYYMMDDHHMMSS.sql.gz file"
  def backup
    exec "sqlite3 #{$db_path} .dump | gzip > timetrack#{Time.now.strftime("%Y%m%d%H%M%S")}.sql.gz"
  end

  desc "pry", "start pry console"
  def pry
    require "pry"
    require "amazing_print"
    AmazingPrint.pry!
    Pry.start
  end
  
  desc "db", "run database console"
  def db 
    litecli = `which litecli 2> /dev/null`.strip
    unless litecli == ''
      exec "#{litecli} #{$db_path}"
    else
      exec  "sqlite3 #{$db_path}"
    end
  end

  desc "log", "print frame log"
  option :client, :aliases => :c, :type => :string, :required => false
  def log
    table = TTY::Table.new()
    total_time     = 0
    total_billable = 0
    total_cost     = 0
    query = Frame.where(invoice_id: nil)
    query = query.where(client: options[:client]) if options[:client]
    query.order(:start_time).each do |frame|
      total_time     += frame.minutes
      total_billable += frame.minutes(billable: true)
      total_cost     += frame.cost
      table << frame.as_array
    end
    puts table.render
    puts 
    puts "TOTAL: pure #{total_time.time_human}, billable #{total_billable.time_human}, cost #{total_cost}"
  end
end
