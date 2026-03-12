:- ['library_data.pl'].

%------------------------------------ Static Data ------------------------------------%
all_books([prolog_fundamentals, recursion_in_depth, list_programming, ai_intro]).
all_students([ali, sara, omar, mona, yousef, nour, karim]).

%------------------------------------ Helper Predicates ------------------------------------%



%my_findall(X, Goal, L):-

%------------------------------------ Task 1 Helpers ------------------------------------%

%books_borrowed_by_student
filter_book(_, [], []).
filter_book(Student, [Book| Tail], [Book| ResultsTail]):-
    borrowed(Student, Book),
    !,
    filter_book(Student, Tail, ResultsTail).

filter_book(Student, [_| Tail], ResultsTail):-
    filter_book(Student, Tail, ResultsTail).


%------------------------------------ Task 2 Helpers ------------------------------------%

%borrowers_count
count_borrowers(_,[], 0).
count_borrowers(Book, [Student| Tail], Count):-
    borrowed(Student, Book),
    !,
    count_borrowers(Book, Tail, TailCount),
    Count is TailCount + 1.

count_borrowers(Book, [_| Tail], Count):-
    count_borrowers(Book, Tail, Count).


%------------------------------------ Task 3 Helpers ------------------------------------%

find_max([], CurrentMaxBook, _, CurrentMaxBook).

%most_borrowed_book
find_max([NextBook | RestBooks], CurrentMaxBook, CurrentMaxCount, FinalBestBook) :-
    borrowers_count(NextBook, NextCount),
    ( NextCount > CurrentMaxCount ->
        find_max(RestBooks, NextBook, NextCount, FinalBestBook);

        find_max(RestBooks, CurrentMaxBook, CurrentMaxCount, FinalBestBook)
    ).


%------------------------------------ Task 4 Helpers ------------------------------------%

%ratings_of_book 
collect_ratings(_, [], []).

collect_ratings(Book, [Student|Tail], [(Student,Score)|ResultsTail]) :-
    rating(Student, Book, Score),
    !,
    collect_ratings(Book, Tail, ResultsTail).

collect_ratings(Book, [_|Tail], ResultsTail) :-
    collect_ratings(Book, Tail, ResultsTail).

%------------------------------------ Task 5 Helpers ------------------------------------%

% find_top_rating(+StudentsList, +CurrentMaxScore, +CurrentTopStudent, -FinalTopStudent)
find_top_rating([], _, TopStudent, TopStudent).

find_top_rating([Student|Tail], CurrentMax, CurrentTopStudent, TopStudent) :-
    all_books(AllBooks),
    check_books_ratings(Student, AllBooks, CurrentMax, CurrentTopStudent, NewMax, NewTop),
    find_top_rating(Tail, NewMax, NewTop, TopStudent).

% check_books_ratings(+Student, +BooksList, +CurrentMax, +CurrentTopStudent, -FinalMax, -FinalTop)
check_books_ratings(_, [], CurrentMax, CurrentTopStudent, CurrentMax, CurrentTopStudent).

check_books_ratings(Student, [Book|Tail], CurrentMax, CurrentTopStudent, FinalMax, FinalTop) :-
    ( rating(Student, Book, Score), Score > CurrentMax ->
        TempMax = Score,
        TempTop = Student
    ;
        TempMax = CurrentMax,
        TempTop = CurrentTopStudent
    ),
    check_books_ratings(Student, Tail, TempMax, TempTop, FinalMax, FinalTop).


%------------------------------------ Task 6 Helpers ------------------------------------%

% append multiple lists (flatten)
flatten_lists([], []).
flatten_lists([List|Tail], FlatList) :-
    flatten_lists(Tail, FlatTail),
    append_lists(List, FlatTail, FlatList).

% append two lists (must come first)
append_lists([], L, L).
append_lists([H|T], L2, [H|R]) :-
    append_lists(T, L2, R).

% collect all topics from a list of books
collect_topics([], []).
collect_topics([Book|Tail], AllTopics) :-
    topics(Book, BookTopics),
    collect_topics(Tail, TailTopics),
    append_lists(BookTopics, TailTopics, AllTopics).

% count occurrences of an element in a list
count_occurrences(_, [], 0).
count_occurrences(X, [X|Tail], Count) :-
    !,
    count_occurrences(X, Tail, TailCount),
    Count is TailCount + 1.
count_occurrences(X, [_|Tail], Count) :-
    count_occurrences(X, Tail, Count).

% delete all occurrences of X from a list
delete_all(_, [], []).
delete_all(X, [X|Tail], Result) :-
    !,
    delete_all(X, Tail, Result).
delete_all(X, [H|Tail], [H|Result]) :-
    delete_all(X, Tail, Result).

% find most frequent topic in a list
find_max_topic([], Topic, _, Topic).
find_max_topic([T|Tail], CurrentTopic, CurrentCount, MostFrequent) :-
    count_occurrences(T, [T|Tail], C),
    (C > CurrentCount ->  % strictly greater
        NewTopic = T,
        NewCount = C
    ;
        NewTopic = CurrentTopic,
        NewCount = CurrentCount
    ),
    delete_all(T, Tail, NewTail),
    find_max_topic(NewTail, NewTopic, NewCount, MostFrequent).

%------------------------------------ Main Tasks-------------------------------------%

% Task 1
books_borrowed_by_student(Student, L) :-
    all_books(AllBooks),
    filter_book(Student, AllBooks, L).

% Task 2
borrowers_count(Book, Count):-
    all_students(Students),
    count_borrowers(Book, Students, Count).

% Task 3
most_borrowed_book(B):-
    all_books(Books),
    find_max(Books, 0, 0, B).

% Task 4
ratings_of_book(Book, L) :-
    all_students(Students),
    collect_ratings(Book, Students, L).

% Task 5
top_reviewer(Student) :-
    all_students(Students),
    find_top_rating(Students, 0, none, Student).

% Task 6
most_common_topic_for_student(Student, Topic) :-
    books_borrowed_by_student(Student, Books),
    collect_topics(Books, AllTopics),
    AllTopics = [First|_],
    find_max_topic(AllTopics, First, 0, Topic).