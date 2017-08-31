\d .key
p:{$[x<4;enlist 2;r,1_where not any x#'not til each r:.z.s ceiling sqrt x]}

/coprimes jg
c:{where not til[x] in raze 1,a*'til@'x div a:{x where 1=sum x=/:x*'x div/:x}i[w],d w:where x=i*d:x div i:1_1+til floor sqrt x}

/euclid gcd
eu:{first{last[x],(mod). x}/[{0<>last x};desc x,y]}

/congruence (ext Euclid)
cg:{$[0>t:{x[;1],'x[;0]-x[;1]*(div). last x}/[{0<>x[1;1]};(0 1;y,x)][0;0];t+y;t]}

/general ext. Euclid
ex:{{(x[1];(x[0]-x[1]*q:(div). x[;0]))}/[{0<x[1;0]};(x,y),'(1 0;0 1)]}
cg:{{$[0>t:x[0;2];y+t;t]}[;y]ex . desc x,y}

/NOTE limit primes to 10000?
mk:{r:`pub`pri`nkey!e,cg[e:1?c t;t:div[prd pq-1;.[ex . pq-1;0 0]]],prd pq:2?p x}

\d .
