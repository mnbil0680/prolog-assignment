:- ['library_data.pl'].


all_books([prolog_fundamentals, recursion_in_depth, list_programming, ai_intro]).
all_students([ali, sara, omar, mona, yousef, nour, karim]).



%my_findall(X, Goal, L):-


%books_borrowed_by_student
filter_book(_, [], []).
filter_book(Student, [Book| Tail], [Book| ResultsTail]):-
    borrowed(Student, Book),
    !,
    filter_book(Student, Tail, ResultsTail).

filter_book(Student, [_| Tail], ResultsTail):-
    filter_book(Student, Tail, ResultsTail).



%borrowers_count
count_borrowers(_,[], 0).
count_borrowers(Book, [Student| Tail], Count):-
    borrowed(Student, Book),
    !,
    count_borrowers(Book, Tail, TailCount),
    Count is TailCount + 1.

count_borrowers(Book, [_| Tail], Count):-
    count_borrowers(Book, Tail, Count).


find_max([], CurrentMaxBook, _, CurrentMaxBook).

%most_borrowed_book
find_max([NextBook | RestBooks], CurrentMaxBook, CurrentMaxCount, FinalBestBook) :-
    borrowers_count(NextBook, NextCount),
    ( NextCount > CurrentMaxCount ->
        find_max(RestBooks, NextBook, NextCount, FinalBestBook);

        find_max(RestBooks, CurrentMaxBook, CurrentMaxCount, FinalBestBook)
    ).


%ratings_of_book 
collect_ratings(_, [], []).

collect_ratings(Book, [Student|Tail], [(Student,Score)|ResultsTail]) :-
    rating(Student, Book, Score),
    !,
    collect_ratings(Book, Tail, ResultsTail).

collect_ratings(Book, [_|Tail], ResultsTail) :-
    collect_ratings(Book, Tail, ResultsTail).


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
%------------------------------------ Main Tasks-------------------------------------%
books_borrowed_by_student(Student, L) :-
    all_books(AllBooks),
    filter_book(Student, AllBooks, L).

borrowers_count(Book, Count):-
    all_students(Students),
    count_borrowers(Book, Students, Count).

most_borrowed_book(B):-
    all_books(Books),
    find_max(Books, 0, 0, B).

ratings_of_book(Book, L) :-
    all_students(Students),
    collect_ratings(Book, Students, L).

top_reviewer(Student) :-
    all_students(Students),
    find_top_rating(Students, 0, none, Student).