-module(model_feeds).

-export([prepare_update/1, write_update/4]).


-define(POOL, pool_users).
-define(Q(Stmt, Params), model_sup:equery(?POOL, Stmt, Params)).

prepare_update(FeedURL) ->
    case ?Q("UPDATE \"feeds\" SET \"last_update\"=CURRENT_TIMESTAMP WHERE \"url\"=$1", [FeedURL]) of
	{ok, 1} ->
	    ok;
	{ok, N} ->
	    exit({n_feeds, N})
    end,

    case ?Q("SELECT \"etag\", \"last_modified\" FROM \"feeds\" WHERE \"url\"=$1", [FeedURL]) of
	{ok, _, [{Etag, LastModified}]} = R ->
	    io:format("R ok: ~p~n",[R]),
	    {ok, Etag, LastModified};
	{ok, _, _} = R ->
	    io:format("R: ~p~n",[R]),
	    {ok, undefined, undefined}
    end.

-spec(write_update/4 :: (string(), {(binary() | null), (binary() | null)}, (binary() | null), (binary() | null)) -> ok).
write_update(FeedURL, {Etag, LastModified}, Error, Xml) when is_list(Etag) ->
    write_update(FeedURL, {list_to_binary(Etag), LastModified}, Error, Xml);
write_update(FeedURL, {Etag, LastModified}, Error, Xml) when is_list(LastModified) ->
    write_update(FeedURL, {Etag, list_to_binary(LastModified)}, Error, Xml);
%% TODO: don't drop xml on error!
write_update(FeedURL, {Etag, LastModified}, Error, Xml) ->
    Stmt = "UPDATE \"feeds\" SET \"last_update\"=CURRENT_TIMESTAMP, \"etag\"=$2, \"last_modified\"=$3, \"error\"=$4, \"xml\"=$5 WHERE \"url\"=$1",
    Params = [FeedURL,
	      enforce_string(Etag), enforce_string(LastModified), 
	      enforce_string(Error), enforce_string(Xml)],
    io:format("Q: ~p ~p~n", [Stmt,Params]),
    case ?Q(Stmt, Params) of
	{ok, 1} ->
	    ok;	   
	{ok, N} ->
	    exit({n_feeds, N})
    end.

enforce_string(S) when is_binary(S);
		       is_list(S) ->
    S;
enforce_string(_) ->
    <<"">>.