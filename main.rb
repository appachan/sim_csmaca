load "./node.rb"
load './frame.rb'

NODE_ID = {"AP"=>0, "A"=>1, "B"=>2, "C"=>3, "D"=>4}

terminal_a = Node.new([90, 95], -85, NODE_ID["A"])
terminal_b = Node.new([95, 90], -85, NODE_ID["B"])
terminal_c = Node.new([105, 90], -85, NODE_ID["C"])
terminal_d = Node.new([110, 95], -85, NODE_ID["D"])
access_point = Node.new([100, 100], -85, NODE_ID["AP"])

puts "|A\t|B\t|C\t|D\t|AP\t|"
for i in 1...25001

  terminal_a.routine([access_point, terminal_b, terminal_c, terminal_d], 54)
  terminal_b.routine([access_point, terminal_a, terminal_c, terminal_d], 54)
  terminal_c.routine([access_point, terminal_b, terminal_a, terminal_d], 54)
  terminal_d.routine([access_point, terminal_b, terminal_c, terminal_a], 54)
  access_point.routine([terminal_a, terminal_b, terminal_c, terminal_d], 54)

  terminal_a.refresh_frames_list()
  terminal_b.refresh_frames_list()
  terminal_c.refresh_frames_list()
  terminal_d.refresh_frames_list()
  access_point.refresh_frames_list()

  print "|"
  terminal_a.print_status()
  print "|"
  terminal_b.print_status()
  print "|"
  terminal_c.print_status()
  print "|"
  terminal_d.print_status()
  print "|"
  access_point.print_status()
  print "|"
  puts i.to_s + " µs passed."
end