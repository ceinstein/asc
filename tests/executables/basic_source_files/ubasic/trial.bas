10   let x = 4
20   let t = 1
20   gosub 100
30   if t = 100 then goto 130 else print "breh"
40   end
100  if t = 100 then return end if
110  let t = t + 1
120  goto 100
130  let x = t
140  print x
150  end