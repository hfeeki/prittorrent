-module(model_enclosures).

-export([to_hash/0, set_torrent/3, item_torrents/2]).

-include("../include/model.hrl").

-define(POOL, pool_users).
-define(Q(Stmt, Params), model_sup:equery(?POOL, Stmt, Params)).
-define(T(Fun), model_sup:transaction(?POOL, Fun)).

to_hash() ->
    case ?Q("SELECT \"enclosure_url\" FROM enclosure_to_hash()", []) of
	{ok, _, [{URL}]}
	  when is_binary(URL),
	       size(URL) > 0 ->
	    {ok, URL};
	R ->
	    io:format("to_hash -> ~p~n", [R]),
	    nothing
    end.

set_torrent(URL, Error, InfoHash) ->
    ?T(fun(Q) ->
	       case Q("SELECT count(\"url\") FROM enclosure_torrents WHERE \"url\"=$1", [URL]) of
		   {ok, _, [{0}]} ->
		       ?Q("INSERT INTO enclosure_torrents (\"url\", \"last_update\", \"info_hash\", \"error\") VALUES ($1, CURRENT_TIMESTAMP, $2, $3)", [URL, InfoHash, Error]);
		   {ok, _, [{1}]} ->
		       ?Q("UPDATE enclosure_torrents SET \"last_update\"=CURRENT_TIMESTAMP, \"info_hash\"=$2, \"error\"=$3 WHERE \"url\"=$1", [URL, InfoHash, Error])
	       end
       end).

item_torrents(Feed, Item) ->
    {ok, _, Torrents} =
	?Q("SELECT \"url\", \"info_hash\" FROM item_torrents WHERE \"feed\"=$1 AND \"item\"=$2 ORDER BY \"url\"", [Feed, Item]),
    Torrents.
