require "csv"

class EventManager
  INVALID_ZIPCODE = "00000"
  
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
      puts clean_number(line[:homephone])
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
  
  def print_zipcodes
    @file.each do |line|
      zipcode = clean_zipcode(line[:zipcode])
      puts zipcode
    end
  end
  
  def clean_zipcode(original)
    if original.nil?
      result = INVALID_ZIPCODE
    elsif original.length < 5
      result = original.prepend("0") until original.length == 5
    else
      result = original
    end
    
    return result
  end
  
end

manager = EventManager.new
manager.print_zipcodes
