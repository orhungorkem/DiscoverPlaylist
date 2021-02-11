% orhun gorkem
% 2017400171
% compiling: yes
% complete: yes

% artist(ArtistName, Genres, AlbumIds).
% album(AlbumId, AlbumName, ArtistNames, TrackIds).
% track(TrackId, TrackName, ArtistNames, AlbumName, [Explicit, Danceability, Energy,
%                                                    Key, Loudness, Mode, Speechiness,
%                                                    Acousticness, Instrumentalness, Liveness,
%                                                    Valence, Tempo, DurationMs, TimeSignature]).


features([explicit-0, danceability-1, energy-1,
          key-0, loudness-0, mode-1, speechiness-1,
       	  acousticness-1, instrumentalness-1,
          liveness-1, valence-1, tempo-0, duration_ms-0,
          time_signature-0]).

filter_features(Features, Filtered) :- features(X), filter_features_rec(Features, X, Filtered).
filter_features_rec([], [], []).
filter_features_rec([FeatHead|FeatTail], [Head|Tail], FilteredFeatures) :-
    filter_features_rec(FeatTail, Tail, FilteredTail),
    _-Use = Head,
    (
        (Use is 1, FilteredFeatures = [FeatHead|FilteredTail]);
        (Use is 0,
            FilteredFeatures = FilteredTail
        )
    ).

getTail([_|T],T).
getHead([H|_],H).


%listTrackIds(+AlbumsIdList, -TracksIdList)  Given list of album ids, get a list of their track ids.
listTrackIds([],[]).
listTrackIds([AlbumsHead|AlbumsTail],Tracks):-listTrackIds(AlbumsTail,Result), album(AlbumsHead,_,_,X), append(X,Result,Tracks).

%getTrackNames(+TracksIdList, -TracksNameList)  Given list of track ids, get a list of track names.
getTrackNames([],[]).
getTrackNames([IdHead|IdTail],[NameHead|NameTail]):-getTrackNames(IdTail,NameTail), track(IdHead,NameHead,_,_,_).

%getTrackArtists(+TracksIdList, -TracksArtistList)  Given list of track ids, get a list of artists.
getTrackArtists([],[]).
getTrackArtists([IdHead|IdTail],[ArtistHead|ArtistTail]):-getTrackArtists(IdTail,ArtistTail), track(IdHead,_,ArtistHead,_,_).

%getAlbumNames(+AlbumsIdList, -AlbumsNameList) Given list of album ids, get a list of their names.
getAlbumNames([],[]).
getAlbumNames([IdHead|IdTail],[NameHead|NameTail]):-getAlbumNames(IdTail,NameTail), album(IdHead,NameHead,_,_).

%getTrackFeatures(+TracksIdList, -TracksFeaturesList) Given list of track ids, get a list of features(filtered)
getTrackFeatures([],[]).
getTrackFeatures([IdHead|IdTail],[FeatureHead|FeatureTail]):-getTrackFeatures(IdTail,FeatureTail), track(IdHead,_,_,_,Features), filter_features(Features,FeatureHead).

%overall(+ListOfLists,-OverallList)  Given a couple of lists, gets an overall list
overall([],[]).
overall(Lists,Result):-total(Lists,Totallists,Count),overalls(Totallists,Count,Result).
%total(+ListOfLists,-TotalList,-Counter) Given a list of lists, sums all parallel indexes and put them in a list called totallist, also counts the number of input lists.
total([],[0,0,0,0,0,0,0,0],0).
total([ListsHead|ListsTail],TotalList,Counter):- total(ListsTail,TailResult,Count), Counter is Count+1, add(ListsHead,TailResult,TotalList).
%add(+List1,+List2,-Result) Given two lists, sums their parallel indexes and puts them in a result list.
add([],[],[]).
add([List1Head|List1Tail],[List2Head|List2Tail],[ResultHead|ResultTail]):-add(List1Tail,List2Tail,ResultTail), ResultHead is List1Head+List2Head.
%overalls(+List,+Divisor,-Result)  Given a list and a divisor, gets a list with all indexes of input divided by divisor.
overalls([],_,[]).
overalls([H|T],Divisor,Result):-overalls(T,Divisor,TailResult),X is H/Divisor,append([X],TailResult,Result).

%distance(+List1,+List2,-Dist) Given two lists, gets their eucledian distance's square
distance([],[],0).
distance([List1Head|List1Tail],[List2Head|List2Tail],Dist):-distance(List1Tail,List2Tail,LastDist),Add is (List1Head-List2Head)*(List1Head-List2Head),Dist is Add+LastDist.

%getFirstThirty(+List,-FirstThirty,+Count) Given a list, returns a list of first 30 elements.
getFirstThirty([],[], _).
getFirstThirty(_, Result, Count) :- Count =< 0, Result= [].
getFirstThirty([H|T],Result,Count) :- Counter is Count-1, getFirstThirty(T,TailResult,Counter), append([H],TailResult,Result).

% getArtistTracks(+ArtistName, -TrackIds, -TrackNames) 5 points
% Albums of artist is reached, given the list of albums, ids of tracks in those albums are stored using listTrackIds.
% Then following the ids, tracknames are stored.
getArtistTracks(ArtistName,TrackIds,TrackNames):- artist(ArtistName,_,Albums),listTrackIds(Albums,TrackIds),getTrackNames(TrackIds,TrackNames).

% albumFeatures(+AlbumId, -AlbumFeatures) 5 points
% Having the trackIds in the album, a list of features are reached using getTrackFeatures.
% Overall list of features are returned by overall.
albumFeatures(AlbumId,AlbumFeatures):-listTrackIds([AlbumId],TrackIds),getTrackFeatures(TrackIds,FeatureList),overall(FeatureList,AlbumFeatures).

% artistFeatures(+ArtistName, -ArtistFeatures) 5 points
% Using the predicate we have written(getArtistTracks), trackIds of the artist is reached.
% Then same procedure is applied as albumFeatures.
artistFeatures(ArtistName,ArtistFeatures):-getArtistTracks(ArtistName,TrackIds,_),getTrackFeatures(TrackIds,FeatureList),overall(FeatureList,ArtistFeatures).

% trackDistance(+TrackId1, +TrackId2, -Score) 5 points
% Features of tracks are yielded in desired format, given to distance predicate to calculate their Eucledian distance's square.
% Then distance is calculated with sqrt.
trackDistance(TrackId1,TrackId2,Score):-getTrackFeatures([TrackId1],L1),overall(L1,List1),getTrackFeatures([TrackId2],L2),overall(L2,List2),
  distance(List1,List2,Score2),Score is sqrt(Score2).

% albumDistance(+AlbumId1, +AlbumId2, -Score) 5 points
% albumfeatures are used and the distance is calculated with same procedure as track distance.
albumDistance(AlbumId1,AlbumId2,Score):-albumFeatures(AlbumId1,List1),albumFeatures(AlbumId2,List2),distance(List1,List2,Score2),Score is sqrt(Score2).

% artistDistance(+ArtistName1, +ArtistName2, -Score) 5 points
% Same process as albumdistance. 
artistDistance(ArtistName1,ArtistName2,Score):-artistFeatures(ArtistName1,List1),artistFeatures(ArtistName2,List2),distance(List1,List2,Score2),Score is sqrt(Score2).

% Helpers to work with pairs.
getValue(Pair,Value):-Pair=_-Value.
getKey(Pair,Key):-Pair=Key-_.
extractSecond([],[]).
extractSecond([HeadOfPairs|TailOfPairs],[HeadOfResult|TailOfResult]):-extractSecond(TailOfPairs,TailOfResult),getValue(HeadOfPairs,HeadOfResult).
extractFirst([],[]).
extractFirst([HeadOfPairs|TailOfPairs],[HeadOfResult|TailOfResult]):-extractFirst(TailOfPairs,TailOfResult),getKey(HeadOfPairs,HeadOfResult).

% findMostSimilarTracks(+TrackId, -SimilarIds, -SimilarNames) 10 points
% Distance-Id pairs are yielded by applying trackDistance predicate to all pair of comparisons with given track.
% List of pairs is sorted according to distances.
% Ids are reached with order, first 31 of them are taken into alist.
% First one should be the track itself, so tail is taken.
% Then names are returned with getTrackNames
findMostSimilarTracks(TrackId,SimilarIds,SimilarNames):-
    findall(Distance-Id, trackDistance(TrackId,Id,Distance), ListOfPairs),
    keysort(ListOfPairs, SortedPairs),
    extractSecond(SortedPairs,SortedIds),
    getFirstThirty(SortedIds,SimilarIds31,31),
    getTail(SimilarIds31,SimilarIds),
    getTrackNames(SimilarIds,SimilarNames).

% findMostSimilarAlbums(+AlbumId, -SimilarIds, -SimilarNames) 10 points
% Same procedure as findMostSimilarTracks
findMostSimilarAlbums(AlbumId,SimilarIds,SimilarNames):-
    findall(Distance-Id, albumDistance(AlbumId,Id,Distance), ListOfPairs),
    keysort(ListOfPairs, SortedPairs),
    extractSecond(SortedPairs,SortedIds),
    getFirstThirty(SortedIds,SimilarIds31,31),
    getTail(SimilarIds31,SimilarIds),
    getAlbumNames(SimilarIds,SimilarNames).


% findMostSimilarArtists(+ArtistName, -SimilarArtists) 10 points
% Same procedure as findMostSimilarTracks
findMostSimilarArtists(ArtistName,SimilarArtists):-
    findall(Distance-Name, artistDistance(ArtistName,Name,Distance), ListOfPairs),
    keysort(ListOfPairs, SortedPairs),
    extractSecond(SortedPairs,SortedNames),
    getFirstThirty(SortedNames,SimilarNames31,31),
    getTail(SimilarNames31,SimilarArtists).

% filterExplicitTracks(+TrackList, -FilteredTracks) 5 points
% Tracks in list are recursively iterated, if their explicit feature is 1, track is not added to result list. Else it is added.
filterExplicitTracks([],[]).
filterExplicitTracks([H|T],ResultTail):-
    track(H,_,_,_,Features),
    getHead(Features,Exp),
    Exp=1,
    filterExplicitTracks(T,ResultTail).
filterExplicitTracks([H|T],[H|ResultTail]):-
    track(H,_,_,_,Features),
    getHead(Features,Exp),
    Exp=0,
    filterExplicitTracks(T,ResultTail).
  

% getTrackGenre(+TrackId, -Genres) 5 points  
% Artists of track is reached
% Using addgenres, genres of given artists are stored in a list 
getTrackGenre(TrackId,Genres):-track(TrackId,_,Artists,_,_),addGenres(Artists,Genres).
addGenres([],[]).
addGenres([ArtistListH|ArtistListT],GenreList):-addGenres(ArtistListT,LastGenreList),artist(ArtistListH,Genres,_),append(Genres,LastGenreList,GenreList).


% discoverPlaylist(+LikedGenres, +DislikedGenres, +Features, +FileName, -Playlist) 30 points
% Adds all tracks to an Idlist with their ids.
% Using eliminationLikes, eliminates the list into LikedIdList
% Using eliminationDislikes, eliminates the list into ValidIdList
% Using pair, creates a list calles Pairlist, keeping pairs of distances and valid tracks
% Sorts the list according to distances, only keeps first 30 tracks
% To write into file, starting from ids, names and artists of tracks are reached
% Then necessary data are written into file
discoverPlaylist(LikedGenres,DislikedGenres,Features,FileName,SortedIdList):- 
    findall(X,track(X,_,_,_,_),IdList),
    eliminationLikes(IdList,LikedGenres,LikedIdList),
    eliminationDislikes(LikedIdList,DislikedGenres,ValidIdList),
    pair(ValidIdList,Features,PairList),
    keysort(PairList,SortedPairsMany),
    getFirstThirty(SortedPairsMany,SortedPairs,30),
    extractSecond(SortedPairs,SortedIdList),
    getTrackNames(SortedIdList,SortedNameList),
    getTrackArtists(SortedIdList,ArtistList),
    extractFirst(SortedPairs,Distances),
    open(FileName, write, Stream),
     write(Stream, SortedIdList),writeln(Stream,""),
     write(Stream, SortedNameList),writeln(Stream,""),
     write(Stream, ArtistList), writeln(Stream,""),
     write(Stream, Distances), close(Stream).

    

    


%Gets id list and comparison features, returns list of distance id pairs
pair([],_,[]).
pair([ValidIdListH|ValidIdListT],Features,Result):-
    pair(ValidIdListT,Features,PairListT),
    getTrackFeatures([ValidIdListH],FeatureList),
    getHead(FeatureList,TrackFeature),
    distance(TrackFeature,Features,Distance2),
    sqrt(Distance2,Distance),
    append([Distance-ValidIdListH],PairListT,Result).


%Gets all tracks, check validity of their genres according to likedgenres and returns a list having valid tracks according o likes.
eliminationLikes([],_,[]).
eliminationLikes([IdListH|IdListT],LikedGenres,Result):-
    eliminationLikes(IdListT,LikedGenres,TailResult),
    getTrackGenre(IdListH,Genres),
    checkGenres(IdListH,Genres,LikedGenres,List),
    append(List,TailResult,Result).

%Gets liked tracks, and eliminates ones owning dislike genres
eliminationDislikes([],_,[]).
eliminationDislikes([IdListH|IdListT],DislikedGenres,Result):-
    eliminationDislikes(IdListT,DislikedGenres,TailResult),
    getTrackGenre(IdListH,Genres),
    checkGenresX(IdListH,Genres,DislikedGenres,List),
    append(List,TailResult,Result).

%Gets a track Id, its genres, Likedgenres, if any genre is in likedgenres, returns a list with given track id, else returns empty list.  
checkGenres(_,[],_,[]).    
checkGenres(TrackId,[GenreH|_],LikedGenres,List):-genreInList(GenreH,LikedGenres),append([TrackId],[],List),!.
checkGenres(TrackId,[_|GenreT],LikedGenres,List):-checkGenres(TrackId,GenreT,LikedGenres,List).

%Gets a track Id, its genres, Dislikedgenres, if any genre is not in dislikedgenres, returns a list with given track id, else returns empty list.  
checkGenresX(TrackId,[],_,[TrackId]).    
checkGenresX(_,[GenreH|_],DislikedGenres,[]):-genreInList(GenreH,DislikedGenres),!.
checkGenresX(TrackId,[_|GenreT],DislikedGenres,List):-checkGenresX(TrackId,GenreT,DislikedGenres,List).

%Gets a genre and a list of genre names, True if genre is a substring of given genres in list.
genreInList(_,[],0).
genreInList(Genre,[ListH|ListT]):-genreInList(Genre,ListT); sub_string(Genre,_,_,_,ListH).









