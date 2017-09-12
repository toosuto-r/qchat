workeron:1b
if[workeron;`SSL_VERIFY_SERVER setenv "no";system"q worker.q -p ",string[wp:{$[x~r:@[system;"lsof -i :",string x;x];x;x+1i]}/[system"p"]];system"sleep 0.5";wh:hopen "j"$wp]
\l kg.q
\l chat.q
\l func.q
\d .c4
\l connect4.q
\d .
\l levenshtein.q
