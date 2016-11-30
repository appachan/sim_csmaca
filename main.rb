r = Random.new()

terminal = Terminal.new([90, 95], 28)
terminal.set_boc
terminal.test_method()
@ch_status = 1
for i in 1...10
  terminal.routine
  puts "1 microsec passed."
end
