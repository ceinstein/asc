10   let x = 3
20   let n = 9223371994482243049
30   let p = 3
50   gosub 100
60   if n % p = 0 then goto 140 else goto 160
100  if p * p > n then return end if
110  if n % p = 0 then return end if
120  let p = p + 2
130  goto 100
140  let x = p
150  end
160  let x = n
170  end


			 
			 
			 
