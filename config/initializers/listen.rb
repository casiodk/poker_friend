listener = Listen.to("/Users/nicolaiseerup/Sites/poker_friend/doc", force_polling: true, wait_for_delay: 1) do |modified, added, removed|
  modified.each do |path|
  	HandHistoryParser.new(path: path).parse
  end

  added.each do |path|
  	HandHistoryParser.new(path: path).parse
  end

  puts "removed absolute path: #{ removed }"

  # send out listen event
end
listener.start # not blocking
