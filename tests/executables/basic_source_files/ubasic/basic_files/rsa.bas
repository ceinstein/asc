10   let n = 101
20   let p = 3
30   gosub 100
40   if n % p = 0 then print p else print n
50   end
100  if p * p > n then return end if
110  if n % p = 0 then return end if
120  let p = p + 2
130  goto 100

			 
			 
			 