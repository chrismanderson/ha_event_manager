require "csv"

class EventManager
  def initialize
    puts "EventManager Initialized."
    @file = CSV.open("event_attendees.csv", {:headers => true, :header_converters => :symbol})
  end

  def print_names
    @file.each do |line|
      puts "#{line[:first_name]} #{line[:last_name]}"
    end
  end

  def print_numbers
    @file.each do |line|
      number = clean_number(line[:homephone])
      puts number
    end
  end

  def clean_number(number)
    number.gsub!(/[^\d]/, '')
    if number.length == 10
      # do nothing
    elsif number.length == 11
      if number.start_with?("1")
        number = number[1..-1]
      else
        number = "0000000000"
      end
    else
      number = "0000000000"
    end
    return number
  end
end

manager = EventManager.new
manager.print_numbers
