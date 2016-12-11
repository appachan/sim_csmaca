load "./node.rb"
load './frame.rb'

NODE_ID = {"AP"=>0, "A"=>1, "B"=>2, "C"=>3, "D"=>4}

# p File.expand_path(File.dirname(__FILE__))

terminal_a = Node.new([90, 95], -85, NODE_ID["A"])
terminal_b = Node.new([95, 90], -85, NODE_ID["B"])
terminal_c = Node.new([105, 90], -85, NODE_ID["C"])
terminal_d = Node.new([110, 95], -85, NODE_ID["D"])
access_point = Node.new([100, 100], -85, NODE_ID["AP"])
=begin
A = Node.new([90, 95], 28, NODE_ID["A"])
B = Node.new([95, 90], 30, NODE_ID["B"])
C = Node.new([105, 90], 25, NODE_ID["C"])
D = Node.new([110, 90], 29, NODE_ID["D"])
=end
for i in 1...25000
  terminal_a.routine([access_point, terminal_b, terminal_c, terminal_d], 54)
  terminal_b.routine([access_point, terminal_a, terminal_c, terminal_d], 54)
  terminal_c.routine([access_point, terminal_b, terminal_a, terminal_d], 54)
  terminal_d.routine([access_point, terminal_b, terminal_c, terminal_a], 54)
  access_point.routine([terminal_a, terminal_b, terminal_c, terminal_d], 54)
  puts i.to_s + " microsec passed."
  puts "-----------------------------------------------------------------"
  terminal_a.refresh_frames_list()
  terminal_b.refresh_frames_list()
  terminal_c.refresh_frames_list()
  terminal_d.refresh_frames_list()
  access_point.refresh_frames_list()
end

puts access_point.received_frames