require "thor"
require "sequel"
require "tty-table"
require_relative "./config"
require_relative "./monkey"

Sequel.connect($db_uri)

require_relative "./models"

class TimeTrack < Thor
  desc "start CLIENT", "start a new time frame"
  def start(client)
    frame = Frame.new(start_time: DateTime.now, client: client)
    frame.save
    puts "starting frame #{frame.id} for project #{frame.client} at #{frame.start_time}"
  end
  
  desc "commit", "commit frame"
  option :message, :aliases => :m, :type => :string, :required => false
  def commit
    frame = Frame.where(end_time: nil).first
    frame.end_time = DateTime.now
    frame.message = options[:message] if options[:message]
    frame.save
  end

  desc "amend ID", "amend a frame"
  option :message, :aliases => :m, :type => :string, :required => false
  option :rate, :aliases => :r, :type => :numeric, :required => false
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
      frame.save
    end
  end
  
  desc "restart", "restart a frame"
  def restart
    raise NotImplementedError
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
