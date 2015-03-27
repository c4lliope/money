require 'capybara/poltergeist'
require 'ruby-progressbar'

session = Capybara::Session.new(:poltergeist)

session.visit("https://bank.simple.com/signin")

session.fill_in("username", with: "USERNAME")
session.fill_in("password", with: "PASSWORD")
session.click_on("Sign in")

puts "Safe to spend: #{session.find("#sts-flag").text}"

session.click_link("Goals")

def print_goal_stats(session)
  goal_name = session.find(".goal-column-title").text
  current_amount = session.find(".goal-column-token").text.gsub('$', '').gsub(',', '').to_f
  total_amount = session.find(".goal-column-total h6").text.gsub('$', '').gsub(',', '').to_f

  puts "#{goal_name}: $#{current_amount} / $#{total_amount}"
  bar = ProgressBar.create(starting_at: current_amount, total: total_amount)
  bar.stop
end

goals_count = session.all(".timeline-goal-container").count
puts "#{goals_count} goals"

goals_count.times do |goal_index|
  goal = session.all(".timeline-goal-container")[goal_index]
  puts

  begin
    goal.click
  rescue
    "could'nt click #{goal.inspect}"
  end

  print_goal_stats(session)

  button = session.find("#goal-navbar button", text: "Catch up")

  if button.disabled?
    puts "Button is disabled"
  else
    previous_amount = session.find(".goal-column-token").text
    button.click
    current_amount = session.find(".goal-column-token").text

    if previous_amount == current_amount
      puts "All caught up!"
    else
      puts "#{previous_amount} -> #{current_amount}"
    end
  end
end

puts

session.click_on "Activity"
puts "Safe to spend: #{session.find("#sts-flag").text}"
