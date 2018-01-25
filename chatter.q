if[not system"p";system"p 0W";-1 "Set main process port to :",string system"p"]; /if started without port, pick a random available one and output it
init:{[x]
  wh::first key .z.W;               /worker has opened handle, first handle in .z.W will be worker
  system@'"l ",/:("kg";"chat";"func";"levenshtein";"bots";"pts";"plot";"connect4"),\:".q";
 }
p:string system"p";                 /get main proc port for worker to callback
system"q worker.q ",p," -p 0W";     /start worker on random available port
/after this, main proc will wait for init to be called by worker
