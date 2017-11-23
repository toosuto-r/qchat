\d .st

futures:([]start:0#.z.p;expiry:0#.z.p;user:0#`;sym:0#`;sz:0#0;cap:0#0f;lev:0#0f;ipx:0#0f)
txhist:futures,'([]cpx:0#0f)

greq:("http://finance.google.com/finance?q=";"";"&output=json")

qt:{r:.Q.hg`$raze@[greq;1;,;x];if[not "/" in 3#r;:enlist "sym not found"];flip[.j.k 3_r][`name`l;0]}

getqt:{[x;u] neg[.z.w](`worker;`buyr;"hey",(-1_u),": "," is "sv qt x)}

//takes stock count, leverage, expiry, input cap; returns amount of q to subtract - null on fail
buy:{[u;c;l;e;s]if[~[first q:qt s]"sym not found";:neg[.z.w](`worker;`buyr;(1_ u),"has failed to specify a correct sym")];
  q:"F"$last q;
  `.st.futures upsert iv:(.z.P;.z.P+60*"v"$e;.z.u;`$s;c;o:c*q;l;q);
  neg[.z.w](`worker;`buyr;(1_ u),"has bought ",string[o]," of ",s," at ",string[100*l],"%, expiring in ",string[e]," minutes");}

interest:1.05

//add interest to the leveraged portion of the stake, subtract this from return over input cap
sell:{po,(((po:$["F";last qt string x`sym])*x`sz)-x`cap)-($["j";"u"$.z.p-x`start]*[interest]/lf)-lf:x[`cap]*1-x[`lev]}

expcheck:{
  ti:exec i from futures where expiry<.z.P;
  if[count ti;
    o:(r`user;last'[s:sell'[r:futures ti]]);
    `.st.txhist upsert futures[ti],'([]cpx:first'[s]);
    neg[key[.z.W]0](`manageq;@[o;1;$["j"]]);
    neg[key[.z.W]0]@/:(`worker;`buyr),/:enlist'[string[r`user],'" made ",/:string[last'[s]],\:"q from their last transaction"];
    delete from `.st.futures where i in ti];
  `..cron insert (.z.P+"v"$60;`.st.expcheck;enlist`);}

`..cron insert (.z.P+"v"$60;`.st.expcheck;enlist`);

\d .
